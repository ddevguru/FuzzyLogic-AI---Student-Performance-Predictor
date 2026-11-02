class EpochMetric {
  final int epoch;
  final double trainLoss;
  final double? valLoss;
  final double trainAccuracy;
  final double? valAccuracy;

  EpochMetric({
    required this.epoch,
    required this.trainLoss,
    this.valLoss,
    required this.trainAccuracy,
    this.valAccuracy,
  });
}

class TrainingResult {
  final int totalEpochs;
  final List<EpochMetric> epochMetrics;
  final double finalLoss;
  final double? finalValLoss;
  final double finalAccuracy;
  final double? finalValAccuracy;
  final Duration trainingDuration;
  final String datasetName;
  final String architectureSummary;

  TrainingResult({
    required this.totalEpochs,
    required this.epochMetrics,
    required this.finalLoss,
    this.finalValLoss,
    required this.finalAccuracy,
    this.finalValAccuracy,
    required this.trainingDuration,
    required this.datasetName,
    required this.architectureSummary,
  });

  List<double> get trainLosses => epochMetrics.map((e) => e.trainLoss).toList();
  List<double> get valLosses => epochMetrics.map((e) => e.valLoss ?? 0.0).toList();
  List<double> get trainAccuracies => epochMetrics.map((e) => e.trainAccuracy).toList();
  List<double> get valAccuracies => epochMetrics.map((e) => e.valAccuracy ?? 0.0).toList();
}
