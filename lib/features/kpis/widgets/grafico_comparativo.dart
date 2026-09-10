import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_spacing.dart';
import '../../../core/theme/brut_typography.dart';
import '../../../shared/models/models.dart';

/// Gráfico comparativo do consumo no período atual frente ao anterior
/// (PRD §5.3). Barra sólida = atual; barra clara ao fundo = período anterior,
/// alinhada por índice.
class GraficoComparativo extends StatelessWidget {
  const GraficoComparativo({super.key, required this.serie});

  final SerieComparativa serie;

  @override
  Widget build(BuildContext context) {
    final n = serie.atual.length;
    double maxV = 0;
    for (var i = 0; i < n; i++) {
      final a = serie.atual[i].consumoKwh;
      final b = i < serie.anterior.length ? serie.anterior[i].consumoKwh : 0.0;
      maxV = [maxV, a, b].reduce((x, y) => x > y ? x : y);
    }
    final topo = maxV <= 0 ? 1.0 : maxV * 1.2;
    final passo = _passo(n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Chave(cor: BrutColors.ink, texto: 'Atual'),
            const SizedBox(width: BrutSpacing.md),
            _Chave(cor: BrutColors.statusManutencaoSoft, texto: 'Anterior'),
          ],
        ),
        const SizedBox(height: BrutSpacing.sm),
        SizedBox(
          height: 190,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceBetween,
              maxY: topo,
              minY: 0,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => BrutColors.ink,
                  tooltipBorderRadius: BorderRadius.zero,
                  getTooltipItem: (group, _, rod, _) {
                    final i = group.x;
                    final a = serie.atual[i].consumoKwh;
                    final b = i < serie.anterior.length
                        ? serie.anterior[i].consumoKwh
                        : 0.0;
                    return BarTooltipItem(
                      'atual ${a.toStringAsFixed(1)} kWh\n',
                      BrutType.mono(11,
                          weight: FontWeight.w700, color: BrutColors.paper),
                      children: [
                        TextSpan(
                          text: 'anterior ${b.toStringAsFixed(1)} kWh',
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
                    reservedSize: 38,
                    getTitlesWidget: (v, meta) {
                      if (v == 0 || v == meta.max) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          v >= 1000
                              ? '${(v / 1000).toStringAsFixed(1)}k'
                              : v.toStringAsFixed(0),
                          style: BrutType.mono(9, color: BrutColors.inkMuted),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 18,
                    getTitlesWidget: (v, meta) {
                      final i = v.toInt();
                      if (i < 0 || i >= n || i % passo != 0) {
                        return const SizedBox.shrink();
                      }
                      return SideTitleWidget(
                        meta: meta,
                        child: Text(
                          _rotulo(serie.atual[i].inicio, serie.granularidade),
                          style: BrutType.mono(8, color: BrutColors.inkMuted),
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
                for (var i = 0; i < n; i++)
                  BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: serie.atual[i].consumoKwh,
                        color: BrutColors.ink,
                        width: n > 20 ? 5 : 9,
                        borderRadius: BorderRadius.zero,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: i < serie.anterior.length
                              ? serie.anterior[i].consumoKwh
                              : 0,
                          color: BrutColors.statusManutencaoSoft,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  static int _passo(int n) {
    if (n <= 8) return 1;
    if (n <= 14) return 2;
    if (n <= 24) return 4;
    return 6;
  }

  static String _rotulo(DateTime d, String granularidade) {
    final l = d.toLocal();
    return switch (granularidade) {
      'hora' => '${l.hour.toString().padLeft(2, '0')}h',
      'mes' => _mes(l.month),
      _ => '${l.day}/${l.month}',
    };
  }

  static String _mes(int m) => const [
        'jan', 'fev', 'mar', 'abr', 'mai', 'jun', //
        'jul', 'ago', 'set', 'out', 'nov', 'dez'
      ][(m - 1) % 12];
}

class _Chave extends StatelessWidget {
  const _Chave({required this.cor, required this.texto});

  final Color cor;
  final String texto;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: cor,
            border: Border.all(color: BrutColors.line, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(texto, style: BrutType.sans(11, color: BrutColors.inkMuted)),
      ],
    );
  }
}
