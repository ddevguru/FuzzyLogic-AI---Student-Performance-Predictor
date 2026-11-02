class Formatters {
  static String formatFitness(double value, {int decimals = 4}) {
    if (value.isInfinite) return 'Infinity';
    if (value.isNaN) return 'NaN';
    if (value.abs() >= 1000000) {
      return value.toStringAsExponential(2);
    }
    if (value.abs() < 0.0001 && value != 0) {
      return value.toStringAsExponential(3);
    }
    return value.toStringAsFixed(decimals);
  }

  static String formatDistance(double value) {
    return '${value.toStringAsFixed(1)} km';
  }

  static String formatDuration(int milliseconds) {
    if (milliseconds < 1000) {
      return '${milliseconds}ms';
    }
    final seconds = (milliseconds / 1000).toStringAsFixed(2);
    return '${seconds}s';
  }

  static String formatPercent(double value) {
    return '${(value * 100).toStringAsFixed(1)}%';
  }
}
