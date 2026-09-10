import 'enums.dart';
import 'json.dart';

/// Resposta de `GET /postes/:id/telemetria` — histórico de consumo agregado.
class TelemetriaHistorico {
  const TelemetriaHistorico({
    required this.posteId,
    required this.periodo,
    required this.inicio,
    required this.fim,
    required this.resumo,
    required this.serie,
  });

  final String posteId;
  final PeriodoTelemetria periodo;
  final DateTime inicio;
  final DateTime fim;
  final ResumoTelemetria resumo;

  /// Barras do gráfico — por hora em `hoje`, por dia em `semana`/`mes`.
  final List<BucketTelemetria> serie;

  bool get vazio => serie.isEmpty;

  factory TelemetriaHistorico.fromJson(Json j) {
    final periodoWire = j['periodo'] as String? ?? 'hoje';
    return TelemetriaHistorico(
      posteId: j['posteId'] as String,
      periodo: PeriodoTelemetria.values.firstWhere(
        (p) => p.wire == periodoWire,
        orElse: () => PeriodoTelemetria.hoje,
      ),
      inicio: asDate(j['inicio']),
      fim: asDate(j['fim']),
      resumo: ResumoTelemetria.fromJson(j['resumo'] as Json),
      serie: asList(j['serie']).map(BucketTelemetria.fromJson).toList(),
    );
  }
}

class ResumoTelemetria {
  const ResumoTelemetria({
    required this.consumoTotalKwh,
    required this.custoTotalReais,
    required this.mediaKw,
    required this.picoKw,
    required this.economiaPct,
  });

  final double consumoTotalKwh;
  final double custoTotalReais;
  final double mediaKw;
  final double picoKw;

  /// % gasto a menos vs. operar sempre em 100% pelas mesmas horas acesas.
  final double economiaPct;

  factory ResumoTelemetria.fromJson(Json j) => ResumoTelemetria(
        consumoTotalKwh: asDouble(j['consumoTotalKwh']),
        custoTotalReais: asDouble(j['custoTotalReais']),
        mediaKw: asDouble(j['mediaKw']),
        picoKw: asDouble(j['picoKw']),
        economiaPct: asDouble(j['economiaPct']),
      );
}

class BucketTelemetria {
  const BucketTelemetria({
    required this.inicio,
    required this.consumoKwh,
    required this.mediaKw,
    required this.picoKw,
  });

  final DateTime inicio;
  final double consumoKwh;
  final double mediaKw;
  final double picoKw;

  factory BucketTelemetria.fromJson(Json j) => BucketTelemetria(
        inicio: asDate(j['inicio']),
        consumoKwh: asDouble(j['consumoKwh']),
        mediaKw: asDouble(j['mediaKw']),
        picoKw: asDouble(j['picoKw']),
      );
}
