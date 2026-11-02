import 'dart:math' as math;
import '../models/training_sample.dart';
import '../models/neural_network.dart';

class ModelMetrics {
  final double accuracy;
  final double precision;
  final double recall;
  final double f1Score;
  final double mse;
  final double mae;

  ModelMetrics({
    required this.accuracy,
    required this.precision,
    required this.recall,
    required this.f1Score,
    required this.mse,
    required this.mae,
  });

  static ModelMetrics evaluate(NeuralNetwork network, List<TrainingSample> samples, {bool isClassification = true}) {
    if (samples.isEmpty) {
      return ModelMetrics(accuracy: 0, precision: 0, recall: 0, f1Score: 0, mse: 0, mae: 0);
    }

    int correct = 0;
    int truePositives = 0;
    int falsePositives = 0;
    int falseNegatives = 0;
    double totalSqError = 0.0;
    double totalAbsError = 0.0;

    for (var sample in samples) {
      final outputs = network.forward(sample.inputs);

      // Error calculations
      for (int i = 0; i < outputs.length; i++) {
        final diff = outputs[i] - sample.targets[i];
        totalSqError += diff * diff;
        totalAbsError += diff.abs();
      }

      if (isClassification) {
        if (outputs.length == 1) {
          // Binary classification threshold 0.5
          final predClass = outputs[0] >= 0.5 ? 1 : 0;
          final targetClass = sample.targets[0] >= 0.5 ? 1 : 0;
          if (predClass == targetClass) correct++;
          if (predClass == 1 && targetClass == 1) truePositives++;
          if (predClass == 1 && targetClass == 0) falsePositives++;
          if (predClass == 0 && targetClass == 1) falseNegatives++;
        } else {
          // Multiclass argmax
          int predArgmax = 0;
          double maxPred = outputs[0];
          for (int i = 1; i < outputs.length; i++) {
            if (outputs[i] > maxPred) {
              maxPred = outputs[i];
              predArgmax = i;
            }
          }

          int targetArgmax = 0;
          double maxTarget = sample.targets[0];
          for (int i = 1; i < sample.targets.length; i++) {
            if (sample.targets[i] > maxTarget) {
              maxTarget = sample.targets[i];
              targetArgmax = i;
            }
          }

          if (predArgmax == targetArgmax) correct++;
        }
      }
    }

    final accuracy = isClassification ? (correct / samples.length) * 100.0 : 0.0;
    final precision = (truePositives + falsePositives) > 0 ? truePositives / (truePositives + falsePositives) : 0.0;
    final recall = (truePositives + falseNegatives) > 0 ? truePositives / (truePositives + falseNegatives) : 0.0;
    final f1 = (precision + recall) > 0 ? (2 * precision * recall) / (precision + recall) : 0.0;
    final mse = totalSqError / (samples.length * network.numOutputs);
    final mae = totalAbsError / (samples.length * network.numOutputs);

    return ModelMetrics(
      accuracy: accuracy,
      precision: precision,
      recall: recall,
      f1Score: f1,
      mse: mse,
      mae: mae,
    );
  }
}
