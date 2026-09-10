import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:smartcity_app/core/network/api_client.dart';
import 'package:smartcity_app/core/theme/brut_theme.dart';
import 'package:smartcity_app/features/detalhe_poste/detalhe_poste_screen.dart';
import 'package:smartcity_app/features/detalhe_poste/widgets/texto_contextual.dart';
import 'package:smartcity_app/shared/data/smartcity_api.dart';
import 'package:smartcity_app/shared/models/models.dart';

Poste _poste({
  required StatusPoste status,
  double luminosidade = 50,
  double consumo = 0.05,
  DateTime? ultimaLeitura,
}) =>
    Poste(
      id: 'id-1',
      codigo: 'P-042',
      endereco: 'Rua Itaguari, 136',
      bairro: 'Centro',
      latitude: -15.954,
      longitude: -49.589,
      status: status,
      luminosidadeAtual: luminosidade,
      consumoInstantaneoKw: consumo,
      ultimaLeituraEm: ultimaLeitura,
      cidade: 'Itaguari',
      uf: 'GO',
      criadoEm: DateTime.utc(2026, 9, 10),
      atualizadoEm: DateTime.utc(2026, 9, 10),
      chamadoAberto: status == StatusPoste.falhaOffline,
    );

class _FakeApi extends SmartcityApi {
  _FakeApi() : super(ApiClient(dio: Dio()));

  Poste poste = _poste(status: StatusPoste.normal);

  @override
  Future<Poste> detalhePoste(String id, {CancelToken? cancelToken}) async =>
      poste;

  @override
  Future<TelemetriaHistorico> telemetria(
    String id, {
    PeriodoTelemetria periodo = PeriodoTelemetria.hoje,
    CancelToken? cancelToken,
  }) async =>
      TelemetriaHistorico(
        posteId: id,
        periodo: periodo,
        inicio: DateTime.utc(2026, 9, 10),
        fim: DateTime.utc(2026, 9, 10, 12),
        resumo: const ResumoTelemetria(
          consumoTotalKwh: 1.5,
          custoTotalReais: 0.87,
          mediaKw: 0.1,
          picoKw: 0.19,
          economiaPct: 41,
        ),
        serie: [
          BucketTelemetria(
            inicio: DateTime.utc(2026, 9, 10, 3),
            consumoKwh: 0.12,
            mediaKw: 0.12,
            picoKw: 0.19,
          ),
        ],
      );

  @override
  Future<List<EventoSensor>> eventos(
    String id, {
    int limite = 50,
    CancelToken? cancelToken,
  }) async =>
      [];
}

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('detalhe renderiza cabeçalho e ações do poste', (tester) async {
    final api = _FakeApi()..poste = _poste(status: StatusPoste.normal);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [smartcityApiProvider.overrideWithValue(api)],
        child: MaterialApp(
          theme: BrutTheme.build(),
          home: const DetalhePosteScreen(posteId: 'id-1'),
        ),
      ),
    );
    // LiveIndicator/progress animam para sempre: não usar pumpAndSettle.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('P-042'), findsWidgets);
    expect(find.text('Rua Itaguari, 136'), findsOneWidget);
    expect(find.text('AGENDAR MANUTENÇÃO'), findsOneWidget);
    expect(find.text('VER NO MAPA'), findsOneWidget);
  });

  testWidgets('texto contextual: falha offline abre chamado', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrutTheme.build(),
        home: Scaffold(
          body: TextoContextual(
            poste: _poste(
              status: StatusPoste.falhaOffline,
              ultimaLeitura: DateTime.utc(2026, 9, 10, 14),
            ),
            eventos: const [],
          ),
        ),
      ),
    );

    expect(find.text('Telemetria ausente'), findsOneWidget);
    expect(find.textContaining('Chamado aberto automaticamente'), findsOneWidget);
  });

  testWidgets('texto contextual: veículo detectado no pico', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BrutTheme.build(),
        home: Scaffold(
          body: TextoContextual(
            poste: _poste(status: StatusPoste.normal, luminosidade: 100),
            eventos: [
              EventoSensor(
                id: 'e1',
                tipo: TipoEventoSensor.veiculoDetectado,
                sentido: SentidoVeiculo.aproximando,
                luminosidadeResultante: 100,
                timestamp: DateTime.utc(2026, 9, 10, 15, 40),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.textContaining('Veículo detectado'), findsOneWidget);
  });
}
