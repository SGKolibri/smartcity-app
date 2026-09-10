import 'package:flutter/material.dart';

import 'core/theme/brut_theme.dart';
import 'features/shell/home_shell.dart';

class SmartcityApp extends StatelessWidget {
  const SmartcityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Iluminação Pública Inteligente',
      debugShowCheckedModeBanner: false,
      theme: BrutTheme.build(),
      home: const HomeShell(),
    );
  }
}
