import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../shared/models/models.dart';

enum RealtimeStatus { conectando, conectado, desconectado }

/// Cliente Socket.IO do backend (`/tempo-real`, API.md · seção WebSocket).
///
/// Mantém uma única conexão para todo o app. Reassina automaticamente o mapa e
/// os postes abertos a cada (re)conexão. Todas as falhas degradam para
/// [RealtimeStatus.desconectado] — o app continua funcionando via REST.
class RealtimeClient {
  RealtimeClient({required this.baseUrl, required this.namespace});

  final String baseUrl;
  final String namespace;

  io.Socket? _socket;
  RealtimeStatus _status = RealtimeStatus.desconectado;
  RealtimeStatus get status => _status;

  final _statusCtrl = StreamController<RealtimeStatus>.broadcast();

  /// Lista completa vinda de `mapa:estado` ao (re)assinar o mapa.
  final _mapaEstadoCtrl = StreamController<List<PosteResumo>>.broadcast();

  /// Deltas de `postes:atualizados` (sala `mapa`).
  final _mapaDeltasCtrl = StreamController<List<PosteSnapshot>>.broadcast();

  /// Estado de um poste em `poste:estado` / `poste:atualizado`, já mesclado.
  final _posteCtrl = StreamController<PosteResumo>.broadcast();
  final _posteCache = <String, PosteResumo>{};

  final Set<String> _postesAssinados = {};
  bool _mapaAssinado = false;

  Stream<RealtimeStatus> statusStream() async* {
    yield _status;
    yield* _statusCtrl.stream;
  }

  Stream<List<PosteResumo>> get mapaEstado => _mapaEstadoCtrl.stream;
  Stream<List<PosteSnapshot>> get mapaDeltas => _mapaDeltasCtrl.stream;

  /// Emite o último estado conhecido do poste (se houver) e depois as mudanças.
  Stream<PosteResumo> posteStream(String posteId) async* {
    final cache = _posteCache[posteId];
    if (cache != null) yield cache;
    yield* _posteCtrl.stream.where((p) => p.id == posteId);
  }

  void _setStatus(RealtimeStatus s) {
    if (_status == s) return;
    _status = s;
    if (!_statusCtrl.isClosed) _statusCtrl.add(s);
  }

  void connect() {
    if (_socket != null) return;
    _setStatus(RealtimeStatus.conectando);

    final socket = io.io(
      '$baseUrl$namespace',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(2000)
          .setReconnectionDelayMax(10000)
          .build(),
    );
    _socket = socket;

    socket.onConnect((_) {
      _setStatus(RealtimeStatus.conectado);
      _mapaAssinado = true;
      socket.emit('assinar:mapa');
      for (final id in _postesAssinados) {
        socket.emit('assinar:poste', {'posteId': id});
      }
    });
    socket.onDisconnect((_) => _setStatus(RealtimeStatus.desconectado));
    socket.onConnectError((_) => _setStatus(RealtimeStatus.desconectado));
    socket.onError((e) => debugPrint('realtime erro: $e'));
    socket.on('erro', (d) => debugPrint('realtime evento erro: $d'));

    socket.on('mapa:estado', (data) {
      final postes = _lista(data?['postes'])
          .map(PosteResumo.fromJson)
          .toList(growable: false);
      if (!_mapaEstadoCtrl.isClosed) _mapaEstadoCtrl.add(postes);
    });

    socket.on('postes:atualizados', (data) {
      final snaps = _lista(data?['postes'])
          .map(PosteSnapshot.fromJson)
          .toList(growable: false);
      if (!_mapaDeltasCtrl.isClosed) _mapaDeltasCtrl.add(snaps);
    });

    socket.on('poste:estado', (data) {
      final j = data?['poste'];
      if (j is Map) _emitirPoste(PosteResumo.fromJson(_json(j)));
    });

    socket.on('poste:atualizado', (data) {
      if (data is! Map) return;
      final snap = PosteSnapshot.fromJson(_json(data));
      final base = _posteCache[snap.posteId];
      if (base != null) {
        _emitirPoste(base.aplicar(snap));
      }
    });

    socket.connect();
  }

  void _emitirPoste(PosteResumo p) {
    _posteCache[p.id] = p;
    if (!_posteCtrl.isClosed) _posteCtrl.add(p);
  }

  void assinarPoste(String posteId) {
    if (_postesAssinados.add(posteId)) {
      if (_status == RealtimeStatus.conectado) {
        _socket?.emit('assinar:poste', {'posteId': posteId});
      }
    }
  }

  void desassinarPoste(String posteId) {
    if (_postesAssinados.remove(posteId)) {
      if (_status == RealtimeStatus.conectado) {
        _socket?.emit('desassinar:poste', {'posteId': posteId});
      }
      _posteCache.remove(posteId);
    }
  }

  void dispose() {
    if (_mapaAssinado) _socket?.emit('desassinar:mapa');
    _socket?.dispose();
    _socket = null;
    _statusCtrl.close();
    _mapaEstadoCtrl.close();
    _mapaDeltasCtrl.close();
    _posteCtrl.close();
  }

  @visibleForTesting
  void debugInjectMapaEstado(List<PosteResumo> postes) {
    if (!_mapaEstadoCtrl.isClosed) _mapaEstadoCtrl.add(postes);
  }

  @visibleForTesting
  void debugInjectMapaDeltas(List<PosteSnapshot> snaps) {
    if (!_mapaDeltasCtrl.isClosed) _mapaDeltasCtrl.add(snaps);
  }

  @visibleForTesting
  void debugInjectPoste(PosteResumo poste) => _emitirPoste(poste);

  @visibleForTesting
  void debugSetStatus(RealtimeStatus s) => _setStatus(s);

  static List<Map<String, dynamic>> _lista(dynamic v) {
    if (v is! List) return const [];
    return v.whereType<Map>().map(_json).toList();
  }

  static Map<String, dynamic> _json(Map m) => m.map(
        (k, value) => MapEntry(k.toString(), value),
      );
}
