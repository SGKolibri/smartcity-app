import 'package:flutter/material.dart';

import '../../shared/widgets/widgets.dart';

/// Fase 3 · Tela Detalhe do poste. Placeholder até a implementação.
class DetalhePosteScreen extends StatelessWidget {
  const DetalhePosteScreen({super.key, required this.posteId});

  final String posteId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalhe do poste')),
      body: const BrutEmpty(
        message: 'Detalhe do poste — em construção (fase 3).',
        icon: Icons.lightbulb_outline,
      ),
    );
  }
}
