import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  double _animationSpeed = 1.0;
  bool _reducedAnimations = false;
  double _defaultLearningRate = 0.1;
  int _defaultEpochs = 250;
  int _defaultHiddenNeurons = 4;

  ThemeMode get themeMode => _themeMode;
  double get animationSpeed => _animationSpeed;
  bool get reducedAnimations => _reducedAnimations;
  double get defaultLearningRate => _defaultLearningRate;
  int get defaultEpochs => _defaultEpochs;
  int get defaultHiddenNeurons => _defaultHiddenNeurons;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  SettingsService() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? true;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    _animationSpeed = prefs.getDouble('animationSpeed') ?? 1.0;
    _reducedAnimations = prefs.getBool('reducedAnimations') ?? false;
    _defaultLearningRate = prefs.getDouble('defaultLearningRate') ?? 0.1;
    _defaultEpochs = prefs.getInt('defaultEpochs') ?? 250;
    _defaultHiddenNeurons = prefs.getInt('defaultHiddenNeurons') ?? 4;
    notifyListeners();
  }

  void toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _themeMode == ThemeMode.dark);
  }

  void setAnimationSpeed(double speed) async {
    _animationSpeed = speed;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('animationSpeed', speed);
  }

  void setReducedAnimations(bool val) async {
    _reducedAnimations = val;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reducedAnimations', val);
  }

  void setDefaults({
    required double learningRate,
    required int epochs,
    required int hiddenNeurons,
  }) async {
    _defaultLearningRate = learningRate;
    _defaultEpochs = epochs;
    _defaultHiddenNeurons = hiddenNeurons;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('defaultLearningRate', learningRate);
    await prefs.setInt('defaultEpochs', epochs);
    await prefs.setInt('defaultHiddenNeurons', hiddenNeurons);
  }

  void resetToDefaults() async {
    _themeMode = ThemeMode.dark;
    _animationSpeed = 1.0;
    _reducedAnimations = false;
    _defaultLearningRate = 0.1;
    _defaultEpochs = 250;
    _defaultHiddenNeurons = 4;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
