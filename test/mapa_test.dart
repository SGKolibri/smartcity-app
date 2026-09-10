import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:smartcity_app/features/mapa/mapa_geo.dart';
import 'package:smartcity_app/features/mapa/mapa_providers.dart';
import 'package:smartcity_app/shared/models/models.dart';

PosteResumo _poste(String id, StatusPoste status) => PosteResumo(
      id: id,
      codigo: id,
      endereco: 'Rua X, 1',
      bairro: 'Centro',
      latitude: -15.95,
      longitude: -49.59,
      status: status,
      luminosidadeAtual: 50,
      consumoInstantaneoKw: 0.05,
      ultimaLeituraEm: null,
    );

void main() {
  test('extensão posicao converte para LatLng', () {
    expect(_poste('P-1', StatusPoste.normal).posicao, isA<LatLng>());
    expect(_poste('P-1', StatusPoste.normal).posicao.latitude, -15.95);
  });

  test('MapaFiltro: igualdade e flag ativo', () {
    const vazio = MapaFiltro();
    expect(vazio.ativo, isFalse);
    expect(vazio.comStatus(StatusPoste.falhaOffline).ativo, isTrue);
    expect(vazio.comBusca('centro').ativo, isTrue);
    expect(const MapaFiltro(busca: '  '), const MapaFiltro(busca: '  '));
  });

  test('MapaFiltroNotifier atualiza status e busca', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(mapaFiltroProvider.notifier);
    notifier.setStatus(StatusPoste.consumoAlto);
    notifier.setBusca('goiás');

    final f = container.read(mapaFiltroProvider);
    expect(f.status, StatusPoste.consumoAlto);
    expect(f.busca, 'goiás');

    notifier.limpar();
    expect(container.read(mapaFiltroProvider), const MapaFiltro());
  });

  test('heatmap visível alterna', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(container.read(heatmapVisivelProvider), isTrue);
    container.read(heatmapVisivelProvider.notifier).alternar();
    expect(container.read(heatmapVisivelProvider), isFalse);
  });
}
