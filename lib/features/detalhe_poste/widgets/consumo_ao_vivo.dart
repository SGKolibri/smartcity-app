import 'package:flutter/material.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_spacing.dart';
import '../../../core/theme/brut_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';
import 'luminosidade_bar.dart';

/// Consumo em tempo real + barra de luminosidade (PRD §5.2).
class ConsumoAoVivo extends StatelessWidget {
  const ConsumoAoVivo({super.key, required this.poste});

  final Poste poste;

  @override
  Widget build(BuildContext context) {
    final offline = poste.status == StatusPoste.falhaOffline;
    final manutencao = poste.status == StatusPoste.manutencao;
    final temTelemetria = !offline && !manutencao;

    return BrutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('CONSUMO', style: BrutType.label(10)),
              const Spacer(),
              LiveIndicator(active: temTelemetria),
            ],
          ),
          const SizedBox(height: BrutSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                temTelemetria
                    ? Fmt.inteiro(poste.consumoInstantaneoKw * 1000)
                    : '—',
                style: BrutType.mono(40, weight: FontWeight.w700),
              ),
              const SizedBox(width: BrutSpacing.xs),
              Text('W', style: BrutType.mono(16, color: BrutColors.inkMuted)),
              const SizedBox(width: BrutSpacing.sm),
              if (temTelemetria)
                Text(
                  '(${Fmt.kw(poste.consumoInstantaneoKw)})',
                  style: BrutType.mono(12, color: BrutColors.inkMuted),
                ),
            ],
          ),
          const SizedBox(height: BrutSpacing.lg),
          const Divider(),
          const SizedBox(height: BrutSpacing.md),
          LuminosidadeBar(
            valor: poste.luminosidadeAtual,
            desligado: manutencao,
          ),
        ],
      ),
    );
  }
}
