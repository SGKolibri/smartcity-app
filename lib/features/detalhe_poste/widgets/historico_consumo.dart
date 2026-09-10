import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/brut_colors.dart';
import '../../../core/theme/brut_spacing.dart';
import '../../../core/theme/brut_typography.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/models/models.dart';
import '../../../shared/widgets/widgets.dart';
import '../detalhe_providers.dart';
import 'grafico_consumo.dart';

/// Histórico de consumo com seletor Hoje / Semana / Mês (PRD §5.2),
/// consumindo `GET /postes/:id/telemetria`.
class HistoricoConsumo extends ConsumerWidget {
  const HistoricoConsumo({super.key, required this.posteId});

  final String posteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(telemetriaPeriodoProvider);
    final async = ref.watch(telemetriaProvider(posteId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionLabel('Histórico de consumo'),
        const SizedBox(height: BrutSpacing.md),
        PeriodSelector<PeriodoTelemetria>(
          value: periodo,
          options: PeriodoTelemetria.values,
          labelOf: (p) => p.label,
          onChanged: (p) => ref.read(telemetriaPeriodoProvider.notifier).ir(p),
        ),
        const SizedBox(height: BrutSpacing.md),
        BrutCard(
          child: async.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 64),
              child: BrutLoading(),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: BrutError(
                error: e,
                onRetry: () => ref.invalidate(telemetriaProvider(posteId)),
              ),
            ),
            data: (h) => h.vazio
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: BrutEmpty(
                      message: 'Sem leituras neste período.',
                      icon: Icons.query_stats,
                    ),
                  )
                : _Conteudo(historico: h),
          ),
        ),
      ],
    );
  }
}

class _Conteudo extends StatelessWidget {
  const _Conteudo({required this.historico});

  final TelemetriaHistorico historico;

  @override
  Widget build(BuildContext context) {
    final r = historico.resumo;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GraficoConsumo(serie: historico.serie, periodo: historico.periodo),
        const SizedBox(height: BrutSpacing.md),
        Row(
          children: [
            Expanded(
              child: _Indicador(
                rotulo: 'Total',
                valor: Fmt.kwh(r.consumoTotalKwh),
              ),
            ),
            Expanded(
              child: _Indicador(
                rotulo: 'Custo',
                valor: Fmt.moeda(r.custoTotalReais),
              ),
            ),
          ],
        ),
        const SizedBox(height: BrutSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _Indicador(
                rotulo: 'Média',
                valor: Fmt.kw(r.mediaKw),
              ),
            ),
            Expanded(
              child: _Indicador(rotulo: 'Pico', valor: Fmt.kw(r.picoKw)),
            ),
            Expanded(
              child: _Indicador(
                rotulo: 'Economia',
                valor: Fmt.percentual(r.economiaPct, casas: 1),
                destaque: true,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.rotulo,
    required this.valor,
    this.destaque = false,
  });

  final String rotulo;
  final String valor;
  final bool destaque;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: BrutSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo.toUpperCase(), style: BrutType.label(9)),
          const SizedBox(height: 2),
          Text(
            valor,
            style: BrutType.mono(
              14,
              weight: FontWeight.w700,
              color: destaque ? BrutColors.statusNormal : BrutColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}
