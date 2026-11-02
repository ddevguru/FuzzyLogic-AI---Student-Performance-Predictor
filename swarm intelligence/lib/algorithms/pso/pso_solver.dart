import 'dart:math';
import '../../core/utils/random_provider.dart';
import '../../models/benchmark_function.dart';
import '../../models/particle_state.dart';
import '../../models/simulation_metric_point.dart';

class PsoSolver {
  final BenchmarkType benchmark;
  final int particleCount;
  final double inertiaWeight; // w
  final double cognitiveWeight; // c1
  final double socialWeight; // c2
  final double minBound;
  final double maxBound;
  final int? seed;

  late final Random rng;
  late final double maxVelocity;

  int currentIteration = 0;
  List<ParticleState> particles = [];
  List<double> globalBestPosition = [0.0, 0.0];
  double globalBestFitness = double.infinity;
  final List<SimulationMetricPoint> history = [];

  PsoSolver({
    this.benchmark = BenchmarkType.sphere,
    this.particleCount = 30,
    this.inertiaWeight = 0.729,
    this.cognitiveWeight = 1.494,
    this.socialWeight = 1.494,
    double? minBound,
    double? maxBound,
    this.seed,
  })  : minBound = minBound ?? benchmark.minBound,
        maxBound = maxBound ?? benchmark.maxBound {
    rng = RandomProvider.create(seed);
    maxVelocity = 0.2 * (this.maxBound - this.minBound);
    initializeSwarm();
  }

  void initializeSwarm() {
    currentIteration = 0;
    particles.clear();
    history.clear();
    globalBestFitness = double.infinity;

    for (int i = 0; i < particleCount; i++) {
      // Random position within search bounds
      final posX = RandomProvider.nextDouble(rng, minBound, maxBound);
      final posY = RandomProvider.nextDouble(rng, minBound, maxBound);
      final pos = [posX, posY];

      // Initial small velocity
      final velX = RandomProvider.nextDouble(rng, -maxVelocity * 0.5, maxVelocity * 0.5);
      final velY = RandomProvider.nextDouble(rng, -maxVelocity * 0.5, maxVelocity * 0.5);
      final vel = [velX, velY];

      final fitness = benchmark.evaluate(pos);

      final particle = ParticleState(
        id: i,
        position: pos,
        velocity: vel,
        personalBestPosition: List<double>.from(pos),
        personalBestFitness: fitness,
        currentFitness: fitness,
      );

      particles.add(particle);

      if (fitness < globalBestFitness) {
        globalBestFitness = fitness;
        globalBestPosition = List<double>.from(pos);
      }
    }
  }

  void reset() {
    initializeSwarm();
  }

  /// Calculates the average distance of all particles from the global best position (swarm dispersion)
  double calculateSwarmDispersion() {
    if (particles.isEmpty) return 0.0;
    double sumDist = 0.0;
    for (final p in particles) {
      final dx = p.position[0] - globalBestPosition[0];
      final dy = p.position[1] - globalBestPosition[1];
      sumDist += sqrt(dx * dx + dy * dy);
    }
    return sumDist / particles.length;
  }

  /// Executes one iteration of Particle Swarm Optimization
  SimulationMetricPoint stepIteration() {
    currentIteration++;
    double totalFitness = 0.0;

    for (final p in particles) {
      // 1. Update velocities and positions for dimension 0 (X) and 1 (Y)
      for (int d = 0; d < 2; d++) {
        final double r1 = rng.nextDouble();
        final double r2 = rng.nextDouble();

        final double cognitiveComponent = cognitiveWeight * r1 * (p.personalBestPosition[d] - p.position[d]);
        final double socialComponent = socialWeight * r2 * (globalBestPosition[d] - p.position[d]);

        // v_i(t+1) = w * v_i(t) + c1 * r1 * (pbest - x) + c2 * r2 * (gbest - x)
        double newVel = inertiaWeight * p.velocity[d] + cognitiveComponent + socialComponent;

        // Velocity clamping
        newVel = newVel.clamp(-maxVelocity, maxVelocity);
        p.velocity[d] = newVel;

        // x_i(t+1) = x_i(t) + v_i(t+1)
        double newPos = p.position[d] + newVel;

        // Boundary reflection/damping
        if (newPos < minBound) {
          newPos = minBound;
          p.velocity[d] = -p.velocity[d] * 0.5;
        } else if (newPos > maxBound) {
          newPos = maxBound;
          p.velocity[d] = -p.velocity[d] * 0.5;
        }
        p.position[d] = newPos;
      }

      // 2. Evaluate fitness at new position
      final double fit = benchmark.evaluate(p.position);
      p.currentFitness = fit;
      totalFitness += fit;

      // 3. Update personal best (Minimization)
      if (fit < p.personalBestFitness) {
        p.personalBestFitness = fit;
        p.personalBestPosition = List<double>.from(p.position);

        // 4. Update global best
        if (fit < globalBestFitness) {
          globalBestFitness = fit;
          globalBestPosition = List<double>.from(p.position);
        }
      }
    }

    final double avgFitness = totalFitness / particleCount;
    final double dispersion = calculateSwarmDispersion();

    final metric = SimulationMetricPoint(
      iteration: currentIteration,
      bestObjective: globalBestFitness,
      averageObjective: avgFitness,
      extraMetric: dispersion,
    );

    history.add(metric);
    return metric;
  }
}
