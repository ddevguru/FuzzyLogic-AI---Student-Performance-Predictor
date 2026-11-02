class PredictionResult {
  final List<double> inputs;
  final List<double> outputs;
  final int predictedClass;
  final double confidence; // Probability score if classification, or score
  final String label;
  final bool isClassification;

  PredictionResult({
    required this.inputs,
    required this.outputs,
    required this.predictedClass,
    required this.confidence,
    required this.label,
    required this.isClassification,
  });
}
