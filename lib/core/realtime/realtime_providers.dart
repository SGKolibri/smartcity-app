import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/models/models.dart';
import '../config/app_config.dart';
import 'realtime_client.dart';

/// Conexão Socket.IO única do app. Conecta na criação, desconecta no dispose
/// do container.
final realtimeClientProvider = Provider<RealtimeClient>((ref) {
  final client = RealtimeClient(
    baseUrl: AppConfig.realtimeUrl,
    namespace: AppConfig.realtimeNamespace,
  );
  client.connect();
  ref.onDispose(client.dispose);
  return client;
});

/// Estado da conexão em tempo real (para o selo "AO VIVO").
final realtimeStatusProvider = StreamProvider<RealtimeStatus>((ref) {
  return ref.watch(realtimeClientProvider).statusStream();
});

/// `true` quando a conexão está ativa.
final aoVivoProvider = Provider<bool>((ref) {
  return ref.watch(realtimeStatusProvider).value == RealtimeStatus.conectado;
});

/// Estado ao vivo do mapa: mapa de `posteId → PosteResumo`, semeado por
/// `mapa:estado` e atualizado por `postes:atualizados`.
class MapaAoVivoNotifier extends Notifier<Map<String, PosteResumo>> {
  @override
  Map<String, PosteResumo> build() {
    final client = ref.watch(realtimeClientProvider);
    final subs = <StreamSubscription<void>>[];

    subs.add(client.mapaEstado.listen((postes) {
      state = {for (final p in postes) p.id: p};
    }));

    subs.add(client.mapaDeltas.listen((snaps) {
      if (state.isEmpty) return;
      final next = Map<String, PosteResumo>.of(state);
      for (final s in snaps) {
        final base = next[s.posteId];
        if (base != null) next[s.posteId] = base.aplicar(s);
      }
      state = next;
    }));

    ref.onDispose(() {
      for (final s in subs) {
        s.cancel();
      }
    });
    return const {};
  }
}

final mapaAoVivoProvider =
    NotifierProvider<MapaAoVivoNotifier, Map<String, PosteResumo>>(
        MapaAoVivoNotifier.new);

/// Estado ao vivo de um poste específico (tela de detalhe). Assina/desassina
/// `poste:<id>` conforme o provider é observado.
final posteAoVivoProvider =
    StreamProvider.autoDispose.family<PosteResumo?, String>((ref, id) {
  final client = ref.watch(realtimeClientProvider);
  client.assinarPoste(id);
  ref.onDispose(() => client.desassinarPoste(id));
  return client.posteStream(id).map<PosteResumo?>((p) => p);
});
