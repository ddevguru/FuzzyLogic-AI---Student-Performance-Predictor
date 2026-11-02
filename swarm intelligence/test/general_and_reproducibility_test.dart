import 'package:flutter_test/flutter_test.dart';
import 'package:swarm_intelligence_lab/algorithms/aco/aco_tsp_solver.dart';
import 'package:swarm_intelligence_lab/algorithms/pso/pso_solver.dart';
import 'package:swarm_intelligence_lab/algorithms/abc/abc_solver.dart';
import 'package:swarm_intelligence_lab/models/benchmark_function.dart';
import 'package:swarm_intelligence_lab/problems/tsp_cities.dart';

void main() {
  group('Reproducibility & General Stability Tests', () {
    test('PSO - Deterministic Random Seed Reproducibility', () {
      final psoA = PsoSolver(
        benchmark: BenchmarkType.sphere,
        particleCount: 20,
        seed: 42,
      );

      final psoB = PsoSolver(
        benchmark: BenchmarkType.sphere,
        particleCount: 20,
        seed: 42,
      );

      // Initial positions must match exactly
      for (int i = 0; i < 20; i++) {
        expect(psoA.particles[i].position[0], equals(psoB.particles[i].position[0]));
        expect(psoA.particles[i].position[1], equals(psoB.particles[i].position[1]));
      }

      // Step 10 iterations on both
      for (int step = 0; step < 10; step++) {
        psoA.stepIteration();
        psoB.stepIteration();
      }

      // Final states must match exactly
      expect(psoA.globalBestFitness, equals(psoB.globalBestFitness));
      expect(psoA.globalBestPosition[0], equals(psoB.globalBestPosition[0]));
      expect(psoA.globalBestPosition[1], equals(psoB.globalBestPosition[1]));
    });

    test('ACO TSP - Deterministic Random Seed Reproducibility', () {
      final acoA = AcoTspSolver(
        cities: TspCitiesData.defaultCities,
        antCount: 15,
        seed: 12345,
      );

      final acoB = AcoTspSolver(
        cities: TspCitiesData.defaultCities,
        antCount: 15,
        seed: 12345,
      );

      for (int i = 0; i < 5; i++) {
        acoA.stepIteration();
        acoB.stepIteration();
      }

      expect(acoA.globalBestRoute?.totalDistance, equals(acoB.globalBestRoute?.totalDistance));
      expect(acoA.globalBestRoute?.cityIndices, equals(acoB.globalBestRoute?.cityIndices));
    });

    test('ABC - Deterministic Random Seed Reproducibility', () {
      final abcA = AbcSolver(
        benchmark: BenchmarkType.sphere,
        foodSourceCount: 15,
        seed: 888,
      );

      final abcB = AbcSolver(
        benchmark: BenchmarkType.sphere,
        foodSourceCount: 15,
        seed: 888,
      );

      for (int i = 0; i < 10; i++) {
        abcA.stepIteration();
        abcB.stepIteration();
      }

      expect(abcA.bestFoodSource?.objectiveValue, equals(abcB.bestFoodSource?.objectiveValue));
      expect(abcA.bestFoodSource?.position[0], equals(abcB.bestFoodSource?.position[0]));
      expect(abcA.bestFoodSource?.position[1], equals(abcB.bestFoodSource?.position[1]));
    });

    test('Safety on Extreme Benchmark Coordinates (NaN & Infinity guard)', () {
      final valSphere = BenchmarkType.sphere.evaluate([0.0, 0.0]);
      expect(valSphere.isNaN, isFalse);
      expect(valSphere.isInfinite, isFalse);

      final valRastrigin = BenchmarkType.rastrigin.evaluate([-5.12, 5.12]);
      expect(valRastrigin.isNaN, isFalse);
      expect(valRastrigin.isInfinite, isFalse);

      final valRosenbrock = BenchmarkType.rosenbrock.evaluate([-2.048, 2.048]);
      expect(valRosenbrock.isNaN, isFalse);
      expect(valRosenbrock.isInfinite, isFalse);
    });
  });
}
