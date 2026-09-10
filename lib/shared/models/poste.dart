import 'enums.dart';
import 'json.dart';

/// `PosteResumo` — item da lista do mapa e dos snapshots de WebSocket (API.md).
class PosteResumo {
  const PosteResumo({
    required this.id,
    required this.codigo,
    required this.endereco,
    required this.bairro,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.luminosidadeAtual,
    required this.consumoInstantaneoKw,
    required this.ultimaLeituraEm,
  });

  final String id;
  final String codigo;
  final String endereco;
  final String bairro;
  final double latitude;
  final double longitude;
  final StatusPoste status;

  /// Percentual: 50 piso, 100 pico, 0 desligado (manutenção).
  final double luminosidadeAtual;

  /// kW instantâneos; 0 quando offline/manutenção.
  final double consumoInstantaneoKw;

  /// Timestamp da última leitura válida — pode ser nulo.
  final DateTime? ultimaLeituraEm;

  bool get semTelemetria => status == StatusPoste.falhaOffline;

  factory PosteResumo.fromJson(Json j) => PosteResumo(
        id: j['id'] as String,
        codigo: j['codigo'] as String,
        endereco: j['endereco'] as String,
        bairro: j['bairro'] as String,
        latitude: asDouble(j['latitude']),
        longitude: asDouble(j['longitude']),
        status: StatusPoste.fromWire(j['status'] as String),
        luminosidadeAtual: asDouble(j['luminosidadeAtual']),
        consumoInstantaneoKw: asDouble(j['consumoInstantaneoKw']),
        ultimaLeituraEm: asDateOrNull(j['ultimaLeituraEm']),
      );

  PosteResumo copyWith({
    StatusPoste? status,
    double? luminosidadeAtual,
    double? consumoInstantaneoKw,
    DateTime? ultimaLeituraEm,
  }) =>
      PosteResumo(
        id: id,
        codigo: codigo,
        endereco: endereco,
        bairro: bairro,
        latitude: latitude,
        longitude: longitude,
        status: status ?? this.status,
        luminosidadeAtual: luminosidadeAtual ?? this.luminosidadeAtual,
        consumoInstantaneoKw: consumoInstantaneoKw ?? this.consumoInstantaneoKw,
        ultimaLeituraEm: ultimaLeituraEm ?? this.ultimaLeituraEm,
      );

  /// Aplica um [PosteSnapshot] de WebSocket sobre este resumo.
  PosteResumo aplicar(PosteSnapshot s) => copyWith(
        status: s.status,
        luminosidadeAtual: s.luminosidadeAtual,
        consumoInstantaneoKw: s.consumoInstantaneoKw,
        ultimaLeituraEm: s.ultimaLeituraEm,
      );
}

/// `Poste` (detalhe) — `PosteResumo` + campos de `GET /postes/:id`.
class Poste extends PosteResumo {
  const Poste({
    required super.id,
    required super.codigo,
    required super.endereco,
    required super.bairro,
    required super.latitude,
    required super.longitude,
    required super.status,
    required super.luminosidadeAtual,
    required super.consumoInstantaneoKw,
    required super.ultimaLeituraEm,
    required this.cidade,
    required this.uf,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.chamadoAberto,
  });

  final String cidade;
  final String uf;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// `true` ⟺ `status == FALHA_OFFLINE`. O `PATCH` de status não devolve o campo,
  /// então derivamos quando ausente.
  final bool chamadoAberto;

  factory Poste.fromJson(Json j) => Poste(
        id: j['id'] as String,
        codigo: j['codigo'] as String,
        endereco: j['endereco'] as String,
        bairro: j['bairro'] as String,
        latitude: asDouble(j['latitude']),
        longitude: asDouble(j['longitude']),
        status: StatusPoste.fromWire(j['status'] as String),
        luminosidadeAtual: asDouble(j['luminosidadeAtual']),
        consumoInstantaneoKw: asDouble(j['consumoInstantaneoKw']),
        ultimaLeituraEm: asDateOrNull(j['ultimaLeituraEm']),
        cidade: j['cidade'] as String? ?? 'Itaguari',
        uf: j['uf'] as String? ?? 'GO',
        criadoEm: asDate(j['criadoEm']),
        atualizadoEm: asDate(j['atualizadoEm']),
        chamadoAberto: (j['chamadoAberto'] as bool?) ??
            ((j['status'] as String?) == 'FALHA_OFFLINE'),
      );

  /// Sobrepõe os campos dinâmicos vindos do WebSocket, mantendo os campos de
  /// cadastro. `chamadoAberto` passa a ser derivado do novo status.
  Poste comAoVivo({
    required StatusPoste status,
    required double luminosidadeAtual,
    required double consumoInstantaneoKw,
    required DateTime? ultimaLeituraEm,
  }) =>
      Poste(
        id: id,
        codigo: codigo,
        endereco: endereco,
        bairro: bairro,
        latitude: latitude,
        longitude: longitude,
        status: status,
        luminosidadeAtual: luminosidadeAtual,
        consumoInstantaneoKw: consumoInstantaneoKw,
        ultimaLeituraEm: ultimaLeituraEm ?? this.ultimaLeituraEm,
        cidade: cidade,
        uf: uf,
        criadoEm: criadoEm,
        atualizadoEm: atualizadoEm,
        chamadoAberto: status == StatusPoste.falhaOffline,
      );
}

/// `SnapshotPoste` — payload de `postes:atualizados` e `poste:atualizado`
/// (API.md, seção WebSocket). Só os campos que mudam a cada tick.
class PosteSnapshot {
  const PosteSnapshot({
    required this.posteId,
    required this.codigo,
    required this.status,
    required this.luminosidadeAtual,
    required this.consumoInstantaneoKw,
    required this.ultimaLeituraEm,
    this.origem,
    this.em,
  });

  final String posteId;
  final String codigo;
  final StatusPoste status;
  final double luminosidadeAtual;
  final double consumoInstantaneoKw;
  final DateTime? ultimaLeituraEm;

  /// `"sensores"` | `"telemetria"` | `"status"` — quando presente.
  final String? origem;
  final DateTime? em;

  factory PosteSnapshot.fromJson(Json j) => PosteSnapshot(
        posteId: (j['posteId'] ?? j['id']) as String,
        codigo: j['codigo'] as String? ?? '',
        status: StatusPoste.fromWire(j['status'] as String),
        luminosidadeAtual: asDouble(j['luminosidadeAtual']),
        consumoInstantaneoKw: asDouble(j['consumoInstantaneoKw']),
        ultimaLeituraEm: asDateOrNull(j['ultimaLeituraEm']),
        origem: j['origem'] as String?,
        em: asDateOrNull(j['em']),
      );
}
