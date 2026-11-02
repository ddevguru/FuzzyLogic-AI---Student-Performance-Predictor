import 'algorithm_type.dart';

class PresentationStep {
  final int stepNumber;
  final String title;
  final String description;
  final String mathematicalFormula;
  final String whatIsHappeningInApp;
  final AlgorithmType algorithm;

  const PresentationStep({
    required this.stepNumber,
    required this.title,
    required this.description,
    required this.mathematicalFormula,
    required this.whatIsHappeningInApp,
    required this.algorithm,
  });
}
