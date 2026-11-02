import 'dart:math' as math;
import 'dataset_base.dart';
import '../models/training_sample.dart';

class BinaryClassificationDataset extends AppDataset {
  final int numSamples;
  final int seed;

  BinaryClassificationDataset({
    this.numSamples = 100,
    this.seed = 42,
  }) : super(
          name: '2D Concentric Circles',
          description:
              'A 2-feature non-linear classification dataset consisting of inner and outer circular boundaries.',
          type: DatasetType.binaryClassification,
          isClassification: true,
          featureNames: ['Feature X1', 'Feature X2'],
          targetNames: ['Class Probability'],
        );

  @override
  List<TrainingSample> get trainSamples => _generateSamples(numSamples, seed);

  @override
  List<TrainingSample>? get valSamples => _generateSamples(30, seed + 100);

  List<TrainingSample> _generateSamples(int count, int rngSeed) {
    final random = math.Random(rngSeed);
    final list = <TrainingSample>[];

    for (int i = 0; i < count; i++) {
      // 50% Class 0 (inner ring), 50% Class 1 (outer ring)
      final isClass0 = i % 2 == 0;
      final radius = isClass0
          ? 0.1 + random.nextDouble() * 0.35 // r in [0.1, 0.45]
          : 0.6 + random.nextDouble() * 0.35; // r in [0.6, 0.95]

      final angle = random.nextDouble() * 2 * math.pi;
      // Convert to normalized coordinates in [-1, 1]
      final x1 = radius * math.cos(angle);
      final x2 = radius * math.sin(angle);

      final label = isClass0 ? 0.0 : 1.0;
      list.add(TrainingSample(inputs: [x1, x2], targets: [label]));
    }
    return list;
  }
}
