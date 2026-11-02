import '../models/chromosome.dart';
import '../models/individual.dart';
import '../models/problem_type.dart';

/// Base abstract class for any GA Optimization Problem.
abstract class BaseProblem<T> {
  ProblemType get problemType;
  String get name;
  String get description;
  int get chromosomeLength;

  /// Generate a random chromosome for initial population.
  Chromosome<T> generateRandomChromosome();

  /// Evaluate raw fitness of a chromosome.
  double evaluateFitness(Chromosome<T> chromosome);

  /// Decode chromosome into human-readable solution string.
  String decodeSolution(Chromosome<T> chromosome);

  /// Rank individuals in population and assign badges.
  List<Individual<T>> rankPopulation(List<Individual<T>> population) {
    List<Individual<T>> sorted = List.from(population)
      ..sort((a, b) => b.fitness.compareTo(a.fitness)); // Descending

    List<Individual<T>> ranked = [];
    for (int i = 0; i < sorted.length; i++) {
      RankBadge badge;
      if (i == 0) {
        badge = RankBadge.best;
      } else if (i < (sorted.length * 0.25).ceil()) {
        badge = RankBadge.good;
      } else if (i < (sorted.length * 0.75).ceil()) {
        badge = RankBadge.average;
      } else {
        badge = RankBadge.weak;
      }

      ranked.add(sorted[i].copyWith(
        rank: i + 1,
        rankBadge: badge,
      ));
    }
    return ranked;
  }
}
