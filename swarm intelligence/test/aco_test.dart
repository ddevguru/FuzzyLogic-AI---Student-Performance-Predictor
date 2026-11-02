import 'package:flutter_test/flutter_test.dart';
import 'package:swarm_intelligence_lab/algorithms/aco/aco_tsp_solver.dart';
import 'package:swarm_intelligence_lab/algorithms/aco/aco_grid_solver.dart';
import 'package:swarm_intelligence_lab/algorithms/aco/pheromone_matrix.dart';
import 'package:swarm_intelligence_lab/models/city.dart';
import 'package:swarm_intelligence_lab/problems/grid_environment.dart';
import 'package:swarm_intelligence_lab/problems/tsp_cities.dart';

void main() {
  group('Ant Colony Optimization (ACO) Unit Tests', () {
    test('Pheromone Matrix - Initialization, Evaporation & Deposit', () {
      final matrix = PheromoneMatrix(size: 5, initialPheromone: 1.0);
      expect(matrix.get(0, 1), equals(1.0));
      expect(matrix.get(1, 0), equals(1.0)); // Symmetric

      // Deposit
      matrix.deposit(0, 1, 0.5);
      expect(matrix.get(0, 1), equals(1.5));
      expect(matrix.get(1, 0), equals(1.5));

      // Evaporation
      matrix.evaporate(0.2); // (1.5 * 0.8) = 1.2
      expect(matrix.get(0, 1), closeTo(1.2, 0.001));

      // Max pheromone tracking
      expect(matrix.getMaxPheromone(), greaterThanOrEqualTo(1.2));
    });

    test('ACO TSP - Valid Closed Tour Construction', () {
      final cities = TspCitiesData.defaultCities;
      final solver = AcoTspSolver(cities: cities, antCount: 10, seed: 12345);

      final route = solver.constructAntRoute(0);
      expect(route.cityIndices.length, equals(cities.length));

      // All cities must be visited exactly once
      final uniqueCities = route.cityIndices.toSet();
      expect(uniqueCities.length, equals(cities.length));
      for (int i = 0; i < cities.length; i++) {
        expect(uniqueCities.contains(i), isTrue);
      }

      // Distance must be strictly positive
      expect(route.totalDistance, greaterThan(0.0));
    });

    test('ACO TSP - Accurate Tour Distance Calculation', () {
      const testCities = [
        City(id: 0, name: 'A', x: 0, y: 0, latitude: 0, longitude: 0),
        City(id: 1, name: 'B', x: 1, y: 0, latitude: 0, longitude: 1),
      ];
      final distMatrix = TspCitiesData.computeDistanceMatrix(testCities);
      expect(distMatrix[0][1], greaterThan(100.0)); // Geographical km
      expect(distMatrix[0][0], equals(0.0));
    });

    test('ACO TSP - Iteration Step & Best Route Tracking', () {
      final solver = AcoTspSolver(
        cities: TspCitiesData.defaultCities,
        antCount: 12,
        seed: 42,
      );

      expect(solver.globalBestRoute, isNull);
      final metric1 = solver.stepIteration();

      expect(solver.currentIteration, equals(1));
      expect(solver.globalBestRoute, isNotNull);
      expect(solver.currentAntRoutes.length, equals(12));
      expect(metric1.bestObjective, equals(solver.globalBestRoute!.totalDistance));
      expect(metric1.averageObjective, greaterThanOrEqualTo(metric1.bestObjective));

      // Subsequent iteration maintains or improves global best
      final bestDistBefore = solver.globalBestRoute!.totalDistance;
      for (int i = 0; i < 5; i++) {
        solver.stepIteration();
      }
      expect(solver.globalBestRoute!.totalDistance, lessThanOrEqualTo(bestDistBefore));
    });

    test('ACO Grid Pathfinding - Feasible Path Discovery & Obstacle Avoidance', () {
      final env = GridEnvironment(width: 10, height: 10);
      // Ensure path exists
      final solver = AcoGridSolver(
        environment: env,
        antCount: 15,
        seed: 777,
      );

      final metric = solver.stepIteration();
      expect(solver.currentIteration, equals(1));
      expect(metric.iteration, equals(1));
      expect(solver.currentAntPaths.length, equals(15));

      // Check if ant paths respect boundary and obstacles
      for (final sol in solver.currentAntPaths) {
        for (final pt in sol.path) {
          expect(pt.x, greaterThanOrEqualTo(0));
          expect(pt.x, lessThan(env.width));
          expect(pt.y, greaterThanOrEqualTo(0));
          expect(pt.y, lessThan(env.height));
          expect(env.isPassable(pt.x, pt.y), isTrue);
        }
      }
    });
  });
}
