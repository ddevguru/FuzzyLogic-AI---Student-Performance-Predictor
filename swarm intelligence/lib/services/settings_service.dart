import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/algorithm_type.dart';

class SettingsService extends ChangeNotifier {
  static const String _keyThemeMode = 'settings_theme_mode';
  static const String _keySimSpeed = 'settings_sim_speed_ms';
  static const String _keyDefaultAlgorithm = 'settings_default_algorithm';
  static const String _keyDefaultAgentCount = 'settings_default_agent_count';
  static const String _keyDefaultIterations = 'settings_default_iterations';
  static const String _keyDefaultSeed = 'settings_default_seed';
  static const String _keyReducedMotion = 'settings_reduced_motion';

  ThemeMode _themeMode = ThemeMode.dark;
  int _simulationSpeedMs = 120; // ms per step
  AlgorithmType _defaultAlgorithm = AlgorithmType.pso;
  int _defaultAgentCount = 25;
  int _defaultIterations = 80;
  int? _defaultSeed;
  bool _reducedMotion = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  int get simulationSpeedMs => _simulationSpeedMs;
  AlgorithmType get defaultAlgorithm => _defaultAlgorithm;
  int get defaultAgentCount => _defaultAgentCount;
  int get defaultIterations => _defaultIterations;
  int? get defaultSeed => _defaultSeed;
  bool get reducedMotion => _reducedMotion;

  SettingsService() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool(_keyThemeMode);
      if (isDark != null) {
        _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      }
      _simulationSpeedMs = prefs.getInt(_keySimSpeed) ?? 120;
      final algoIndex = prefs.getInt(_keyDefaultAlgorithm);
      if (algoIndex != null && algoIndex >= 0 && algoIndex < AlgorithmType.values.length) {
        _defaultAlgorithm = AlgorithmType.values[algoIndex];
      }
      _defaultAgentCount = prefs.getInt(_keyDefaultAgentCount) ?? 25;
      _defaultIterations = prefs.getInt(_keyDefaultIterations) ?? 80;
      _defaultSeed = prefs.getInt(_keyDefaultSeed);
      _reducedMotion = prefs.getBool(_keyReducedMotion) ?? false;
      notifyListeners();
    } catch (_) {
      // In-memory defaults fallback gracefully
    }
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyThemeMode, isDark);
    } catch (_) {}
  }

  Future<void> setSimulationSpeed(int speedMs) async {
    _simulationSpeedMs = speedMs.clamp(20, 1000);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keySimSpeed, _simulationSpeedMs);
    } catch (_) {}
  }

  Future<void> setDefaultAlgorithm(AlgorithmType algo) async {
    _defaultAlgorithm = algo;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyDefaultAlgorithm, algo.index);
    } catch (_) {}
  }

  Future<void> setDefaultAgentCount(int count) async {
    _defaultAgentCount = count.clamp(5, 100);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyDefaultAgentCount, _defaultAgentCount);
    } catch (_) {}
  }

  Future<void> setDefaultIterations(int iters) async {
    _defaultIterations = iters.clamp(10, 500);
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyDefaultIterations, _defaultIterations);
    } catch (_) {}
  }

  Future<void> setDefaultSeed(int? seed) async {
    _defaultSeed = seed;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (seed != null) {
        await prefs.setInt(_keyDefaultSeed, seed);
      } else {
        await prefs.remove(_keyDefaultSeed);
      }
    } catch (_) {}
  }

  Future<void> setReducedMotion(bool value) async {
    _reducedMotion = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyReducedMotion, value);
    } catch (_) {}
  }

  Future<void> resetDefaults() async {
    _themeMode = ThemeMode.dark;
    _simulationSpeedMs = 120;
    _defaultAlgorithm = AlgorithmType.pso;
    _defaultAgentCount = 25;
    _defaultIterations = 80;
    _defaultSeed = null;
    _reducedMotion = false;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (_) {}
  }
}
