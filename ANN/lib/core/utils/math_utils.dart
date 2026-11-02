import 'dart:math' as math;

class MathUtils {
  static final math.Random _random = math.Random(42);

  /// Return random float between min and max
  static double randomDouble(double min, double max, {math.Random? seedRandom}) {
    final r = seedRandom ?? _random;
    return min + r.nextDouble() * (max - min);
  }

  /// Xavier / Glorot initialization standard deviation
  static double xavierScale(int fanIn, int fanOut) {
    return math.sqrt(2.0 / (fanIn + fanOut));
  }

  /// He / Kaiming initialization standard deviation for ReLU
  static double heScale(int fanIn) {
    return math.sqrt(2.0 / fanIn);
  }

  /// Random Gaussian approximation using Box-Muller
  static double nextGaussian({math.Random? seedRandom}) {
    final r = seedRandom ?? _random;
    double u1 = r.nextDouble();
    double u2 = r.nextDouble();
    while (u1 <= 1e-15) {
      u1 = r.nextDouble();
    }
    return math.sqrt(-2.0 * math.log(u1)) * math.cos(2.0 * math.pi * u2);
  }

  /// Clip value to prevent overflow/underflow in exponential or log functions
  static double clip(double val, double minVal, double maxVal) {
    if (val < minVal) return minVal;
    if (val > maxVal) return maxVal;
    return val;
  }
}
