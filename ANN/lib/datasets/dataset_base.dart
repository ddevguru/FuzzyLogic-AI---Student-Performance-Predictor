import '../models/training_sample.dart';

enum DatasetType {
  xor,
  binaryClassification,
  functionRegression,
}

abstract class AppDataset {
  final String name;
  final String description;
  final DatasetType type;
  final bool isClassification;
  final List<String> featureNames;
  final List<String> targetNames;

  AppDataset({
    required this.name,
    required this.description,
    required this.type,
    required this.isClassification,
    required this.featureNames,
    required this.targetNames,
  });

  List<TrainingSample> get trainSamples;
  List<TrainingSample>? get valSamples;
}
