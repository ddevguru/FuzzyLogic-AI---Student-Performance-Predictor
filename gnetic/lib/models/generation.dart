import 'individual.dart';

/// Represents a single Generation snapshot during GA execution.
class Generation<T> {
  final int generationNumber;
  final List<Individual<T>> population;
  final Individual<T> bestIndividual;
  final double averageFitness;
  final double worstFitness;
  final double diversity;

  const Generation({
    required this.generationNumber,
    required this.population,
    required this.bestIndividual,
    required this.averageFitness,
    required this.worstFitness,
    required this.diversity,
  });
}
