import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const double kMinFontSize = 12.0;
const double kMaxFontSize = 28.0;
const double kDefaultFontSize = 16.0;

const _fontSizeKey = 'settings.font_size';
const _darkModeKey = 'settings.dark_mode';

/// Immutable snapshot of user-configurable app settings.
class SettingsState {
  final double fontSize;
  final bool darkMode;
  final bool loaded;

  const SettingsState({
    this.fontSize = kDefaultFontSize,
    this.darkMode = false,
    this.loaded = false,
  });

  ThemeMode get themeMode => darkMode ? ThemeMode.dark : ThemeMode.light;

  SettingsState copyWith({double? fontSize, bool? darkMode, bool? loaded}) {
    return SettingsState(
      fontSize: fontSize ?? this.fontSize,
      darkMode: darkMode ?? this.darkMode,
      loaded: loaded ?? this.loaded,
    );
  }
}

/// Persists font size and dark-mode preference via [SharedPreferences].
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble(_fontSizeKey) ?? kDefaultFontSize;
    final darkMode = prefs.getBool(_darkModeKey) ?? false;
    state = state.copyWith(
      fontSize: fontSize,
      darkMode: darkMode,
      loaded: true,
    );
  }

  Future<void> setFontSize(double size) async {
    final clamped = size.clamp(kMinFontSize, kMaxFontSize).toDouble();
    state = state.copyWith(fontSize: clamped);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, clamped);
  }

  Future<void> setDarkMode(bool enabled) async {
    state = state.copyWith(darkMode: enabled);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, enabled);
  }

  Future<void> toggleDarkMode() => setDarkMode(!state.darkMode);
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) => SettingsNotifier(),
);
