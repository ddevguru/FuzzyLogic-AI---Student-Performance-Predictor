import 'dart:math' as math;
import '../core/utils/math_utils.dart';

enum ActivationType {
  sigmoid,
  relu,
  tanh,
  linear,
  softmax,
}

class ActivationFunctions {
  static String getName(ActivationType type) {
    switch (type) {
      case ActivationType.sigmoid:
        return 'Sigmoid';
      case ActivationType.relu:
        return 'ReLU';
      case ActivationType.tanh:
        return 'Tanh';
      case ActivationType.linear:
        return 'Linear';
      case ActivationType.softmax:
        return 'Softmax';
    }
  }

  static String getFormula(ActivationType type) {
    switch (type) {
      case ActivationType.sigmoid:
        return r'f(x) = \frac{1}{1 + e^{-x}}';
      case ActivationType.relu:
        return r'f(x) = \max(0, x)';
      case ActivationType.tanh:
        return r'f(x) = \tanh(x)';
      case ActivationType.linear:
        return r'f(x) = x';
      case ActivationType.softmax:
        return r'f(z_i) = \frac{e^{z_i}}{\sum e^{z_k}}';
    }
  }

  static double activate(double x, ActivationType type) {
    switch (type) {
      case ActivationType.sigmoid:
        // Numerically stable sigmoid
        if (x >= 0) {
          final z = math.exp(-x);
          return 1.0 / (1.0 + z);
        } else {
          final z = math.exp(x);
          return z / (1.0 + z);
        }
      case ActivationType.relu:
        return math.max(0.0, x);
      case ActivationType.tanh:
        final e2x = math.exp(2 * x.clamp(-20.0, 20.0));
        return (e2x - 1.0) / (e2x + 1.0);
      case ActivationType.linear:
        return x;
      case ActivationType.softmax:
        // Scalar fallback (for full layer, layer handles vector softmax)
        return math.exp(x);
    }
  }

  /// Derivative with respect to weighted sum z or activation output a
  static double derivative(double z, double output, ActivationType type) {
    switch (type) {
      case ActivationType.sigmoid:
        // f'(z) = f(z) * (1 - f(z)) = output * (1 - output)
        return output * (1.0 - output);
      case ActivationType.relu:
        return z > 0 ? 1.0 : 0.0;
      case ActivationType.tanh:
        // f'(z) = 1 - tanh^2(z) = 1 - output^2
        return 1.0 - (output * output);
      case ActivationType.linear:
        return 1.0;
      case ActivationType.softmax:
        // Softmax derivative handled during vector backprop or combined with Cross-Entropy
        return output * (1.0 - output);
    }
  }

  /// Vector activation for Softmax
  static List<double> activateVector(List<double> zValues, ActivationType type) {
    if (type != ActivationType.softmax) {
      return zValues.map((z) => activate(z, type)).toList();
    }
    // Numerically stable Softmax
    final maxZ = zValues.reduce(math.max);
    final exps = zValues.map((z) => math.exp(z - maxZ)).toList();
    final sumExps = exps.reduce((a, b) => a + b);
    return exps.map((e) => e / (sumExps == 0 ? 1e-15 : sumExps)).toList();
  }
}
