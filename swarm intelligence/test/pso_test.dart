import 'package:flutter_test/flutter_test.dart';
import 'package:swarm_intelligence_lab/algorithms/pso/pso_solver.dart';
import 'package:swarm_intelligence_lab/models/benchmark_function.dart';

void main() {
  group('Particle Swarm Optimization (PSO) Unit Tests', () {
    test('Benchmark Functions - Mathematical Evaluation Accuracy', () {
      // Sphere: f(0, 0) = 0
      expect(BenchmarkType.sphere.evaluate([0.0, 0.0]), closeTo(0.0, 0.0001));
      expect(BenchmarkType.sphere.evaluate([1.0, 2.0]), closeTo(5.0, 0.0001));

      // Rastrigin: f(0, 0) = 0
      expect(BenchmarkType.rastrigin.evaluate([0.0, 0.0]), closeTo(0.0, 0.0001));
      expect(BenchmarkType.rastrigin.evaluate([1.0, 1.0]), closeTo(2.0, 0.0001));

      // Rosenbrock: f(1, 1) = 0
      expect(BenchmarkType.rosenbrock.evaluate([1.0, 1.0]), closeTo(0.0, 0.0001));
      expect(BenchmarkType.rosenbrock.evaluate([0.0, 0.0]), closeTo(1.0, 0.0001));
    });

    test('PSO - Swarm Initialization & Bounds Compliance', () {
      final pso = PsoSolver(
        benchmark: BenchmarkType.sphere,
        particleCount: 20,
        seed: 42,
      );

      expect(pso.particles.length, equals(20));
      expect(pso.currentIteration, equals(0));
      expect(pso.globalBestFitness.isFinite, isTrue);

      for (final p in pso.particles) {
        expect(p.position[0], greaterThanOrEqualTo(pso.minBound));
        expect(p.position[0], lessThanOrEqualTo(pso.maxBound));
        expect(p.position[1], greaterThanOrEqualTo(pso.minBound));
        expect(p.position[1], lessThanOrEqualTo(pso.maxBound));
        expect(p.personalBestFitness, equals(p.currentFitness));
      }
    });

    test('PSO - Velocity and Position Iteration Updates', () {
      final pso = PsoSolver(
        benchmark: BenchmarkType.sphere,
        particleCount: 20,
        seed: 999,
      );

      final initialPos = List<double>.from(pso.particles.first.position);
      final initialBest = pso.globalBestFitness;

      final metric = pso.stepIteration();
      expect(pso.currentIteration, equals(1));
      expect(metric.iteration, equals(1));

      // Particle position must have changed
      final newPos = pso.particles.first.position;
      final moved = (initialPos[0] != newPos[0]) || (initialPos[1] != newPos[1]);
      expect(moved, isTrue);

      // Global best fitness must either improve or remain identical (never worsen)
      expect(pso.globalBestFitness, lessThanOrEqualTo(initialBest));
    });

    test('PSO - Convergence on Sphere Benchmark Function', () {
      final pso = PsoSolver(
        benchmark: BenchmarkType.sphere,
        particleCount: 30,
        inertiaWeight: 0.729,
        cognitiveWeight: 1.494,
        socialWeight: 1.494,
        seed: 42,
      );

      final startFitness = pso.globalBestFitness;
      for (int i = 0; i < 40; i++) {
        pso.stepIteration();
      }

      // After 40 iterations on Sphere, fitness should have improved significantly
      expect(pso.globalBestFitness, lessThan(startFitness));
      expect(pso.globalBestFitness, lessThan(0.5));
    });

    test('PSO - Swarm Dispersion Metric', () {
      final pso = PsoSolver(
        benchmark: BenchmarkType.sphere,
        particleCount: 25,
        seed: 42,
      );

      final initialDispersion = pso.calculateSwarmDispersion();
      expect(initialDispersion, greaterThan(0.0));

      for (int i = 0; i < 30; i++) {
        pso.stepIteration();
      }

      final finalDispersion = pso.calculateSwarmDispersion();
      // Particles converge toward gbest, so dispersion decreases
      expect(finalDispersion, lessThan(initialDispersion));
    });
  });
}
