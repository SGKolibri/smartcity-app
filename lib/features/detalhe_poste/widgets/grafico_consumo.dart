import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_typography.dart';
import '../../../shared/models/models.dart';

/// Gráfico de barras do histórico de consumo (PRD §5.2). Uma barra por bucket
/// da `serie` — por hora em "hoje", por dia em "semana"/"mês".
class GraficoConsumo extends StatelessWidget {
  const GraficoConsumo({
    super.key,
    required this.serie,
    required this.periodo,
  });

  final List<BucketTelemetria> serie;
  final PeriodoTelemetria periodo;

  @override
  Widget build(BuildContext context) {
    final maxKwh = serie.fold<double>(
      0,
      (m, b) => b.consumoKwh > m ? b.consumoKwh : m,
    );
    final topo = maxKwh <= 0 ? 1.0 : maxKwh * 1.2;
    final passo = _passoRotulos(serie.length);

    return SizedBox(
      height: 180,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceBetween,
          maxY: topo,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => BrutColors.ink,
              tooltipBorderRadius: BorderRadius.zero,
              getTooltipItem: (group, _, rod, _) {
                final b = serie[group.x];
                return BarTooltipItem(
                  '${b.consumoKwh.toStringAsFixed(2)} kWh\n',
                  BrutType.mono(11, weight: FontWeight.w700,
                      color: BrutColors.paper),
                  children: [
                    TextSpan(
                      text: _rotuloBucket(b, periodo),
                      style: BrutType.sans(10, color: BrutColors.paper),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(),
            rightTitles: const AxisTitles(),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 34,
                getTitlesWidget: (v, meta) {
                  if (v == meta.max || v == 0) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      v.toStringAsFixed(v < 1 ? 1 : 0),
                      style: BrutType.mono(9, color: BrutColors.inkMuted),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (v, meta) {
                  final i = v.toInt();
                  if (i < 0 || i >= serie.length || i % passo != 0) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      _rotuloEixo(serie[i], periodo),
                      style: BrutType.mono(9, color: BrutColors.inkMuted),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: topo / 2,
            getDrawingHorizontalLine: (_) => const FlLine(
              color: BrutColors.statusManutencaoSoft,
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: BrutColors.line, width: 2),
              bottom: BorderSide(color: BrutColors.line, width: 2),
            ),
          ),
          barGroups: [
            for (var i = 0; i < serie.length; i++)
              BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: serie[i].consumoKwh,
                    color: BrutColors.ink,
                    width: serie.length > 24 ? 5 : 10,
                    borderRadius: BorderRadius.zero,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  static int _passoRotulos(int n) {
    if (n <= 8) return 1;
    if (n <= 16) return 2;
    if (n <= 31) return 4;
    return 6;
  }

  static String _rotuloEixo(BucketTelemetria b, PeriodoTelemetria p) {
    final d = b.inicio.toLocal();
    return p == PeriodoTelemetria.hoje
        ? '${d.hour.toString().padLeft(2, '0')}h'
        : '${d.day}/${d.month}';
  }

  static String _rotuloBucket(BucketTelemetria b, PeriodoTelemetria p) {
    final d = b.inicio.toLocal();
    return p == PeriodoTelemetria.hoje
        ? '${d.hour.toString().padLeft(2, '0')}:00'
        : '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
  }
}
