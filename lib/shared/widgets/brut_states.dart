import 'package:flutter/material.dart';

import '../../core/network/api_exception.dart';
import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../core/theme/brut_typography.dart';
import 'brut_button.dart';

/// Estado de carregamento padrão — barra de progresso linear brutalista.
class BrutLoading extends StatelessWidget {
  const BrutLoading({super.key, this.label = 'Carregando…'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 120,
            child: LinearProgressIndicator(
              minHeight: 6,
              color: BrutColors.ink,
              backgroundColor: BrutColors.statusManutencaoSoft,
            ),
          ),
          const SizedBox(height: BrutSpacing.md),
          Text(label, style: BrutType.label(11)),
        ],
      ),
    );
  }
}

/// Estado de erro com mensagem normalizada e ação de tentar de novo.
class BrutError extends StatelessWidget {
  const BrutError({super.key, required this.error, this.onRetry});

  final Object error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final msg = error is ApiException
        ? (error as ApiException).message
        : 'Algo deu errado. Tente novamente.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(BrutSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(BrutSpacing.sm),
              decoration: BoxDecoration(
                border: Border.all(
                  color: BrutColors.statusFalha,
                  width: BrutStroke.regular,
                ),
              ),
              child: const Icon(
                Icons.priority_high,
                color: BrutColors.statusFalha,
              ),
            ),
            const SizedBox(height: BrutSpacing.md),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: BrutType.sans(14, color: BrutColors.ink),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: BrutSpacing.lg),
              BrutButton(
                label: 'Tentar de novo',
                icon: Icons.refresh,
                variant: BrutButtonVariant.secondary,
                onPressed: onRetry,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Estado vazio genérico.
class BrutEmpty extends StatelessWidget {
  const BrutEmpty({super.key, required this.message, this.icon});

  final String message;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BrutSpacing.xl,
          vertical: BrutSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: BrutColors.inkMuted, size: 24),
              const SizedBox(height: BrutSpacing.xs),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: BrutType.sans(13, color: BrutColors.inkMuted),
            ),
          ],
        ),
      ),
    );
  }
}
