import 'dart:math';

class RandomProvider {
  static Random create([int? seed]) {
    if (seed != null) {
      return Random(seed);
    }
    return Random();
  }

  /// Returns random double in range [min, max)
  static double nextDouble(Random rng, double min, double max) {
    return min + rng.nextDouble() * (max - min);
  }
}
