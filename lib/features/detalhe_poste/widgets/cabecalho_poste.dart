import 'package:flutter/material.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_spacing.dart';
import '../../../core/theme/brut_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// Cabeçalho do detalhe (PRD §5.2): código, endereço, coordenadas, cidade e
/// badge de status.
class CabecalhoPoste extends StatelessWidget {
  const CabecalhoPoste({super.key, required this.poste});

  final Poste poste;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(BrutSpacing.lg),
      decoration: const BoxDecoration(
        color: BrutColors.surface,
        border: Border(
          bottom: BorderSide(color: BrutColors.line, width: BrutStroke.regular),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  poste.codigo,
                  style: BrutType.mono(28, weight: FontWeight.w700),
                ),
              ),
              StatusBadge(poste.status),
            ],
          ),
          const SizedBox(height: BrutSpacing.sm),
          Text(poste.endereco, style: BrutType.sans(15)),
          Text(
            '${poste.bairro} · ${poste.cidade}/${poste.uf}',
            style: BrutType.sans(13, color: BrutColors.inkMuted),
          ),
          const SizedBox(height: BrutSpacing.xs),
          Text(
            Fmt.coordenadas(poste.latitude, poste.longitude),
            style: BrutType.mono(11, color: BrutColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
