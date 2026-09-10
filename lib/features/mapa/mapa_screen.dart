import 'package:flutter/material.dart';

import '../../shared/widgets/widgets.dart';

/// Fase 2 · Tela Mapa da cidade. Placeholder até a integração `flutter_map`.
class MapaScreen extends StatelessWidget {
  const MapaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const BrutEmpty(
      message: 'Mapa da cidade — em construção (fase 2).',
      icon: Icons.map_outlined,
    );
  }
}
