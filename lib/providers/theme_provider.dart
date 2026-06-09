import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'app_theme';

  ThemeMode _themeMode = ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;

  String get currentTheme {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
          _themeMode = ThemeMode.system;
          break;
      }
      notifyListeners();
    }
  }

  Future<void> setTheme(String theme) async {
    final prefs = await SharedPreferences.getInstance();

    switch (theme) {
      case 'light':
        _themeMode = ThemeMode.light;
        await prefs.setString(_themeKey, 'light');
        break;
      case 'dark':
        _themeMode = ThemeMode.dark;
        await prefs.setString(_themeKey, 'dark');
        break;
      case 'system':
        _themeMode = ThemeMode.system;
        await prefs.setString(_themeKey, 'system');
        break;
    }

    notifyListeners();
  }

  ThemeData getThemeData() {
    switch (_themeMode) {
      case ThemeMode.light:
        return AppTheme.light;
      case ThemeMode.dark:
        return AppTheme.dark;
      case ThemeMode.system:
        // Check system brightness
        final brightness = WidgetsBinding.instance.window.platformBrightness;
        return brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
    }
  }
}
