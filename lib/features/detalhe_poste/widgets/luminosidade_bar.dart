import 'package:flutter/material.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_typography.dart';

/// Barra de luminosidade 0–100% com marcação do piso operacional (50%, PRD §5.2).
class LuminosidadeBar extends StatelessWidget {
  const LuminosidadeBar({
    super.key,
    required this.valor,
    this.piso = 50,
    this.desligado = false,
  });

  final double valor;
  final double piso;
  final bool desligado;

  @override
  Widget build(BuildContext context) {
    final pct = (valor.clamp(0, 100)) / 100;
    final noPico = valor >= 99;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('LUMINOSIDADE', style: BrutType.label(10)),
            const Spacer(),
            Text(
              desligado ? 'DESLIGADO' : '${valor.toStringAsFixed(0)}%',
              style: BrutType.mono(16, weight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            return SizedBox(
              height: 22,
              child: Stack(
                children: [
                  // Trilho
                  Container(
                    decoration: BoxDecoration(
                      color: BrutColors.paper,
                      border: Border.all(
                        color: BrutColors.line,
                        width: 2,
                      ),
                    ),
                  ),
                  // Preenchimento
                  if (!desligado)
                    FractionallySizedBox(
                      widthFactor: pct,
                      child: Container(
                        color: noPico
                            ? BrutColors.lumAlta
                            : BrutColors.statusManutencaoSoft,
                      ),
                    ),
                  // Marcação do piso (50%)
                  Positioned(
                    left: (w * (piso / 100)).clamp(0, w) - 1,
                    top: -3,
                    bottom: -3,
                    child: Container(width: 2, color: BrutColors.accent),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(Icons.arrow_drop_up, size: 14, color: BrutColors.accent),
            Text(
              'piso ${piso.toStringAsFixed(0)}%',
              style: BrutType.sans(10, color: BrutColors.inkMuted),
            ),
            const Spacer(),
            if (noPico && !desligado)
              Text('pico 100%',
                  style: BrutType.sans(10, color: BrutColors.inkMuted)),
          ],
        ),
      ],
    );
  }
}
