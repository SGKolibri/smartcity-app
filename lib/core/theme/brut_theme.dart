import 'package:flutter/material.dart';

import 'brut_colors.dart';
import 'brut_spacing.dart';
import 'brut_typography.dart';

/// Tema global. Radius 0, sem elevação/sombra, bordas duras em tudo.
abstract final class BrutTheme {
  static ThemeData build() {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
    );

    const border = OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: BrutColors.line, width: BrutStroke.regular),
    );

    return base.copyWith(
      scaffoldBackgroundColor: BrutColors.paper,
      canvasColor: BrutColors.paper,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      colorScheme: const ColorScheme.light(
        primary: BrutColors.accent,
        onPrimary: BrutColors.onAccent,
        secondary: BrutColors.ink,
        onSecondary: BrutColors.paper,
        surface: BrutColors.surface,
        onSurface: BrutColors.ink,
        error: BrutColors.statusFalha,
      ),
      textTheme: BrutType.textTheme(base.textTheme),
      dividerTheme: const DividerThemeData(
        color: BrutColors.line,
        thickness: BrutStroke.regular,
        space: BrutStroke.regular,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: BrutColors.paper,
        foregroundColor: BrutColors.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: BrutType.sans(18, weight: FontWeight.w700),
        shape: const Border(
          bottom: BorderSide(color: BrutColors.line, width: BrutStroke.regular),
        ),
      ),
      cardTheme: const CardThemeData(
        color: BrutColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(color: BrutColors.line, width: BrutStroke.regular),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: BrutColors.surface,
        elevation: 0,
        modalElevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BrutColors.surface,
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: const BorderSide(
            color: BrutColors.accent,
            width: BrutStroke.bold,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: BrutSpacing.md,
          vertical: BrutSpacing.md,
        ),
        hintStyle: BrutType.sans(14, color: BrutColors.inkMuted),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: BrutColors.ink,
        contentTextStyle: BrutType.sans(14, color: BrutColors.paper),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
