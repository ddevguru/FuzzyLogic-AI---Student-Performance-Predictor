import 'package:flutter/material.dart';
import '../models/ga_config.dart';

class SettingsService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  int _animationSpeedMs = 350; // default normal
  GAConfig _defaultGAConfig = const GAConfig();

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  int get animationSpeedMs => _animationSpeedMs;
  GAConfig get defaultGAConfig => _defaultGAConfig;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setAnimationSpeed(int ms) {
    _animationSpeedMs = ms;
    notifyListeners();
  }

  void updateDefaultGAConfig(GAConfig config) {
    _defaultGAConfig = config;
    notifyListeners();
  }

  void resetSettings() {
    _themeMode = ThemeMode.light;
    _animationSpeedMs = 350;
    _defaultGAConfig = const GAConfig();
    notifyListeners();
  }
}
