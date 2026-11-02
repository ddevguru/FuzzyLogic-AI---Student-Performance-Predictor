import 'dataset_base.dart';
import '../models/training_sample.dart';

class XorDataset extends AppDataset {
  XorDataset()
      : super(
          name: 'XOR Logic Gate',
          description:
              'Exclusive OR problem. Non-linearly separable benchmark problem demonstrating the necessity of hidden layers in ANNs.',
          type: DatasetType.xor,
          isClassification: true,
          featureNames: ['Input A', 'Input B'],
          targetNames: ['XOR Output'],
        );

  @override
  List<TrainingSample> get trainSamples => [
        TrainingSample(inputs: [0.0, 0.0], targets: [0.0]),
        TrainingSample(inputs: [0.0, 1.0], targets: [1.0]),
        TrainingSample(inputs: [1.0, 0.0], targets: [1.0]),
        TrainingSample(inputs: [1.0, 1.0], targets: [0.0]),
      ];

  @override
  List<TrainingSample>? get valSamples => null;
}
