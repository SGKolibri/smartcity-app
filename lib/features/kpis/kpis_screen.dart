import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../mapa/mapa_providers.dart';
import '../shell/shell_providers.dart';
import 'kpis_providers.dart';
import 'widgets/distribuicao_status.dart';
import 'widgets/grafico_comparativo.dart';
import 'widgets/kpi_totais.dart';
import 'widgets/ranking_consumo_widget.dart';

/// Fase 4 · Dashboard de KPIs.
class KpisScreen extends ConsumerWidget {
  const KpisScreen({super.key});

  Future<void> _recarregar(WidgetRef ref) async {
    ref.invalidate(kpisProvider);
    ref.invalidate(maiorConsumoProvider);
    ref.invalidate(postesPorStatusProvider);
    await ref.read(kpisProvider.future);
  }

  void _verNoMapa(WidgetRef ref, String posteId) {
    ref.read(posteSelecionadoProvider.notifier).selecionar(posteId);
    ref.read(homeTabProvider.notifier).ir(HomeTab.mapa);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodo = ref.watch(kpiPeriodoProvider);
    final kpis = ref.watch(kpisProvider);
    final ranking = ref.watch(maiorConsumoProvider);
    final distribuicao = ref.watch(postesPorStatusProvider);

    return RefreshIndicator(
      color: BrutColors.ink,
      onRefresh: () => _recarregar(ref),
      child: ListView(
        padding: const EdgeInsets.all(BrutSpacing.lg),
        children: [
          PeriodSelector<PeriodoKpi>(
            value: periodo,
            options: PeriodoKpi.values,
            labelOf: (p) => p.label,
            onChanged: (p) => ref.read(kpiPeriodoProvider.notifier).ir(p),
          ),
          const SizedBox(height: BrutSpacing.xl),

          _Secao(
            titulo: 'Consumo e custo',
            child: _asyncBox(
              kpis,
              onRetry: () => ref.invalidate(kpisProvider),
              builder: (k) => KpiTotais(kpis: k),
            ),
          ),
          const SizedBox(height: BrutSpacing.xl),

          _Secao(
            titulo: 'Atual vs. período anterior',
            child: _asyncBox(
              kpis,
              onRetry: () => ref.invalidate(kpisProvider),
              builder: (k) => BrutCard(child: GraficoComparativo(serie: k.serie)),
            ),
          ),
          const SizedBox(height: BrutSpacing.xl),

          _Secao(
            titulo: 'Maior consumo · top 5',
            child: _asyncBox(
              ranking,
              onRetry: () => ref.invalidate(maiorConsumoProvider),
              builder: (r) => RankingConsumoWidget(
                ranking: r,
                onTapPoste: (id) => _verNoMapa(ref, id),
              ),
            ),
          ),
          const SizedBox(height: BrutSpacing.xl),

          _Secao(
            titulo: 'Distribuição por status',
            child: _asyncBox(
              distribuicao,
              onRetry: () => ref.invalidate(postesPorStatusProvider),
              builder: (d) => DistribuicaoStatus(dados: d),
            ),
          ),
          const SizedBox(height: BrutSpacing.xxl),
        ],
      ),
    );
  }

  Widget _asyncBox<T>(
    AsyncValue<T> async, {
    required Widget Function(T) builder,
    required VoidCallback onRetry,
  }) {
    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: BrutLoading(),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: BrutError(error: e, onRetry: onRetry),
      ),
      data: builder,
    );
  }
}

class _Secao extends StatelessWidget {
  const _Secao({required this.titulo, required this.child});

  final String titulo;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(titulo),
        const SizedBox(height: BrutSpacing.md),
        child,
      ],
    );
  }
}
