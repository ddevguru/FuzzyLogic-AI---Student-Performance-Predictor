class AppConstants {
  static const String appTitle = "Genetic Optimization Lab";
  static const String appSubtitle = "Interactive Genetic Algorithm Simulator & Learning Platform";
  static const String appVersion = "v2.5.0-Lab";

  // GA Defaults
  static const int defaultPopulationSize = 50;
  static const int defaultMaxGenerations = 50;
  static const double defaultMutationRate = 0.05; // 5%
  static const double defaultCrossoverRate = 0.85; // 85%
  static const bool defaultElitism = true;
  static const int defaultElitismCount = 2;

  // Animation Speeds (ms per generation)
  static const int speedSlow = 800;
  static const int speedNormal = 350;
  static const int speedFast = 80;
}
