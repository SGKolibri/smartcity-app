import 'package:flutter/material.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_spacing.dart';
import '../../../core/theme/brut_typography.dart';
import '../../../shared/models/models.dart';

/// Distribuição de postes por status em barra empilhada, com contagem absoluta
/// por categoria (PRD §5.3).
class DistribuicaoStatus extends StatelessWidget {
  const DistribuicaoStatus({super.key, required this.dados});

  final PostesPorStatus dados;

  @override
  Widget build(BuildContext context) {
    final ordem = [
      StatusPoste.normal,
      StatusPoste.consumoAlto,
      StatusPoste.falhaOffline,
      StatusPoste.manutencao,
    ];

    return Container(
      padding: const EdgeInsets.all(BrutSpacing.lg),
      decoration: BoxDecoration(
        color: BrutColors.surface,
        border: Border.all(color: BrutColors.line, width: BrutStroke.regular),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('${dados.total}',
                  style: BrutType.mono(24, weight: FontWeight.w700)),
              const SizedBox(width: BrutSpacing.xs),
              Text('POSTES NA REDE', style: BrutType.label(10)),
            ],
          ),
          const SizedBox(height: BrutSpacing.md),
          // Barra empilhada — flex proporcional à contagem.
          Container(
            height: 26,
            decoration: BoxDecoration(
              border:
                  Border.all(color: BrutColors.line, width: BrutStroke.regular),
            ),
            child: Row(
              children: [
                for (final s in ordem)
                  if (dados.quantidadeDe(s) > 0)
                    Expanded(
                      flex: dados.quantidadeDe(s),
                      child: Container(color: s.color),
                    ),
              ],
            ),
          ),
          const SizedBox(height: BrutSpacing.md),
          // Legenda com contagem
          Wrap(
            spacing: BrutSpacing.lg,
            runSpacing: BrutSpacing.sm,
            children: [
              for (final s in ordem)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 10, color: s.color),
                    const SizedBox(width: 6),
                    Text(s.labelFiltro, style: BrutType.sans(12)),
                    const SizedBox(width: 4),
                    Text(
                      '${dados.quantidadeDe(s)}',
                      style: BrutType.mono(12, weight: FontWeight.w700),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
