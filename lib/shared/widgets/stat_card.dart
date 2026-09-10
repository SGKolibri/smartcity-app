import 'package:flutter/material.dart';

import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../core/theme/brut_typography.dart';
import 'brut_card.dart';

/// Célula de indicador: rótulo, valor em mono e, opcionalmente, uma variação
/// percentual com seta. Reutilizada nos KPIs (consumo/custo) e no detalhe
/// (Média / Pico / Economia).
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.deltaLabel,
    this.deltaPositiveIsGood = false,
    this.deltaValue,
    this.emphasis = false,
  });

  final String label;
  final String value;
  final String? unit;

  /// Texto já formatado da variação (ex.: "−5,4%").
  final String? deltaLabel;

  /// Valor bruto da variação, para escolher a cor/seta. `null` = neutro.
  final double? deltaValue;

  /// Se `true`, queda (delta < 0) é boa (verde). Consumo de energia: menos é bom.
  final bool deltaPositiveIsGood;

  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    return BrutCard(
      background: emphasis ? BrutColors.ink : BrutColors.surface,
      padding: const EdgeInsets.all(BrutSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: BrutType.label(
              10,
              color: emphasis ? BrutColors.paper : BrutColors.inkMuted,
            ),
          ),
          const SizedBox(height: BrutSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BrutType.mono(
                    22,
                    weight: FontWeight.w700,
                    color: emphasis ? BrutColors.paper : BrutColors.ink,
                  ),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: BrutType.mono(
                    12,
                    color: emphasis ? BrutColors.paper : BrutColors.inkMuted,
                  ),
                ),
              ],
            ],
          ),
          if (deltaLabel != null) ...[
            const SizedBox(height: BrutSpacing.xs),
            _Delta(
              label: deltaLabel!,
              value: deltaValue,
              positiveIsGood: deltaPositiveIsGood,
              onDark: emphasis,
            ),
          ],
        ],
      ),
    );
  }
}

class _Delta extends StatelessWidget {
  const _Delta({
    required this.label,
    required this.value,
    required this.positiveIsGood,
    required this.onDark,
  });

  final String label;
  final double? value;
  final bool positiveIsGood;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    Color color = onDark ? BrutColors.paper : BrutColors.inkMuted;
    IconData? icon;
    if (value != null && value != 0) {
      final bom = value! > 0 ? positiveIsGood : !positiveIsGood;
      color = bom ? BrutColors.statusNormal : BrutColors.statusFalha;
      icon = value! > 0 ? Icons.arrow_upward : Icons.arrow_downward;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) Icon(icon, size: 13, color: color),
        if (icon != null) const SizedBox(width: 2),
        Text(
          label,
          style: BrutType.mono(12, weight: FontWeight.w600, color: color),
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            'vs. anterior',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: BrutType.sans(
              11,
              color: onDark ? BrutColors.paper : BrutColors.inkMuted,
            ),
          ),
        ),
      ],
    );
  }
}
