import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get isSystemMode => _themeMode == ThemeMode.system;
  bool get isInitialized => _isInitialized;

  ThemeData get lightTheme => AppTheme.lightTheme;
  ThemeData get darkTheme => AppTheme.darkTheme;

  // Initialize theme from saved preferences
  Future<void> initialize() async {
    try {
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
          default:
            _themeMode = ThemeMode.system;
            break;
        }
      }
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error loading theme preferences: $e');
      _themeMode = ThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Set theme mode and save to preferences
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      String themeString;
      
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      
      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      print('Error saving theme preferences: $e');
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // If system mode, switch to dark
      await setThemeMode(ThemeMode.dark);
    }
  }

  // Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  // Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  // Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  // Get the current theme name for display
  String get currentThemeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  // Check if device is in dark mode (for system theme)
  bool isDeviceInDarkMode(BuildContext context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark;
  }

  // Get effective theme mode considering system settings
  bool getEffectiveIsDarkMode(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        return isDeviceInDarkMode(context);
    }
  }
}
