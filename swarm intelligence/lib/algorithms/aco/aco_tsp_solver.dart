import 'dart:math';
import '../../core/utils/random_provider.dart';
import '../../models/city.dart';
import '../../models/route_solution.dart';
import '../../models/simulation_metric_point.dart';
import '../../problems/tsp_cities.dart';
import 'pheromone_matrix.dart';

class AcoTspSolver {
  final List<City> cities;
  late final List<List<double>> distanceMatrix;
  final int antCount;
  final double alpha; // pheromone weight
  final double beta; // heuristic weight
  final double evaporationRate; // rho
  final double depositStrength; // Q
  final int? seed;

  late final Random rng;
  late final PheromoneMatrix pheromoneMatrix;

  int currentIteration = 0;
  RouteSolution? globalBestRoute;
  RouteSolution? iterationBestRoute;
  List<RouteSolution> currentAntRoutes = [];
  final List<SimulationMetricPoint> history = [];

  AcoTspSolver({
    List<City>? cities,
    this.antCount = 15,
    this.alpha = 1.0,
    this.beta = 2.5,
    this.evaporationRate = 0.1,
    this.depositStrength = 100.0,
    this.seed,
  }) : cities = cities ?? TspCitiesData.defaultCities {
    distanceMatrix = TspCitiesData.computeDistanceMatrix(this.cities);
    rng = RandomProvider.create(seed);
    pheromoneMatrix = PheromoneMatrix(size: this.cities.length, initialPheromone: 1.0);
    reset();
  }

  void reset() {
    currentIteration = 0;
    globalBestRoute = null;
    iterationBestRoute = null;
    currentAntRoutes = [];
    history.clear();
    pheromoneMatrix.reset();
  }

  /// Calculates total tour distance for a list of city indices (including loop back to start)
  double calculateTourDistance(List<int> tour) {
    if (tour.length < 2) return 0.0;
    double dist = 0.0;
    for (int i = 0; i < tour.length - 1; i++) {
      dist += distanceMatrix[tour[i]][tour[i + 1]];
    }
    // Return to starting city to complete closed loop
    dist += distanceMatrix[tour.last][tour.first];
    return dist;
  }

  /// Constructs a single ant's route using probabilistic state transition rule
  RouteSolution constructAntRoute(int antIndex) {
    final int n = cities.length;
    final List<int> tour = [];
    final Set<int> visited = {};

    // Start ant at a random city or antIndex % n
    final int startCity = rng.nextInt(n);
    tour.add(startCity);
    visited.add(startCity);

    while (tour.length < n) {
      final int currentCity = tour.last;
      final List<int> candidates = [];
      final List<double> probabilities = [];
      double sumProb = 0.0;

      for (int nextCity = 0; nextCity < n; nextCity++) {
        if (!visited.contains(nextCity)) {
          candidates.add(nextCity);
          final double tau = pheromoneMatrix.get(currentCity, nextCity);
          final double d = distanceMatrix[currentCity][nextCity];
          final double eta = d > 0 ? 1.0 / d : 1.0;

          final double weight = pow(tau, alpha).toDouble() * pow(eta, beta).toDouble();
          probabilities.add(weight);
          sumProb += weight;
        }
      }

      int chosenCity;
      if (sumProb <= 0.0 || candidates.isEmpty) {
        // Fallback: pick any unvisited city
        chosenCity = candidates.first;
      } else {
        // Roulette wheel selection
        final double r = rng.nextDouble() * sumProb;
        double accum = 0.0;
        chosenCity = candidates.last;
        for (int i = 0; i < candidates.length; i++) {
          accum += probabilities[i];
          if (accum >= r) {
            chosenCity = candidates[i];
            break;
          }
        }
      }

      tour.add(chosenCity);
      visited.add(chosenCity);
    }

    final double totalDistance = calculateTourDistance(tour);
    return RouteSolution(
      cityIndices: tour,
      totalDistance: totalDistance,
      antIndex: antIndex,
    );
  }

  /// Executes one full ACO iteration
  SimulationMetricPoint stepIteration() {
    currentIteration++;
    currentAntRoutes.clear();

    double totalDist = 0.0;
    RouteSolution? iterBest;

    // 1. Construct all ant routes
    for (int k = 0; k < antCount; k++) {
      final route = constructAntRoute(k);
      currentAntRoutes.add(route);
      totalDist += route.totalDistance;

      if (iterBest == null || route.totalDistance < iterBest.totalDistance) {
        iterBest = route;
      }
    }

    iterationBestRoute = iterBest;

    // 2. Update global best route
    if (iterBest != null) {
      if (globalBestRoute == null || iterBest.totalDistance < globalBestRoute!.totalDistance) {
        globalBestRoute = iterBest.copyWith();
      }
    }

    // 3. Evaporate pheromone
    pheromoneMatrix.evaporate(evaporationRate);

    // 4. Deposit pheromone
    // For each ant, deposit Q / L_k along its traversed edges
    for (final route in currentAntRoutes) {
      final double delta = depositStrength / route.totalDistance;
      final tour = route.cityIndices;
      for (int i = 0; i < tour.length - 1; i++) {
        pheromoneMatrix.deposit(tour[i], tour[i + 1], delta);
      }
      pheromoneMatrix.deposit(tour.last, tour.first, delta);
    }

    // Elitist pheromone reinforcement for global best
    if (globalBestRoute != null) {
      final double eliteDelta = (2.0 * depositStrength) / globalBestRoute!.totalDistance;
      final tour = globalBestRoute!.cityIndices;
      for (int i = 0; i < tour.length - 1; i++) {
        pheromoneMatrix.deposit(tour[i], tour[i + 1], eliteDelta);
      }
      pheromoneMatrix.deposit(tour.last, tour.first, eliteDelta);
    }

    // 5. Record metrics
    final double avgDist = totalDist / antCount;
    final metric = SimulationMetricPoint(
      iteration: currentIteration,
      bestObjective: globalBestRoute?.totalDistance ?? 0.0,
      averageObjective: avgDist,
      extraMetric: pheromoneMatrix.getMaxPheromone(),
    );
    history.add(metric);
    return metric;
  }
}
