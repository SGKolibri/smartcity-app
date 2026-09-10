import 'enums.dart';
import 'json.dart';

/// Item de `GET /postes/:id/eventos` — log do sensor 360°.
class EventoSensor {
  const EventoSensor({
    required this.id,
    required this.tipo,
    required this.sentido,
    required this.luminosidadeResultante,
    required this.timestamp,
  });

  final String id;
  final TipoEventoSensor tipo;

  /// Direção do veículo — pode ser nula.
  final SentidoVeiculo? sentido;

  /// 100 na detecção, 50 no retorno ao piso.
  final double luminosidadeResultante;
  final DateTime timestamp;

  bool get subiuParaPico => tipo == TipoEventoSensor.veiculoDetectado;

  factory EventoSensor.fromJson(Json j) => EventoSensor(
        id: j['id'] as String,
        tipo: TipoEventoSensor.fromWire(j['tipo'] as String),
        sentido: SentidoVeiculo.fromWire(j['sentido'] as String?),
        luminosidadeResultante: asDouble(j['luminosidadeResultante']),
        timestamp: asDate(j['timestamp']),
      );
}
