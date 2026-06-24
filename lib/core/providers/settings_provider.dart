import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Keys
const _kThemeModeKey = 'settings_theme_mode';

class AppSettings {
  final ThemeMode themeMode;

  const AppSettings({
    this.themeMode = ThemeMode.light,
  });

  AppSettings copyWith({ThemeMode? themeMode}) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  late SharedPreferences _prefs;

  @override
  Future<AppSettings> build() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIndex =
        _prefs.getInt(_kThemeModeKey) ?? 1; // 0=dark, 1=light, 2=system
    return AppSettings(
      themeMode: _themeModeFromIndex(themeIndex),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final current = state.valueOrNull ?? const AppSettings();
    state = AsyncValue.data(current.copyWith(themeMode: mode));
    await _prefs.setInt(_kThemeModeKey, _indexFromThemeMode(mode));
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
}

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
