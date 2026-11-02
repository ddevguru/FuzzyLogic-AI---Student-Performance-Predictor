import 'dart:math';
import '../../core/utils/random_provider.dart';
import '../../models/simulation_metric_point.dart';
import '../../problems/grid_environment.dart';

class GridPathSolution {
  final List<GridPoint> path;
  final int stepCount;
  final bool reachedGoal;
  final int antIndex;

  const GridPathSolution({
    required this.path,
    required this.stepCount,
    required this.reachedGoal,
    this.antIndex = 0,
  });
}

class AcoGridSolver {
  final GridEnvironment environment;
  final int antCount;
  final double alpha;
  final double beta;
  final double evaporationRate;
  final double depositStrength;
  final int? seed;

  late final Random rng;
  late List<List<double>> cellPheromone;

  int currentIteration = 0;
  GridPathSolution? globalBestPath;
  GridPathSolution? iterationBestPath;
  List<GridPathSolution> currentAntPaths = [];
  final List<SimulationMetricPoint> history = [];

  AcoGridSolver({
    required this.environment,
    this.antCount = 20,
    this.alpha = 1.0,
    this.beta = 2.0,
    this.evaporationRate = 0.15,
    this.depositStrength = 50.0,
    this.seed,
  }) {
    rng = RandomProvider.create(seed);
    reset();
  }

  void reset() {
    currentIteration = 0;
    globalBestPath = null;
    iterationBestPath = null;
    currentAntPaths.clear();
    history.clear();

    cellPheromone = List.generate(
      environment.height,
      (_) => List.filled(environment.width, 1.0),
    );
  }

  GridPathSolution constructAntPath(int antIndex) {
    final List<GridPoint> path = [environment.start];
    final Set<GridPoint> visited = {environment.start};
    final int maxSteps = environment.width * environment.height * 2;

    GridPoint current = environment.start;
    bool reached = false;

    while (path.length < maxSteps) {
      if (current == environment.goal) {
        reached = true;
        break;
      }

      final neighbors = environment.getNeighbors(current);
      // Prefer unvisited neighbors to prevent wandering in circles
      final unvisitedNeighbors = neighbors.where((p) => !visited.contains(p)).toList();
      final candidates = unvisitedNeighbors.isNotEmpty ? unvisitedNeighbors : neighbors;

      if (candidates.isEmpty) {
        // Dead end
        break;
      }

      // Compute weights
      final List<double> weights = [];
      double sumWeight = 0.0;

      for (final next in candidates) {
        final tau = cellPheromone[next.y][next.x];
        // Heuristic: inverse of Euclidean distance to goal
        final dist = next.distanceTo(environment.goal);
        final eta = 1.0 / (dist + 0.1);

        final w = pow(tau, alpha).toDouble() * pow(eta, beta).toDouble();
        weights.add(w);
        sumWeight += w;
      }

      GridPoint chosen = candidates.first;
      if (sumWeight > 0.0) {
        final double r = rng.nextDouble() * sumWeight;
        double accum = 0.0;
        for (int i = 0; i < candidates.length; i++) {
          accum += weights[i];
          if (accum >= r) {
            chosen = candidates[i];
            break;
          }
        }
      }

      path.add(chosen);
      visited.add(chosen);
      current = chosen;
    }

    return GridPathSolution(
      path: path,
      stepCount: path.length,
      reachedGoal: reached,
      antIndex: antIndex,
    );
  }

  SimulationMetricPoint stepIteration() {
    currentIteration++;
    currentAntPaths.clear();

    GridPathSolution? iterBest;
    double totalSteps = 0.0;
    int successCount = 0;

    // 1. Construct paths for all ants
    for (int k = 0; k < antCount; k++) {
      final solution = constructAntPath(k);
      currentAntPaths.add(solution);
      totalSteps += solution.stepCount;

      if (solution.reachedGoal) {
        successCount++;
        if (iterBest == null || solution.stepCount < iterBest.stepCount) {
          iterBest = solution;
        }
      }
    }

    iterationBestPath = iterBest;

    // 2. Global best path tracking
    if (iterBest != null) {
      if (globalBestPath == null || iterBest.stepCount < globalBestPath!.stepCount) {
        globalBestPath = iterBest;
      }
    }

    // 3. Evaporate pheromone
    for (int y = 0; y < environment.height; y++) {
      for (int x = 0; x < environment.width; x++) {
        cellPheromone[y][x] = (cellPheromone[y][x] * (1.0 - evaporationRate)).clamp(0.01, 100.0);
      }
    }

    // 4. Deposit pheromone for successful paths
    for (final solution in currentAntPaths) {
      if (solution.reachedGoal && solution.stepCount > 0) {
        final double deposit = depositStrength / solution.stepCount;
        for (final p in solution.path) {
          cellPheromone[p.y][p.x] = (cellPheromone[p.y][p.x] + deposit).clamp(0.01, 100.0);
        }
      }
    }

    // 5. Reinforce global best path if exists
    if (globalBestPath != null && globalBestPath!.stepCount > 0) {
      final double eliteDeposit = (2.0 * depositStrength) / globalBestPath!.stepCount;
      for (final p in globalBestPath!.path) {
        cellPheromone[p.y][p.x] = (cellPheromone[p.y][p.x] + eliteDeposit).clamp(0.01, 100.0);
      }
    }

    // 6. Metrics
    final double bestVal = (globalBestPath != null) ? globalBestPath!.stepCount.toDouble() : 999.0;
    final double avgVal = totalSteps / antCount;

    final metric = SimulationMetricPoint(
      iteration: currentIteration,
      bestObjective: bestVal,
      averageObjective: avgVal,
      extraMetric: successCount.toDouble(), // Number of ants that successfully reached goal
    );
    history.add(metric);
    return metric;
  }
}
