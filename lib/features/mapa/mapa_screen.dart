import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../core/theme/brut_typography.dart';
import '../../shared/models/models.dart';
import '../../shared/widgets/widgets.dart';
import '../detalhe_poste/detalhe_poste_screen.dart';
import 'mapa_geo.dart';
import 'mapa_providers.dart';
import 'widgets/busca_field.dart';
import 'widgets/filtro_status_bar.dart';
import 'widgets/luminosity_heatmap_layer.dart';
import 'widgets/poste_bottom_sheet.dart';
import 'widgets/poste_marker.dart';

/// Fase 2 · Tela Mapa da cidade.
class MapaScreen extends ConsumerStatefulWidget {
  const MapaScreen({super.key});

  @override
  ConsumerState<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends ConsumerState<MapaScreen> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _abrirDetalhe(String posteId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetalhePosteScreen(posteId: posteId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postesAsync = ref.watch(postesMapaProvider);
    final selecionadoId = ref.watch(posteSelecionadoProvider);
    final heatmapOn = ref.watch(heatmapVisivelProvider);

    final postes = postesAsync.value ?? const <PosteResumo>[];
    PosteResumo? selecionado;
    if (selecionadoId != null) {
      for (final p in postes) {
        if (p.id == selecionadoId) {
          selecionado = p;
          break;
        }
      }
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: MapaGeo.centroItaguari,
            initialZoom: MapaGeo.zoomInicial,
            minZoom: MapaGeo.zoomMin,
            maxZoom: MapaGeo.zoomMax,
            onTap: (_, _) =>
                ref.read(posteSelecionadoProvider.notifier).limpar(),
          ),
          children: [
            TileLayer(
              urlTemplate: MapaGeo.tileUrl,
              userAgentPackageName: MapaGeo.tileUserAgent,
              tileProvider: NetworkTileProvider(),
            ),
            if (heatmapOn) RepaintBoundary(child: LuminosityHeatmapLayer(postes: postes)),
            MarkerLayer(
              markers: [
                for (final p in postes)
                  Marker(
                    point: p.posicao,
                    width: PosteMarker.tamanho,
                    height: PosteMarker.tamanho,
                    alignment: Alignment.center,
                    child: PosteMarker(
                      status: p.status,
                      selecionado: p.id == selecionadoId,
                      onTap: () {
                        ref
                            .read(posteSelecionadoProvider.notifier)
                            .selecionar(p.id);
                        _mapController.move(
                          p.posicao,
                          _mapController.camera.zoom,
                        );
                      },
                    ),
                  ),
              ],
            ),
          ],
        ),

        const Positioned(right: 0, bottom: 0, child: _AtribuicaoOsm()),

        // Painel superior: contador, busca e filtros.
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.all(BrutSpacing.md),
            child: Column(
              children: [
                _Cabecalho(
                  total: postes.length,
                  carregando: postesAsync.isLoading,
                  heatmapOn: heatmapOn,
                  onToggleHeatmap: () =>
                      ref.read(heatmapVisivelProvider.notifier).alternar(),
                ),
                const SizedBox(height: BrutSpacing.sm),
                const BuscaField(),
                const SizedBox(height: BrutSpacing.sm),
                const FiltroStatusBar(),
                if (heatmapOn) ...[
                  const SizedBox(height: BrutSpacing.sm),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: HeatmapLegenda(),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Erro de carga (quando não há dados anteriores para mostrar).
        if (postesAsync.hasError && postes.isEmpty)
          Positioned.fill(
            child: ColoredBox(
              color: BrutColors.paper,
              child: BrutError(
                error: postesAsync.error!,
                onRetry: () => ref.invalidate(postesMapaProvider),
              ),
            ),
          ),

        // Bottom sheet do poste selecionado.
        if (selecionado case final sel?)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: PosteBottomSheet(
              poste: sel,
              onFechar: () =>
                  ref.read(posteSelecionadoProvider.notifier).limpar(),
              onVerDetalhe: () => _abrirDetalhe(sel.id),
            ),
          ),
      ],
    );
  }
}

class _Cabecalho extends ConsumerWidget {
  const _Cabecalho({
    required this.total,
    required this.carregando,
    required this.heatmapOn,
    required this.onToggleHeatmap,
  });

  final int total;
  final bool carregando;
  final bool heatmapOn;
  final VoidCallback onToggleHeatmap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtroAtivo = ref.watch(mapaFiltroProvider).ativo;
    final texto = filtroAtivo ? '$total / $kTotalPostesRede' : '$total';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: BrutSpacing.md,
        vertical: BrutSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: BrutColors.surface,
        border: Border.all(color: BrutColors.line, width: BrutStroke.regular),
      ),
      child: Row(
        children: [
          Text(texto, style: BrutType.mono(20, weight: FontWeight.w700)),
          const SizedBox(width: BrutSpacing.sm),
          Text('POSTES', style: BrutType.label(11)),
          if (carregando) ...[
            const SizedBox(width: BrutSpacing.sm),
            const SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: BrutColors.ink,
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onToggleHeatmap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: BrutSpacing.sm,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: heatmapOn ? BrutColors.ink : BrutColors.surface,
                border: Border.all(
                  color: BrutColors.line,
                  width: BrutStroke.thin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.blur_on,
                    size: 14,
                    color: heatmapOn ? BrutColors.paper : BrutColors.ink,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'HEATMAP',
                    style: BrutType.mono(
                      10,
                      weight: FontWeight.w700,
                      color: heatmapOn ? BrutColors.paper : BrutColors.ink,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AtribuicaoOsm extends StatelessWidget {
  const _AtribuicaoOsm();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BrutColors.surface.withValues(alpha: 0.85),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Text(
        MapaGeo.atribuicao,
        style: BrutType.sans(9, color: BrutColors.inkMuted),
      ),
    );
  }
}
