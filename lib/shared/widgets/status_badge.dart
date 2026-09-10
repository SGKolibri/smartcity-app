import 'package:flutter/material.dart';

import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../core/theme/brut_typography.dart';
import '../models/enums.dart';

/// Badge de status do poste — ponto sólido + rótulo, borda dura.
/// Usado no mapa (bottom sheet), no cabeçalho do detalhe e nos KPIs.
class StatusBadge extends StatelessWidget {
  const StatusBadge(
    this.status, {
    super.key,
    this.compact = false,
    this.filtro = false,
  });

  final StatusPoste status;

  /// Sem fundo, só ponto + texto (para listas densas).
  final bool compact;

  /// Usa o rótulo curto do filtro do mapa ("Atenção", "Falha").
  final bool filtro;

  @override
  Widget build(BuildContext context) {
    final texto = filtro ? status.labelFiltro : status.label;
    final dot = Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
    );

    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: BrutSpacing.xs),
          Text(texto, style: BrutType.label(11, color: BrutColors.ink)),
        ],
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BrutSpacing.sm,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: status.softColor,
        border: Border.all(color: status.color, width: BrutStroke.thin),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          dot,
          const SizedBox(width: BrutSpacing.sm),
          Text(
            texto.toUpperCase(),
            style: BrutType.mono(
              11,
              weight: FontWeight.w700,
              color: BrutColors.ink,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}
