import 'package:flutter/material.dart';

import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../core/theme/brut_typography.dart';

enum BrutButtonVariant { primary, secondary, danger }

/// Botão brutalista: retângulo de borda dura, sem sombra, rótulo em mono.
class BrutButton extends StatelessWidget {
  const BrutButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = BrutButtonVariant.primary,
    this.expand = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final BrutButtonVariant variant;
  final bool expand;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;

    final (Color bg, Color fg) = switch (variant) {
      BrutButtonVariant.primary => (BrutColors.ink, BrutColors.paper),
      BrutButtonVariant.secondary => (BrutColors.surface, BrutColors.ink),
      BrutButtonVariant.danger => (BrutColors.statusFalha, BrutColors.onAccent),
    };

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (icon != null) ...[
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: BrutSpacing.sm),
        ],
        if (!loading)
          Text(
            label.toUpperCase(),
            style: BrutType.mono(
              13,
              weight: FontWeight.w700,
              color: fg,
              letterSpacing: 1,
            ),
          ),
      ],
    );

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: InkWell(
        onTap: enabled ? onPressed : null,
        splashFactory: NoSplash.splashFactory,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: BrutSpacing.lg,
            vertical: BrutSpacing.md,
          ),
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: BrutColors.line, width: BrutStroke.regular),
          ),
          child: content,
        ),
      ),
    );
  }
}
