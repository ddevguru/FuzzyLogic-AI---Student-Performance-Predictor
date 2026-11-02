import 'dart:math';
import '../models/ga_config.dart';
import '../models/individual.dart';

class GASelection {
  static final Random _random = Random();

  /// Tournament Selection: randomly select k individuals and return the best one.
  static Individual<T> tournamentSelect<T>(
    List<Individual<T>> population, {
    int tournamentSize = 3,
  }) {
    List<Individual<T>> sample = [];
    for (int i = 0; i < tournamentSize; i++) {
      int idx = _random.nextInt(population.length);
      sample.add(population[idx]);
    }
    sample.sort((a, b) => b.fitness.compareTo(a.fitness));
    return sample.first;
  }

  /// Roulette Wheel Selection: probability proportional to fitness.
  static Individual<T> rouletteSelect<T>(List<Individual<T>> population) {
    double totalFitness = population.fold(0.0, (sum, ind) => sum + ind.fitness);
    if (totalFitness <= 0) {
      return population[_random.nextInt(population.length)];
    }

    double rand = _random.nextDouble() * totalFitness;
    double cumulative = 0.0;
    for (var ind in population) {
      cumulative += ind.fitness;
      if (cumulative >= rand) {
        return ind;
      }
    }
    return population.last;
  }

  static Individual<T> select<T>(
    List<Individual<T>> population,
    SelectionMethod method, {
    int tournamentSize = 3,
  }) {
    switch (method) {
      case SelectionMethod.tournament:
        return tournamentSelect(population, tournamentSize: tournamentSize);
      case SelectionMethod.rouletteWheel:
        return rouletteSelect(population);
    }
  }
}
