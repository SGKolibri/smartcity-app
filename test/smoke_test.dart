import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartcity_app/core/theme/brut_theme.dart';
import 'package:smartcity_app/shared/models/models.dart';
import 'package:smartcity_app/shared/widgets/widgets.dart';

void main() {
  test('StatusPoste.fromWire mapeia os valores da API', () {
    expect(StatusPoste.fromWire('CONSUMO_ALTO'), StatusPoste.consumoAlto);
    expect(StatusPoste.fromWire('FALHA_OFFLINE'), StatusPoste.falhaOffline);
  });

  test('Poste.fromJson deriva chamadoAberto quando ausente', () {
    final p = Poste.fromJson({
      'id': 'a',
      'codigo': 'P-001',
      'endereco': 'Rua X, 1',
      'bairro': 'Centro',
      'latitude': -15.9,
      'longitude': -49.5,
      'status': 'FALHA_OFFLINE',
      'luminosidadeAtual': 50,
      'consumoInstantaneoKw': 0,
      'ultimaLeituraEm': null,
      'criadoEm': '2026-09-10T16:00:00.000Z',
      'atualizadoEm': '2026-09-10T16:00:00.000Z',
    });
    expect(p.chamadoAberto, isTrue);
    expect(p.ultimaLeituraEm, isNull);
  });

  testWidgets('PeriodSelector troca de valor ao tocar', (tester) async {
    PeriodoKpi selecionado = PeriodoKpi.mes;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: BrutTheme.build(),
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) => PeriodSelector<PeriodoKpi>(
                value: selecionado,
                options: PeriodoKpi.values,
                labelOf: (p) => p.label,
                onChanged: (p) => setState(() => selecionado = p),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('ANO'));
    await tester.pump();
    expect(selecionado, PeriodoKpi.ano);
  });
}
