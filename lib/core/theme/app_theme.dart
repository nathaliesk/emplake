import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../settings/settings_controller.dart';

/// Monta o ThemeData a partir das configurações do jogador.
class AppTheme {
  const AppTheme._();

  static ThemeData build(AppSettings s, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(seedColor: s.seedColor, brightness: brightness);
    final base = ThemeData(colorScheme: scheme, useMaterial3: true, brightness: brightness);
    TextTheme text;
    try {
      text = GoogleFonts.getTextTheme(s.fontFamily, base.textTheme);
    } catch (_) {
      text = base.textTheme;
    }
    return base.copyWith(
      textTheme: text,
      snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(visualDensity: VisualDensity.compact, textStyle: WidgetStatePropertyAll(text.labelLarge)),
      ),
    );
  }
}
