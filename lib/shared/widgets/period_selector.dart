import 'package:flutter/material.dart';

import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../core/theme/brut_typography.dart';

/// Segmented control brutalista, genérico. Um único bloco com divisórias
/// internas; o segmento ativo inverte para tinta cheia.
///
/// Compartilhado pelo detalhe do poste (Hoje / Semana / Mês) e pelo
/// dashboard de KPIs (Dia / Semana / Mês / Ano).
class PeriodSelector<T> extends StatelessWidget {
  const PeriodSelector({
    super.key,
    required this.value,
    required this.options,
    required this.labelOf,
    required this.onChanged,
  });

  final T value;
  final List<T> options;
  final String Function(T) labelOf;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BrutColors.surface,
        border: Border.all(color: BrutColors.line, width: BrutStroke.regular),
      ),
      child: Row(
        children: [
          for (var i = 0; i < options.length; i++)
            Expanded(
              child: _Segment(
                label: labelOf(options[i]),
                selected: options[i] == value,
                showLeftBorder: i != 0,
                onTap: () {
                  if (options[i] != value) onChanged(options[i]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.showLeftBorder,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool showLeftBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? BrutColors.ink : BrutColors.surface,
          border: showLeftBorder
              ? const Border(
                  left: BorderSide(
                    color: BrutColors.line,
                    width: BrutStroke.regular,
                  ),
                )
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          style: BrutType.mono(
            12,
            weight: FontWeight.w700,
            color: selected ? BrutColors.paper : BrutColors.inkMuted,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
