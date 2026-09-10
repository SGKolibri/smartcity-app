import 'package:flutter/material.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_spacing.dart';
import '../../../core/theme/brut_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// Cards de consumo total e custo total, com variação % frente ao período
/// anterior equivalente (PRD §5.3). Rodapé com a tarifa vigente e o parcial
/// do dia corrente (fora da comparação).
class KpiTotais extends StatelessWidget {
  const KpiTotais({super.key, required this.kpis});

  final KpisResumo kpis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IntrinsicHeight(
          child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: StatCard(
                label: 'Consumo · ${kpis.periodo.label}',
                value: Fmt.inteiro(kpis.atual.consumoKwh.round()),
                unit: 'kWh',
                deltaLabel: Fmt.percentualVariacao(kpis.variacaoConsumoPct),
                deltaValue: kpis.variacaoConsumoPct,
              ),
            ),
            const SizedBox(width: BrutSpacing.md),
            Expanded(
              child: StatCard(
                label: 'Custo · ${kpis.periodo.label}',
                value: Fmt.moeda(kpis.atual.custoReais),
                deltaLabel: Fmt.percentualVariacao(kpis.variacaoCustoPct),
                deltaValue: kpis.variacaoCustoPct,
                emphasis: true,
              ),
            ),
          ],
          ),
        ),
        const SizedBox(height: BrutSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(BrutSpacing.md),
          decoration: BoxDecoration(
            color: BrutColors.surface,
            border:
                Border.all(color: BrutColors.line, width: BrutStroke.regular),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('TARIFA', style: BrutType.label(10)),
                  const SizedBox(width: BrutSpacing.sm),
                  Expanded(
                    child: Text(
                      '${kpis.tarifa.classe} · ${kpis.tarifa.descricao}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BrutType.sans(12),
                    ),
                  ),
                  const SizedBox(width: BrutSpacing.sm),
                  Text(
                    '${Fmt.moeda(kpis.tarifa.valorKwh)}/kWh',
                    style: BrutType.mono(12, weight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Divider(height: BrutStroke.regular),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text('HOJE ATÉ AGORA', style: BrutType.label(10)),
                  const SizedBox(width: BrutSpacing.sm),
                  Expanded(
                    child: Text(
                      '${Fmt.kwh(kpis.parcialHoje.consumoKwh)}  ·  '
                      '${Fmt.moeda(kpis.parcialHoje.custoReais)}',
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: BrutType.mono(12, color: BrutColors.inkMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
