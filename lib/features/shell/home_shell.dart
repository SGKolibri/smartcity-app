import 'package:flutter/material.dart';

import '../../core/theme/brut_colors.dart';
import '../../core/theme/brut_spacing.dart';
import '../../core/theme/brut_typography.dart';
import '../design_system/design_system_screen.dart';
import '../kpis/kpis_screen.dart';
import '../mapa/mapa_screen.dart';

/// Casca de navegação entre as telas principais. A integração completa
/// mapa ⇄ detalhe ⇄ KPIs é fechada na fase 6; por ora um `IndexedStack`
/// simples com a galeria do design system incluída para validação visual.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _tabs = <_Tab>[
    _Tab('Mapa', Icons.map_outlined, MapaScreen()),
    _Tab('KPIs', Icons.bar_chart_outlined, KpisScreen()),
    _Tab('Design', Icons.grid_view_outlined, DesignSystemScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Iluminação Pública',
                style: BrutType.sans(16, weight: FontWeight.w700)),
            Text('ITAGUARI · GO', style: BrutType.label(10)),
          ],
        ),
      ),
      body: IndexedStack(
        index: _index,
        children: [for (final t in _tabs) t.screen],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: BrutColors.line, width: BrutStroke.regular),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          backgroundColor: BrutColors.surface,
          indicatorColor: BrutColors.ink,
          surfaceTintColor: Colors.transparent,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: [
            for (final t in _tabs)
              NavigationDestination(
                icon: Icon(t.icon, color: BrutColors.inkMuted),
                selectedIcon: Icon(t.icon, color: BrutColors.paper),
                label: t.label,
              ),
          ],
        ),
      ),
    );
  }
}

class _Tab {
  const _Tab(this.label, this.icon, this.screen);

  final String label;
  final IconData icon;
  final Widget screen;
}
