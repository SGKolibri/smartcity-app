import 'package:flutter/material.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../shared/models/models.dart';

/// Marcador de poste no mapa — quadrado de borda dura preenchido com a cor do
/// status (PRD §5.1). Quando selecionado, ganha um anel de acento.
class PosteMarker extends StatelessWidget {
  const PosteMarker({
    super.key,
    required this.status,
    required this.selecionado,
    required this.onTap,
  });

  final StatusPoste status;
  final bool selecionado;
  final VoidCallback onTap;

  static const double tamanho = 34; // área de toque

  @override
  Widget build(BuildContext context) {
    final base = Container(
      width: selecionado ? 20 : 14,
      height: selecionado ? 20 : 14,
      decoration: BoxDecoration(
        color: status.color,
        border: Border.all(
          color: selecionado ? BrutColors.accent : BrutColors.ink,
          width: selecionado ? 3 : 2,
        ),
      ),
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: tamanho,
        height: tamanho,
        child: Center(child: base),
      ),
    );
  }
}
