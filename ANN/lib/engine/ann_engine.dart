import 'dart:async';
import '../models/neural_network.dart';
import '../models/training_sample.dart';
import '../models/training_result.dart';
import 'loss_functions.dart';
import 'optimizers.dart';
import 'backpropagation.dart';
import 'metrics.dart';

typedef TrainingProgressCallback = void Function(
  int currentEpoch,
  int totalEpochs,
  double trainLoss,
  double trainAccuracy,
  double? valLoss,
  double? valAccuracy,
);

class AnnEngine {
  final NeuralNetwork network;
  final LossType lossType;
  final Optimizer optimizer;

  bool _isPaused = false;
  bool _isCancelled = false;

  AnnEngine({
    required this.network,
    required this.lossType,
    required this.optimizer,
  });

  void pause() => _isPaused = true;
  void resume() => _isPaused = false;
  void stop() => _isCancelled = true;

  bool get isPaused => _isPaused;
  bool get isCancelled => _isCancelled;

  /// Runs full training loop across dataset
  Future<TrainingResult> train({
    required List<TrainingSample> trainSamples,
    List<TrainingSample>? valSamples,
    required int epochs,
    required String datasetName,
    required bool isClassification,
    TrainingProgressCallback? onProgress,
    int yieldEveryEpochs = 5,
  }) async {
    _isPaused = false;
    _isCancelled = false;
    final stopwatch = Stopwatch()..start();
    final epochMetrics = <EpochMetric>[];

    for (int epoch = 1; epoch <= epochs; epoch++) {
      if (_isCancelled) break;

      while (_isPaused && !_isCancelled) {
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // Shuffle samples each epoch for mini-batch / SGD stochasticity
      final samplesCopy = List<TrainingSample>.from(trainSamples)..shuffle();

      double epochLossSum = 0.0;
      for (var sample in samplesCopy) {
        final step = Backpropagation.trainSample(
          network,
          sample.inputs,
          sample.targets,
          lossType,
          optimizer,
        );
        epochLossSum += step.loss;
      }

      final trainLoss = epochLossSum / trainSamples.length;
      final trainEval = ModelMetrics.evaluate(network, trainSamples, isClassification: isClassification);
      
      double? valLoss;
      double? valAccuracy;
      if (valSamples != null && valSamples.isNotEmpty) {
        final valEval = ModelMetrics.evaluate(network, valSamples, isClassification: isClassification);
        valLoss = valEval.mse;
        valAccuracy = valEval.accuracy;
      }

      final metric = EpochMetric(
        epoch: epoch,
        trainLoss: trainLoss,
        valLoss: valLoss,
        trainAccuracy: trainEval.accuracy,
        valAccuracy: valAccuracy,
      );
      epochMetrics.add(metric);

      if (onProgress != null) {
        onProgress(epoch, epochs, trainLoss, trainEval.accuracy, valLoss, valAccuracy);
      }

      // Periodically yield to main thread so UI stays 60fps responsive
      if (epoch % yieldEveryEpochs == 0) {
        await Future.delayed(Duration.zero);
      }
    }

    stopwatch.stop();

    final finalEval = ModelMetrics.evaluate(network, trainSamples, isClassification: isClassification);
    double? finalValLoss;
    double? finalValAccuracy;
    if (valSamples != null && valSamples.isNotEmpty) {
      final valEval = ModelMetrics.evaluate(network, valSamples, isClassification: isClassification);
      finalValLoss = valEval.mse;
      finalValAccuracy = valEval.accuracy;
    }

    return TrainingResult(
      totalEpochs: epochMetrics.length,
      epochMetrics: epochMetrics,
      finalLoss: epochMetrics.isNotEmpty ? epochMetrics.last.trainLoss : 0.0,
      finalValLoss: finalValLoss,
      finalAccuracy: finalEval.accuracy,
      finalValAccuracy: finalValAccuracy,
      trainingDuration: stopwatch.elapsed,
      datasetName: datasetName,
      architectureSummary: network.architectureSummary,
    );
  }
}
