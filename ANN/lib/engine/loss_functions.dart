import 'dart:math' as math;

enum LossType {
  mse,
  binaryCrossEntropy,
  categoricalCrossEntropy,
}

class LossFunctions {
  static String getName(LossType type) {
    switch (type) {
      case LossType.mse:
        return 'Mean Squared Error (MSE)';
      case LossType.binaryCrossEntropy:
        return 'Binary Cross Entropy (BCE)';
      case LossType.categoricalCrossEntropy:
        return 'Categorical Cross Entropy';
    }
  }

  /// Calculates sample loss for actual predictions vs targets
  static double computeLoss(List<double> predictions, List<double> targets, LossType type) {
    if (predictions.length != targets.length) {
      throw ArgumentError('Predictions and targets length mismatch');
    }

    switch (type) {
      case LossType.mse:
        double sumSqErr = 0.0;
        for (int i = 0; i < predictions.length; i++) {
          final diff = predictions[i] - targets[i];
          sumSqErr += diff * diff;
        }
        return sumSqErr / predictions.length;

      case LossType.binaryCrossEntropy:
        double sumBce = 0.0;
        for (int i = 0; i < predictions.length; i++) {
          final p = predictions[i].clamp(1e-15, 1.0 - 1e-15);
          final y = targets[i];
          sumBce += -(y * math.log(p) + (1.0 - y) * math.log(1.0 - p));
        }
        return sumBce / predictions.length;

      case LossType.categoricalCrossEntropy:
        double sumCce = 0.0;
        for (int i = 0; i < predictions.length; i++) {
          final p = predictions[i].clamp(1e-15, 1.0 - 1e-15);
          final y = targets[i];
          if (y > 0) {
            sumCce += -y * math.log(p);
          }
        }
        return sumCce;
    }
  }

  /// Calculates derivative dL/dA for backprop
  static List<double> computeLossDerivative(List<double> predictions, List<double> targets, LossType type) {
    final list = <double>[];
    for (int i = 0; i < predictions.length; i++) {
      final p = predictions[i];
      final y = targets[i];
      switch (type) {
        case LossType.mse:
          list.add(p - y);
          break;
        case LossType.binaryCrossEntropy:
          final pClamped = p.clamp(1e-15, 1.0 - 1e-15);
          list.add((pClamped - y) / (pClamped * (1.0 - pClamped)));
          break;
        case LossType.categoricalCrossEntropy:
          final pClamped = p.clamp(1e-15, 1.0 - 1e-15);
          list.add(-y / pClamped);
          break;
      }
    }
    return list;
  }
}
