import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../game/domain/level.dart';

/// Instância do SharedPreferences, carregada no `main` antes do `runApp`.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Sobrescrito no main()'),
);

/// Fontes oferecidas (todas do Google Fonts, funcionam na web).
const availableFonts = <String>[
  'Roboto',
  'Inter',
  'EB Garamond',
  'Lato',
  'Merriweather',
  'Nunito',
  'Space Grotesk',
  'JetBrains Mono',
];

/// Cores semente sugeridas.
const seedPalette = <Color>[
  Color(0xFF3F51B5),
  Color(0xFF0061A4),
  Color(0xFF006A60),
  Color(0xFF2E7D32),
  Color(0xFF827717),
  Color(0xFFF57C00),
  Color(0xFFC62828),
  Color(0xFFAD1457),
  Color(0xFF6A1B9A),
  Color(0xFF455A64),
];

/// Temas prontos: cor semente + fonte.
enum ThemePreset {
  ocean(Color(0xFF0061A4), 'Inter'),
  forest(Color(0xFF2E7D32), 'Nunito'),
  sunset(Color(0xFFF57C00), 'Lato'),
  grape(Color(0xFF6A1B9A), 'Space Grotesk'),
  classic(Color(0xFF455A64), 'EB Garamond'),
  terminal(Color(0xFF006A60), 'JetBrains Mono');

  const ThemePreset(this.seed, this.font);
  final Color seed;
  final String font;
}

@immutable
class AppSettings {
  final ThemeMode themeMode;
  final double fontScale;
  final String fontFamily;
  final Color seedColor;
  final bool soundEnabled;

  /// Código do idioma ('pt' ou 'en'); `null` = idioma do aparelho.
  final String? languageCode;
  final Level level;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.fontScale = 1.0,
    this.fontFamily = 'Roboto',
    this.seedColor = const Color(0xFF3F51B5),
    this.soundEnabled = false,
    this.languageCode,
    this.level = Level.easy,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    String? fontFamily,
    Color? seedColor,
    bool? soundEnabled,
    String? languageCode,
    Level? level,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        fontScale: fontScale ?? this.fontScale,
        fontFamily: fontFamily ?? this.fontFamily,
        seedColor: seedColor ?? this.seedColor,
        soundEnabled: soundEnabled ?? this.soundEnabled,
        languageCode: languageCode ?? this.languageCode,
        level: level ?? this.level,
      );

  Locale? get locale => languageCode == null ? null : Locale(languageCode!);
}

/// Configurações do app, salvas no SharedPreferences a cada mudança.
class SettingsController extends Notifier<AppSettings> {
  static const _kTheme = 'settings.themeMode';
  static const _kScale = 'settings.fontScale';
  static const _kFont = 'settings.fontFamily';
  static const _kSeed = 'settings.seed';
  static const _kSound = 'settings.sound';
  static const _kLang = 'settings.language';
  static const _kLevel = 'settings.level';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final p = ref.read(sharedPreferencesProvider);
    final font = p.getString(_kFont);
    final levelName = p.getString(_kLevel);
    return AppSettings(
      themeMode: ThemeMode.values[p.getInt(_kTheme) ?? ThemeMode.system.index],
      fontScale: p.getDouble(_kScale) ?? 1.0,
      fontFamily: availableFonts.contains(font) ? font! : 'Roboto',
      seedColor: Color(p.getInt(_kSeed) ?? 0xFF3F51B5),
      soundEnabled: p.getBool(_kSound) ?? false,
      languageCode: p.getString(_kLang),
      level: Level.values.asNameMap()[levelName] ?? Level.easy,
    );
  }

  void setThemeMode(ThemeMode mode) {
    state = state.copyWith(themeMode: mode);
    _prefs.setInt(_kTheme, mode.index);
  }

  void setFontScale(double scale) {
    state = state.copyWith(fontScale: scale);
    _prefs.setDouble(_kScale, scale);
  }

  void setFontFamily(String font) {
    state = state.copyWith(fontFamily: font);
    _prefs.setString(_kFont, font);
  }

  void setSeedColor(Color color) {
    state = state.copyWith(seedColor: color);
    _prefs.setInt(_kSeed, color.toARGB32());
  }

  void applyPreset(ThemePreset preset) {
    setSeedColor(preset.seed);
    setFontFamily(preset.font);
  }

  void setSoundEnabled(bool enabled) {
    state = state.copyWith(soundEnabled: enabled);
    _prefs.setBool(_kSound, enabled);
  }

  void setLanguage(String code) {
    state = state.copyWith(languageCode: code);
    _prefs.setString(_kLang, code);
  }

  void setLevel(Level level) {
    state = state.copyWith(level: level);
    _prefs.setString(_kLevel, level.name);
  }

  /// Volta tudo ao padrão (tema do aparelho, fonte e tamanho normais).
  void reset() {
    for (final k in [_kTheme, _kScale, _kFont, _kSeed, _kSound]) {
      _prefs.remove(k);
    }
    state = AppSettings(languageCode: state.languageCode, level: state.level);
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
