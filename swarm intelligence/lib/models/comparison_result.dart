import 'algorithm_type.dart';
import 'simulation_metric_point.dart';

class ComparisonResult {
  final AlgorithmType algorithm;
  final String configurationName;
  final String problemName;
  final int iterations;
  final int evaluationCount;
  final int durationMs;
  final double bestObjective;
  final double finalAverageObjective;
  final List<SimulationMetricPoint> convergenceHistory;
  final String solutionDescription;
  final Map<String, dynamic> parameters;

  const ComparisonResult({
    required this.algorithm,
    required this.configurationName,
    required this.problemName,
    required this.iterations,
    required this.evaluationCount,
    required this.durationMs,
    required this.bestObjective,
    required this.finalAverageObjective,
    required this.convergenceHistory,
    required this.solutionDescription,
    required this.parameters,
  });
}
