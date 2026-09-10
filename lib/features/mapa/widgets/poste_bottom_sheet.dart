import 'package:flutter/material.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_spacing.dart';
import '../../../core/theme/brut_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// Resumo do poste selecionado no mapa (PRD §5.1): código, endereço, status,
/// consumo instantâneo, luminosidade atual e CTA para o detalhe.
class PosteBottomSheet extends StatelessWidget {
  const PosteBottomSheet({
    super.key,
    required this.poste,
    required this.onFechar,
    required this.onVerDetalhe,
  });

  final PosteResumo poste;
  final VoidCallback onFechar;
  final VoidCallback onVerDetalhe;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BrutColors.surface,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: BrutColors.line, width: BrutStroke.bold),
          ),
        ),
        padding: EdgeInsets.fromLTRB(
          BrutSpacing.lg,
          BrutSpacing.md,
          BrutSpacing.lg,
          BrutSpacing.lg + MediaQuery.viewPaddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        poste.codigo,
                        style: BrutType.mono(20, weight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${poste.endereco} · ${poste.bairro}',
                        style: BrutType.sans(13, color: BrutColors.inkMuted),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onFechar,
                  icon: const Icon(Icons.close),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: BrutSpacing.md),
            StatusBadge(poste.status),
            const SizedBox(height: BrutSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _Metrica(
                    rotulo: 'Consumo agora',
                    valor: poste.semTelemetria
                        ? '—'
                        : Fmt.kw(poste.consumoInstantaneoKw),
                  ),
                ),
                Container(width: BrutStroke.regular, height: 36, color: BrutColors.line),
                Expanded(
                  child: _Metrica(
                    rotulo: 'Luminosidade',
                    valor: poste.status == StatusPoste.manutencao
                        ? 'desligado'
                        : '${poste.luminosidadeAtual.toStringAsFixed(0)}%',
                  ),
                ),
              ],
            ),
            if (poste.ultimaLeituraEm != null) ...[
              const SizedBox(height: BrutSpacing.sm),
              Text(
                'Última leitura ${Fmt.desde(poste.ultimaLeituraEm!)}',
                style: BrutType.sans(11, color: BrutColors.inkMuted),
              ),
            ],
            const SizedBox(height: BrutSpacing.lg),
            BrutButton(
              label: 'Ver detalhe do poste',
              icon: Icons.arrow_forward,
              expand: true,
              onPressed: onVerDetalhe,
            ),
          ],
        ),
      ),
    );
  }
}

class _Metrica extends StatelessWidget {
  const _Metrica({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: BrutSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo.toUpperCase(), style: BrutType.label(10)),
          const SizedBox(height: 4),
          Text(valor, style: BrutType.mono(16, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
