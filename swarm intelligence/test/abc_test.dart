import 'package:flutter_test/flutter_test.dart';
import 'package:swarm_intelligence_lab/algorithms/abc/abc_solver.dart';
import 'package:swarm_intelligence_lab/models/benchmark_function.dart';
import 'package:swarm_intelligence_lab/models/food_source_state.dart';

void main() {
  group('Artificial Bee Colony (ABC) Unit Tests', () {
    test('ABC - Food Source Fitness Metric Transformation', () {
      // f(x) >= 0 -> fit = 1 / (1 + f(x))
      expect(FoodSourceState.computeFitness(0.0), closeTo(1.0, 0.0001));
      expect(FoodSourceState.computeFitness(1.0), closeTo(0.5, 0.0001));
      expect(FoodSourceState.computeFitness(9.0), closeTo(0.1, 0.0001));

      // f(x) < 0 -> fit = 1 + |f(x)|
      expect(FoodSourceState.computeFitness(-5.0), closeTo(6.0, 0.0001));
    });

    test('ABC - Food Source Initialization & Bounds', () {
      final abc = AbcSolver(
        benchmark: BenchmarkType.sphere,
        foodSourceCount: 15,
        abandonmentLimit: 20,
        seed: 42,
      );

      expect(abc.foodSources.length, equals(15));
      expect(abc.bestFoodSource, isNotNull);
      expect(abc.currentIteration, equals(0));

      for (final s in abc.foodSources) {
        expect(s.position[0], greaterThanOrEqualTo(abc.minBound));
        expect(s.position[0], lessThanOrEqualTo(abc.maxBound));
        expect(s.position[1], greaterThanOrEqualTo(abc.minBound));
        expect(s.position[1], lessThanOrEqualTo(abc.maxBound));
        expect(s.trial, equals(0));
      }
    });

    test('ABC - Iteration Execution & Greedy Replacement', () {
      final abc = AbcSolver(
        benchmark: BenchmarkType.sphere,
        foodSourceCount: 15,
        abandonmentLimit: 25,
        seed: 100,
      );

      final initialBest = abc.bestFoodSource!.objectiveValue;
      final metric = abc.stepIteration();

      expect(abc.currentIteration, equals(1));
      expect(metric.iteration, equals(1));
      // Best food source objective should not get worse
      expect(abc.bestFoodSource!.objectiveValue, lessThanOrEqualTo(initialBest));
    });

    test('ABC - Scout Bee Phase & Abandonment Replacement', () {
      final abc = AbcSolver(
        benchmark: BenchmarkType.sphere,
        foodSourceCount: 10,
        abandonmentLimit: 3, // Low limit to force quick scout replacements
        seed: 42,
      );

      // Force high trial counts on all food sources
      for (final s in abc.foodSources) {
        s.trial = 10;
      }

      abc.stepIteration();

      // Scout bee replacements should have triggered
      expect(abc.totalScoutReplacements, greaterThan(0));
    });

    test('ABC - Multi-Iteration Convergence on Sphere Function', () {
      final abc = AbcSolver(
        benchmark: BenchmarkType.sphere,
        foodSourceCount: 20,
        onlookerBeeCount: 20,
        abandonmentLimit: 30,
        seed: 42,
      );

      final startObjective = abc.bestFoodSource!.objectiveValue;
      for (int i = 0; i < 40; i++) {
        abc.stepIteration();
      }

      expect(abc.bestFoodSource!.objectiveValue, lessThan(startObjective));
      expect(abc.bestFoodSource!.objectiveValue, lessThan(1.0));
    });
  });
}
