import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'brut_colors.dart';

/// Tipografia do BRUT: IBM Plex Sans para texto, IBM Plex Mono para números,
/// códigos de poste e rótulos técnicos.
abstract final class BrutType {
  static TextStyle sans(
    double size, {
    FontWeight weight = FontWeight.w400,
    Color color = BrutColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.ibmPlexSans(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle mono(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = BrutColors.ink,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.ibmPlexMono(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Rótulo em caixa alta, espaçado — muito usado no visual brutalista.
  static TextStyle label(double size, {Color color = BrutColors.inkMuted}) {
    return GoogleFonts.ibmPlexMono(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: 1.2,
    );
  }

  static TextTheme textTheme(TextTheme base) {
    return base.copyWith(
      displayLarge: sans(40, weight: FontWeight.w700, height: 1.05),
      displayMedium: sans(32, weight: FontWeight.w700, height: 1.1),
      headlineMedium: sans(24, weight: FontWeight.w700, height: 1.15),
      headlineSmall: sans(20, weight: FontWeight.w700, height: 1.2),
      titleLarge: sans(18, weight: FontWeight.w600),
      titleMedium: sans(16, weight: FontWeight.w600),
      bodyLarge: sans(16, height: 1.4),
      bodyMedium: sans(14, height: 1.4),
      bodySmall: sans(12, height: 1.35, color: BrutColors.inkMuted),
      labelLarge: mono(14, weight: FontWeight.w600),
      labelMedium: mono(12, weight: FontWeight.w600, letterSpacing: 1),
      labelSmall: label(11),
    );
  }
}
