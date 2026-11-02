import 'dart:math' as math;
import 'dataset_base.dart';
import '../models/training_sample.dart';

class FunctionRegressionDataset extends AppDataset {
  final int numSamples;
  final int seed;

  FunctionRegressionDataset({
    this.numSamples = 80,
    this.seed = 123,
  }) : super(
          name: 'Sine Wave Regression',
          description:
              'A non-linear function approximation benchmark: target function y = sin(pi * x). Demonstrates continuous value prediction.',
          type: DatasetType.functionRegression,
          isClassification: false,
          featureNames: ['Input X'],
          targetNames: ['Target Y'],
        );

  @override
  List<TrainingSample> get trainSamples => _generateSamples(numSamples, seed);

  @override
  List<TrainingSample>? get valSamples => _generateSamples(25, seed + 50);

  List<TrainingSample> _generateSamples(int count, int rngSeed) {
    final random = math.Random(rngSeed);
    final list = <TrainingSample>[];

    for (int i = 0; i < count; i++) {
      // Input x uniformly sampled in [-1.0, 1.0]
      final x = -1.0 + (i / (count - 1)) * 2.0;
      // Target y = sin(pi * x), scaled to [0, 1] for neural net friendly target range
      final rawY = math.sin(math.pi * x);
      final yNormalized = (rawY + 1.0) / 2.0;

      list.add(TrainingSample(inputs: [x], targets: [yNormalized]));
    }
    return list;
  }
}
