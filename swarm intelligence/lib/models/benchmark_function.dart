import 'dart:math';

enum BenchmarkType {
  sphere('Sphere Function', 'f(x) = \\sum x_i^2', -5.12, 5.12, [0.0, 0.0], 0.0),
  rastrigin('Rastrigin Function', 'f(x) = 10d + \\sum [x_i^2 - 10\\cos(2\\pi x_i)]', -5.12, 5.12, [0.0, 0.0], 0.0),
  rosenbrock('Rosenbrock Function', 'f(x) = 100(x_2 - x_1^2)^2 + (x_1 - 1)^2', -2.048, 2.048, [1.0, 1.0], 0.0);

  final String name;
  final String formula;
  final double minBound;
  final double maxBound;
  final List<double> globalOptimumPos;
  final double globalOptimumVal;

  const BenchmarkType(
    this.name,
    this.formula,
    this.minBound,
    this.maxBound,
    this.globalOptimumPos,
    this.globalOptimumVal,
  );

  String get description {
    switch (this) {
      case BenchmarkType.sphere:
        return 'Smooth, convex, unimodal benchmark. Ideal for testing convergence speed and baseline accuracy.';
      case BenchmarkType.rastrigin:
        return 'Highly multimodal landscape with deep oscillatory local minima. Tests the algorithm\'s ability to escape traps.';
      case BenchmarkType.rosenbrock:
        return 'Non-convex "Banana valley". Finding the parabolic valley is trivial, but navigating to (1, 1) is difficult.';
    }
  }

  /// Evaluates the function at point [x, y]
  double evaluate(List<double> point) {
    if (point.length < 2) return 0.0;
    final x = point[0];
    final y = point[1];

    switch (this) {
      case BenchmarkType.sphere:
        return x * x + y * y;
      case BenchmarkType.rastrigin:
        return 20.0 + (x * x - 10.0 * cos(2 * pi * x)) + (y * y - 10.0 * cos(2 * pi * y));
      case BenchmarkType.rosenbrock:
        final term1 = y - x * x;
        final term2 = 1.0 - x;
        return 100.0 * term1 * term1 + term2 * term2;
    }
  }
}
