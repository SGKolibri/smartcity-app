import 'package:flutter/material.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_spacing.dart';
import '../../../core/theme/brut_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';

/// Ranking dos 5 postes de maior consumo no período (PRD §5.3).
class RankingConsumoWidget extends StatelessWidget {
  const RankingConsumoWidget({
    super.key,
    required this.ranking,
    this.onTapPoste,
  });

  final RankingConsumo ranking;
  final void Function(String posteId)? onTapPoste;

  @override
  Widget build(BuildContext context) {
    if (ranking.itens.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(BrutSpacing.lg),
        decoration: BoxDecoration(
          color: BrutColors.surface,
          border: Border.all(color: BrutColors.line, width: BrutStroke.regular),
        ),
        child: Text('Sem consumo registrado no período.',
            style: BrutType.sans(13, color: BrutColors.inkMuted)),
      );
    }

    final maxKwh = ranking.itens.first.consumoKwh;

    return Container(
      decoration: BoxDecoration(
        color: BrutColors.surface,
        border: Border.all(color: BrutColors.line, width: BrutStroke.regular),
      ),
      child: Column(
        children: [
          for (var i = 0; i < ranking.itens.length; i++)
            _Linha(
              item: ranking.itens[i],
              fracao: maxKwh <= 0 ? 0 : ranking.itens[i].consumoKwh / maxKwh,
              primeira: i == 0,
              onTap: onTapPoste == null
                  ? null
                  : () => onTapPoste!(ranking.itens[i].posteId),
            ),
        ],
      ),
    );
  }
}

class _Linha extends StatelessWidget {
  const _Linha({
    required this.item,
    required this.fracao,
    required this.primeira,
    this.onTap,
  });

  final ItemRanking item;
  final double fracao;
  final bool primeira;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      splashFactory: NoSplash.splashFactory,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: BrutSpacing.md,
          vertical: BrutSpacing.md,
        ),
        decoration: BoxDecoration(
          border: primeira
              ? null
              : const Border(
                  top: BorderSide(
                      color: BrutColors.line, width: BrutStroke.thin),
                ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: item.posicao == 1
                        ? BrutColors.ink
                        : BrutColors.surface,
                    border:
                        Border.all(color: BrutColors.line, width: BrutStroke.thin),
                  ),
                  child: Text(
                    '${item.posicao}',
                    style: BrutType.mono(
                      11,
                      weight: FontWeight.w700,
                      color: item.posicao == 1
                          ? BrutColors.paper
                          : BrutColors.ink,
                    ),
                  ),
                ),
                const SizedBox(width: BrutSpacing.sm),
                Text(item.codigo,
                    style: BrutType.mono(14, weight: FontWeight.w700)),
                const Spacer(),
                Text(
                  Fmt.kwh(item.consumoKwh),
                  style: BrutType.mono(13, weight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: Text(
                '${item.endereco} · ${item.bairro}   —   ${Fmt.moeda(item.custoReais)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: BrutType.sans(11, color: BrutColors.inkMuted),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 30),
              child: LayoutBuilder(
                builder: (context, c) => Container(
                  height: 4,
                  width: c.maxWidth,
                  color: BrutColors.paper,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: c.maxWidth * fracao.clamp(0.0, 1.0),
                      color: BrutColors.ink,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
