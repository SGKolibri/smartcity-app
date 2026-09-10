import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartcity_app/core/realtime/realtime_client.dart';
import 'package:smartcity_app/core/realtime/realtime_providers.dart';
import 'package:smartcity_app/shared/models/models.dart';

PosteResumo _poste(
  String id, {
  StatusPoste status = StatusPoste.normal,
  double lum = 50,
  double consumo = 0.05,
}) =>
    PosteResumo(
      id: id,
      codigo: id,
      endereco: 'Rua X, 1',
      bairro: 'Centro',
      latitude: -15.95,
      longitude: -49.59,
      status: status,
      luminosidadeAtual: lum,
      consumoInstantaneoKw: consumo,
      ultimaLeituraEm: DateTime.utc(2026, 9, 10, 16),
    );

PosteSnapshot _snap(
  String id, {
  StatusPoste status = StatusPoste.consumoAlto,
  double lum = 100,
  double consumo = 0.2,
}) =>
    PosteSnapshot(
      posteId: id,
      codigo: id,
      status: status,
      luminosidadeAtual: lum,
      consumoInstantaneoKw: consumo,
      ultimaLeituraEm: DateTime.utc(2026, 9, 10, 16, 5),
      origem: 'sensores',
    );

void main() {
  test('PosteResumo.aplicar sobrepõe só os campos dinâmicos', () {
    final base = _poste('P-1');
    final atualizado = base.aplicar(_snap('P-1'));
    expect(atualizado.status, StatusPoste.consumoAlto);
    expect(atualizado.luminosidadeAtual, 100);
    expect(atualizado.consumoInstantaneoKw, 0.2);
    expect(atualizado.endereco, base.endereco); // cadastro preservado
  });

  test('Poste.comAoVivo preserva cadastro e deriva chamadoAberto', () {
    final p = Poste(
      id: 'P-1',
      codigo: 'P-1',
      endereco: 'Rua X, 1',
      bairro: 'Centro',
      latitude: -15.95,
      longitude: -49.59,
      status: StatusPoste.normal,
      luminosidadeAtual: 50,
      consumoInstantaneoKw: 0.05,
      ultimaLeituraEm: DateTime.utc(2026, 9, 10),
      cidade: 'Itaguari',
      uf: 'GO',
      criadoEm: DateTime.utc(2026, 9, 1),
      atualizadoEm: DateTime.utc(2026, 9, 1),
      chamadoAberto: false,
    );
    final vivo = p.comAoVivo(
      status: StatusPoste.falhaOffline,
      luminosidadeAtual: 50,
      consumoInstantaneoKw: 0,
      ultimaLeituraEm: null,
    );
    expect(vivo.chamadoAberto, isTrue);
    expect(vivo.cidade, 'Itaguari');
    expect(vivo.ultimaLeituraEm, p.ultimaLeituraEm); // mantém a última válida
  });

  test('PosteSnapshot.fromJson aceita posteId ou id', () {
    final a = PosteSnapshot.fromJson({
      'posteId': 'x',
      'codigo': 'P-9',
      'status': 'NORMAL',
      'luminosidadeAtual': 50,
      'consumoInstantaneoKw': 0.05,
      'ultimaLeituraEm': null,
    });
    expect(a.posteId, 'x');
  });

  test('mapaAoVivoProvider semeia com mapa:estado e aplica deltas', () async {
    final client = RealtimeClient(baseUrl: 'http://x', namespace: '/tempo-real');
    addTearDown(client.dispose);

    final container = ProviderContainer(
      overrides: [realtimeClientProvider.overrideWithValue(client)],
    );
    addTearDown(container.dispose);

    // Ativa o notifier.
    final sub = container.listen(mapaAoVivoProvider, (_, _) {});
    addTearDown(sub.close);

    expect(container.read(mapaAoVivoProvider), isEmpty);

    client.debugInjectMapaEstado([_poste('P-1'), _poste('P-2')]);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(mapaAoVivoProvider).length, 2);

    client.debugInjectMapaDeltas([_snap('P-1')]);
    await Future<void>.delayed(Duration.zero);
    final p1 = container.read(mapaAoVivoProvider)['P-1']!;
    expect(p1.status, StatusPoste.consumoAlto);
    expect(p1.luminosidadeAtual, 100);
    // Delta de poste ausente do estado é ignorado.
    client.debugInjectMapaDeltas([_snap('P-999')]);
    await Future<void>.delayed(Duration.zero);
    expect(container.read(mapaAoVivoProvider).containsKey('P-999'), isFalse);
  });
}
