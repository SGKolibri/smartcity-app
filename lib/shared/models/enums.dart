import 'package:flutter/material.dart';

import '../../core/theme/brut_colors.dart';

/// Status do poste (API.md · "Tipos de referência"). Derivado da telemetria,
/// exceto `MANUTENCAO` que é manual.
enum StatusPoste {
  normal('NORMAL', 'Normal', BrutColors.statusNormal, BrutColors.statusNormalSoft),
  consumoAlto(
    'CONSUMO_ALTO',
    'Consumo alto',
    BrutColors.statusAtencao,
    BrutColors.statusAtencaoSoft,
  ),
  falhaOffline(
    'FALHA_OFFLINE',
    'Falha · Offline',
    BrutColors.statusFalha,
    BrutColors.statusFalhaSoft,
  ),
  manutencao(
    'MANUTENCAO',
    'Manutenção',
    BrutColors.statusManutencao,
    BrutColors.statusManutencaoSoft,
  );

  const StatusPoste(this.wire, this.label, this.color, this.softColor);

  /// Valor cru trafegado pela API.
  final String wire;
  final String label;
  final Color color;
  final Color softColor;

  /// Rótulo curto para o filtro do mapa.
  String get labelFiltro => switch (this) {
        StatusPoste.consumoAlto => 'Atenção',
        StatusPoste.falhaOffline => 'Falha',
        _ => label,
      };

  static StatusPoste fromWire(String value) => StatusPoste.values.firstWhere(
        (s) => s.wire == value,
        orElse: () => StatusPoste.normal,
      );
}

/// Tipo de evento do sensor 360°.
enum TipoEventoSensor {
  veiculoDetectado('VEICULO_DETECTADO', 'Veículo detectado'),
  retornoAoPiso('RETORNO_AO_PISO', 'Retorno ao piso');

  const TipoEventoSensor(this.wire, this.label);

  final String wire;
  final String label;

  static TipoEventoSensor fromWire(String value) =>
      TipoEventoSensor.values.firstWhere(
        (t) => t.wire == value,
        orElse: () => TipoEventoSensor.retornoAoPiso,
      );
}

/// Sentido do veículo. Pode vir nulo da API.
enum SentidoVeiculo {
  aproximando('APROXIMANDO', 'Aproximando'),
  afastando('AFASTANDO', 'Afastando');

  const SentidoVeiculo(this.wire, this.label);

  final String wire;
  final String label;

  static SentidoVeiculo? fromWire(String? value) {
    if (value == null) return null;
    for (final s in SentidoVeiculo.values) {
      if (s.wire == value) return s;
    }
    return null;
  }
}

/// Janela do histórico de telemetria de um poste (`GET /postes/:id/telemetria`).
enum PeriodoTelemetria {
  hoje('hoje', 'Hoje'),
  semana('semana', 'Semana'),
  mes('mes', 'Mês');

  const PeriodoTelemetria(this.wire, this.label);

  final String wire;
  final String label;
}

/// Janela do dashboard de KPIs (`GET /kpis`).
enum PeriodoKpi {
  dia('dia', 'Dia'),
  semana('semana', 'Semana'),
  mes('mes', 'Mês'),
  ano('ano', 'Ano');

  const PeriodoKpi(this.wire, this.label);

  final String wire;
  final String label;
}
