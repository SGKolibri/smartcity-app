import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/realtime/realtime_providers.dart';
import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../core/theme/brut_typography.dart';
import '../../shared/widgets/widgets.dart';
import 'detalhe_providers.dart';
import 'widgets/acoes_poste.dart';
import 'widgets/cabecalho_poste.dart';
import 'widgets/consumo_ao_vivo.dart';
import 'widgets/historico_consumo.dart';
import 'widgets/log_eventos.dart';
import 'widgets/texto_contextual.dart';

/// Fase 3 · Tela Detalhe do poste.
class DetalhePosteScreen extends ConsumerWidget {
  const DetalhePosteScreen({super.key, required this.posteId});

  final String posteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(posteDetalheProvider(posteId));
    final eventos = ref.watch(eventosProvider(posteId)).value;
    final live = ref.watch(posteAoVivoProvider(posteId)).value;
    final aoVivo = ref.watch(aoVivoProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          async.value?.codigo ?? 'Poste',
          style: BrutType.mono(18, weight: FontWeight.w700),
        ),
      ),
      body: async.when(
        loading: () => const BrutLoading(),
        error: (e, _) => BrutError(
          error: e,
          onRetry: () => ref.invalidate(posteDetalheProvider(posteId)),
        ),
        data: (posteRest) {
          final poste = live == null
              ? posteRest
              : posteRest.comAoVivo(
                  status: live.status,
                  luminosidadeAtual: live.luminosidadeAtual,
                  consumoInstantaneoKw: live.consumoInstantaneoKw,
                  ultimaLeituraEm: live.ultimaLeituraEm,
                );
          return Column(
            children: [
            Expanded(
              child: RefreshIndicator(
                color: BrutColors.ink,
                onRefresh: () async {
                  ref.invalidate(posteDetalheProvider(posteId));
                  ref.invalidate(telemetriaProvider(posteId));
                  ref.invalidate(eventosProvider(posteId));
                  await ref.read(posteDetalheProvider(posteId).future);
                },
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    CabecalhoPoste(poste: poste),
                    Padding(
                      padding: const EdgeInsets.all(BrutSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ConsumoAoVivo(poste: poste, aoVivo: aoVivo),
                          const SizedBox(height: BrutSpacing.md),
                          TextoContextual(poste: poste, eventos: eventos),
                          const SizedBox(height: BrutSpacing.xl),
                          HistoricoConsumo(posteId: posteId),
                          const SizedBox(height: BrutSpacing.xl),
                          LogEventos(posteId: posteId),
                          const SizedBox(height: BrutSpacing.lg),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
              AcoesPoste(poste: poste),
            ],
          );
        },
      ),
    );
  }
}
