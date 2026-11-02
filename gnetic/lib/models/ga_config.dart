enum SelectionMethod { tournament, rouletteWheel }
enum CrossoverMethod { singlePoint, uniform, ordered }
enum MutationMethod { bitFlip, swap, inversion }

class GAConfig {
  final int populationSize;
  final int maxGenerations;
  final double mutationRate;
  final double crossoverRate;
  final bool elitism;
  final int elitismCount;
  final SelectionMethod selectionMethod;
  final int tournamentSize;

  const GAConfig({
    this.populationSize = 50,
    this.maxGenerations = 50,
    this.mutationRate = 0.05,
    this.crossoverRate = 0.85,
    this.elitism = true,
    this.elitismCount = 2,
    this.selectionMethod = SelectionMethod.tournament,
    this.tournamentSize = 3,
  });

  GAConfig copyWith({
    int? populationSize,
    int? maxGenerations,
    double? mutationRate,
    double? crossoverRate,
    bool? elitism,
    int? elitismCount,
    SelectionMethod? selectionMethod,
    int? tournamentSize,
  }) {
    return GAConfig(
      populationSize: populationSize ?? this.populationSize,
      maxGenerations: maxGenerations ?? this.maxGenerations,
      mutationRate: mutationRate ?? this.mutationRate,
      crossoverRate: crossoverRate ?? this.crossoverRate,
      elitism: elitism ?? this.elitism,
      elitismCount: elitismCount ?? this.elitismCount,
      selectionMethod: selectionMethod ?? this.selectionMethod,
      tournamentSize: tournamentSize ?? this.tournamentSize,
    );
  }
}
