import 'package:flutter/material.dart';

import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';

/// Card brutalista: borda dura 2px, radius 0, sem sombra.
/// Opcionalmente clicável e com uma faixa de acento à esquerda (status).
class BrutCard extends StatelessWidget {
  const BrutCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(BrutSpacing.lg),
    this.onTap,
    this.accent,
    this.background = BrutColors.surface,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Faixa de 6px à esquerda (ex.: cor do status do poste).
  final Color? accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    final border = accent == null
        ? Border.all(color: BrutColors.line, width: BrutStroke.regular)
        : Border(
            top: const BorderSide(
                color: BrutColors.line, width: BrutStroke.regular),
            right: const BorderSide(
                color: BrutColors.line, width: BrutStroke.regular),
            bottom: const BorderSide(
                color: BrutColors.line, width: BrutStroke.regular),
            left: BorderSide(color: accent!, width: 6),
          );

    final content = Container(
      decoration: BoxDecoration(color: background, border: border),
      padding: padding,
      child: child,
    );

    if (onTap == null) return content;
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      child: content,
    );
  }
}
