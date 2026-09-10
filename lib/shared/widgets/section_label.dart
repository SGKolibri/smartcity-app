import 'package:flutter/material.dart';

import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../core/theme/brut_typography.dart';

/// Rótulo de seção em caixa alta com um traço à esquerda — recorrente no BRUT.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 14, height: 2, color: BrutColors.ink),
        const SizedBox(width: BrutSpacing.sm),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: BrutType.label(12, color: BrutColors.ink),
          ),
        ),
        ?trailing,
      ],
    );
  }
}
