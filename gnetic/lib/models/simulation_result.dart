import 'generation.dart';
import 'individual.dart';

class SimulationResult<T> {
  final List<Generation<T>> generations;
  final Individual<T> initialBest;
  final Individual<T> finalBest;
  final int totalGenerationsExecuted;
  final Duration executionTime;
  final String problemName;

  const SimulationResult({
    required this.generations,
    required this.initialBest,
    required this.finalBest,
    required this.totalGenerationsExecuted,
    required this.executionTime,
    required this.problemName,
  });

  double get initialFitness => initialBest.fitness;
  double get finalFitness => finalBest.fitness;

  double get percentageImprovement {
    if (initialFitness == 0) return 0.0;
    return ((finalFitness - initialFitness) / initialFitness) * 100;
  }
}
