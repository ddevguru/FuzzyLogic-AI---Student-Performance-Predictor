import 'dart:math';
import '../../core/utils/random_provider.dart';
import '../../models/benchmark_function.dart';
import '../../models/food_source_state.dart';
import '../../models/simulation_metric_point.dart';

class AbcSolver {
  final BenchmarkType benchmark;
  final int foodSourceCount; // SN (number of food sources = number of employed bees)
  final int onlookerBeeCount;
  final int abandonmentLimit; // trial limit
  final double minBound;
  final double maxBound;
  final int? seed;

  late final Random rng;

  int currentIteration = 0;
  List<FoodSourceState> foodSources = [];
  FoodSourceState? bestFoodSource;
  int totalScoutReplacements = 0;
  int iterationScoutReplacements = 0;
  final List<SimulationMetricPoint> history = [];

  AbcSolver({
    this.benchmark = BenchmarkType.sphere,
    this.foodSourceCount = 20,
    int? onlookerBeeCount,
    int? abandonmentLimit,
    double? minBound,
    double? maxBound,
    this.seed,
  })  : onlookerBeeCount = onlookerBeeCount ?? foodSourceCount,
        abandonmentLimit = abandonmentLimit ?? (foodSourceCount * 2),
        minBound = minBound ?? benchmark.minBound,
        maxBound = maxBound ?? benchmark.maxBound {
    rng = RandomProvider.create(seed);
    initializeFoodSources();
  }

  void initializeFoodSources() {
    currentIteration = 0;
    foodSources.clear();
    history.clear();
    bestFoodSource = null;
    totalScoutReplacements = 0;
    iterationScoutReplacements = 0;

    for (int i = 0; i < foodSourceCount; i++) {
      final posX = RandomProvider.nextDouble(rng, minBound, maxBound);
      final posY = RandomProvider.nextDouble(rng, minBound, maxBound);
      final pos = [posX, posY];

      final obj = benchmark.evaluate(pos);
      final fit = FoodSourceState.computeFitness(obj);

      final source = FoodSourceState(
        id: i,
        position: pos,
        objectiveValue: obj,
        fitness: fit,
        trial: 0,
      );

      foodSources.add(source);

      if (bestFoodSource == null || obj < bestFoodSource!.objectiveValue) {
        bestFoodSource = source.clone();
      }
    }
  }

  void reset() {
    initializeFoodSources();
  }

  /// 1. Employed Bee Phase
  void _employedBeePhase() {
    for (int i = 0; i < foodSources.length; i++) {
      final source = foodSources[i];

      // Pick a random neighbor k != i
      int k = rng.nextInt(foodSources.length);
      while (k == i && foodSources.length > 1) {
        k = rng.nextInt(foodSources.length);
      }
      final neighbor = foodSources[k];

      // Pick random dimension (0 or 1)
      final int paramIndex = rng.nextInt(2);

      // phi in [-1, 1]
      final double phi = RandomProvider.nextDouble(rng, -1.0, 1.0);

      // v_ij = x_ij + phi * (x_ij - x_kj)
      final List<double> candidatePos = List<double>.from(source.position);
      final double newVal = source.position[paramIndex] + phi * (source.position[paramIndex] - neighbor.position[paramIndex]);
      candidatePos[paramIndex] = newVal.clamp(minBound, maxBound);

      final double candidateObj = benchmark.evaluate(candidatePos);
      final double candidateFit = FoodSourceState.computeFitness(candidateObj);

      // Greedy selection (for minimization, smaller objective is better)
      if (candidateObj < source.objectiveValue) {
        source.position = candidatePos;
        source.objectiveValue = candidateObj;
        source.fitness = candidateFit;
        source.trial = 0;

        if (bestFoodSource == null || candidateObj < bestFoodSource!.objectiveValue) {
          bestFoodSource = source.clone();
        }
      } else {
        source.trial++;
      }
    }
  }

  /// 2. Onlooker Bee Phase
  void _onlookerBeePhase() {
    // Calculate selection probabilities: P_i = fit_i / sum(fit)
    double totalFitness = 0.0;
    for (final s in foodSources) {
      totalFitness += s.fitness;
    }

    if (totalFitness <= 0.0) return;

    final List<double> probabilities = foodSources.map((s) => s.fitness / totalFitness).toList();

    for (int bee = 0; bee < onlookerBeeCount; bee++) {
      // Roulette wheel selection
      final double r = rng.nextDouble();
      double accum = 0.0;
      int selectedIdx = 0;

      for (int i = 0; i < foodSources.length; i++) {
        accum += probabilities[i];
        if (accum >= r) {
          selectedIdx = i;
          break;
        }
      }

      final source = foodSources[selectedIdx];

      // Pick neighbor k != selectedIdx
      int k = rng.nextInt(foodSources.length);
      while (k == selectedIdx && foodSources.length > 1) {
        k = rng.nextInt(foodSources.length);
      }
      final neighbor = foodSources[k];

      final int paramIndex = rng.nextInt(2);
      final double phi = RandomProvider.nextDouble(rng, -1.0, 1.0);

      final List<double> candidatePos = List<double>.from(source.position);
      final double newVal = source.position[paramIndex] + phi * (source.position[paramIndex] - neighbor.position[paramIndex]);
      candidatePos[paramIndex] = newVal.clamp(minBound, maxBound);

      final double candidateObj = benchmark.evaluate(candidatePos);
      final double candidateFit = FoodSourceState.computeFitness(candidateObj);

      // Greedy selection
      if (candidateObj < source.objectiveValue) {
        source.position = candidatePos;
        source.objectiveValue = candidateObj;
        source.fitness = candidateFit;
        source.trial = 0;

        if (bestFoodSource == null || candidateObj < bestFoodSource!.objectiveValue) {
          bestFoodSource = source.clone();
        }
      } else {
        source.trial++;
      }
    }
  }

  /// 3. Scout Bee Phase
  void _scoutBeePhase() {
    iterationScoutReplacements = 0;
    for (int i = 0; i < foodSources.length; i++) {
      if (foodSources[i].trial >= abandonmentLimit) {
        // Abandoned source: replace with newly generated food source
        final posX = RandomProvider.nextDouble(rng, minBound, maxBound);
        final posY = RandomProvider.nextDouble(rng, minBound, maxBound);
        final pos = [posX, posY];

        final obj = benchmark.evaluate(pos);
        final fit = FoodSourceState.computeFitness(obj);

        foodSources[i].position = pos;
        foodSources[i].objectiveValue = obj;
        foodSources[i].fitness = fit;
        foodSources[i].trial = 0;

        iterationScoutReplacements++;
        totalScoutReplacements++;

        if (bestFoodSource == null || obj < bestFoodSource!.objectiveValue) {
          bestFoodSource = foodSources[i].clone();
        }
      }
    }
  }

  /// Executes one full iteration of ABC
  SimulationMetricPoint stepIteration() {
    currentIteration++;

    // 1. Employed bee phase
    _employedBeePhase();

    // 2. Onlooker bee phase
    _onlookerBeePhase();

    // 3. Scout bee phase
    _scoutBeePhase();

    // 4. Calculate metrics
    double sumObj = 0.0;
    for (final s in foodSources) {
      sumObj += s.objectiveValue;
    }
    final double avgObj = sumObj / foodSources.length;

    final metric = SimulationMetricPoint(
      iteration: currentIteration,
      bestObjective: bestFoodSource?.objectiveValue ?? 0.0,
      averageObjective: avgObj,
      extraMetric: iterationScoutReplacements.toDouble(),
    );

    history.add(metric);
    return metric;
  }
}
