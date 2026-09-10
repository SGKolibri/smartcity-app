import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/data/smartcity_api.dart';
import '../../shared/models/models.dart';

/// Total fixo da rede (PRD §3 / API garante 248).
const int kTotalPostesRede = 248;

/// Filtro corrente do mapa: status + texto de busca (rua ou bairro).
class MapaFiltro {
  const MapaFiltro({this.status, this.busca = ''});

  final StatusPoste? status;
  final String busca;

  bool get ativo => status != null || busca.trim().isNotEmpty;

  MapaFiltro comStatus(StatusPoste? s) => MapaFiltro(status: s, busca: busca);
  MapaFiltro comBusca(String b) => MapaFiltro(status: status, busca: b);

  @override
  bool operator ==(Object other) =>
      other is MapaFiltro && other.status == status && other.busca == busca;

  @override
  int get hashCode => Object.hash(status, busca);
}

class MapaFiltroNotifier extends Notifier<MapaFiltro> {
  @override
  MapaFiltro build() => const MapaFiltro();

  void setStatus(StatusPoste? s) => state = state.comStatus(s);
  void setBusca(String b) => state = state.comBusca(b);
  void limpar() => state = const MapaFiltro();
}

final mapaFiltroProvider =
    NotifierProvider<MapaFiltroNotifier, MapaFiltro>(MapaFiltroNotifier.new);

/// Lista de postes do mapa, reagindo ao filtro (`GET /postes`).
final postesMapaProvider =
    FutureProvider.autoDispose<List<PosteResumo>>((ref) async {
  final filtro = ref.watch(mapaFiltroProvider);
  final api = ref.watch(smartcityApiProvider);
  final busca = filtro.busca.trim();
  return api.listarPostes(
    status: filtro.status,
    busca: busca.isEmpty ? null : busca,
  );
});

/// Poste selecionado no mapa (abre o bottom sheet). `null` = nenhum.
class PosteSelecionadoNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void selecionar(String id) => state = id;
  void limpar() => state = null;
}

final posteSelecionadoProvider =
    NotifierProvider<PosteSelecionadoNotifier, String?>(
        PosteSelecionadoNotifier.new);

/// Liga/desliga a camada de heatmap de luminosidade.
class HeatmapVisivelNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void alternar() => state = !state;
}

final heatmapVisivelProvider =
    NotifierProvider<HeatmapVisivelNotifier, bool>(HeatmapVisivelNotifier.new);
