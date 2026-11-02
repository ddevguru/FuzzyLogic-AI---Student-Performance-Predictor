class SimulationMetricPoint {
  final int iteration;
  final double bestObjective;
  final double averageObjective;
  final double extraMetric; // e.g. Max Pheromone for ACO, Swarm Dispersion for PSO, Scout Count for ABC

  const SimulationMetricPoint({
    required this.iteration,
    required this.bestObjective,
    required this.averageObjective,
    this.extraMetric = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      'iteration': iteration,
      'bestObjective': bestObjective,
      'averageObjective': averageObjective,
      'extraMetric': extraMetric,
    };
  }
}
