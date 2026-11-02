import 'dart:math';

class FormattingUtils {
  static String formatFitness(double fitness) {
    if (fitness.isNaN || fitness.isInfinite) return '0.00';
    if (fitness > 1000) {
      return fitness.toStringAsFixed(1);
    }
    return fitness.toStringAsFixed(2);
  }

  static String formatPercent(double val) {
    return '${(val * 100).toStringAsFixed(1)}%';
  }

  static String formatImprovement(double initial, double finalVal) {
    if (initial == 0) return '+0.0%';
    double diff = ((finalVal - initial) / initial) * 100;
    String sign = diff >= 0 ? '+' : '';
    return '$sign${diff.toStringAsFixed(1)}%';
  }
}
