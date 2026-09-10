import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_spacing.dart';
import '../../../core/theme/brut_typography.dart';
import '../../../shared/models/models.dart';
import '../mapa_providers.dart';

/// Filtro por status (PRD §5.1): Todos, Normal, Atenção, Falha, Manutenção.
/// Chips brutalistas em rolagem horizontal.
class FiltroStatusBar extends ConsumerWidget {
  const FiltroStatusBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selecionado = ref.watch(mapaFiltroProvider).status;

    void selecionar(StatusPoste? s) =>
        ref.read(mapaFiltroProvider.notifier).setStatus(s);

    return SizedBox(
      height: 34,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _Chip(
            label: 'Todos',
            cor: BrutColors.ink,
            ativo: selecionado == null,
            onTap: () => selecionar(null),
          ),
          for (final s in StatusPoste.values) ...[
            const SizedBox(width: BrutSpacing.sm),
            _Chip(
              label: s.labelFiltro,
              cor: s.color,
              ativo: selecionado == s,
              onTap: () => selecionar(s),
            ),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.cor,
    required this.ativo,
    required this.onTap,
  });

  final String label;
  final Color cor;
  final bool ativo;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: BrutSpacing.md),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ativo ? BrutColors.ink : BrutColors.surface,
          border: Border.all(color: BrutColors.line, width: BrutStroke.regular),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: cor, shape: BoxShape.circle),
            ),
            const SizedBox(width: BrutSpacing.sm),
            Text(
              label.toUpperCase(),
              style: BrutType.mono(
                11,
                weight: FontWeight.w700,
                color: ativo ? BrutColors.paper : BrutColors.ink,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
