import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys
const _kThemeModeKey = 'settings_theme_mode';
const _kLocaleKey = 'settings_locale';

class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;

  const AppSettings({
    this.themeMode = ThemeMode.light,
    this.locale = const Locale('pt', 'BR'),
  });

  AppSettings copyWith({ThemeMode? themeMode, Locale? locale}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  Future<AppSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex = _prefs.getInt(_kThemeModeKey) ?? 1; // 0=dark, 1=light, 2=system
    final localeStr = _prefs.getString(_kLocaleKey) ?? 'pt_BR';
    return AppSettings(
      themeMode: _themeModeFromIndex(themeIndex),
      locale: _localeFromString(localeStr),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(current.copyWith(themeMode: mode));
    await _prefs.setInt(_kThemeModeKey, _indexFromThemeMode(mode));
  }

  Future<void> setLocale(Locale locale) async {
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(current.copyWith(locale: locale));
    await _prefs.setString(_kLocaleKey, '${locale.languageCode}_${locale.countryCode}');
  }

  ThemeMode _themeModeFromIndex(int index) {
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.system;
      default:
        return ThemeMode.dark;
    }
  }

  int _indexFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 1;
      case ThemeMode.system:
        return 2;
      default:
        return 0;
    }
  }

  Locale _localeFromString(String str) {
    if (str == 'en_US') return const Locale('en', 'US');
    return const Locale('pt', 'BR');
  }
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
