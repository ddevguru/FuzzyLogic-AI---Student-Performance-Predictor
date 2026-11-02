import 'dart:math';
import '../models/chromosome.dart';
import '../models/gene.dart';
import '../models/problem_type.dart';
import 'base_problem.dart';

/// Function Optimization: Maximize f(x) = x * sin(x) + 10 over x in [0, 31.875]
class FunctionOptimizationProblem extends BaseProblem<int> {
  final Random _random = Random();
  final int bitLength;
  final double minX;
  final double maxX;

  FunctionOptimizationProblem({
    this.bitLength = 10,
    this.minX = 0.0,
    this.maxX = 31.875,
  });

  @override
  ProblemType get problemType => ProblemType.functionOptimization;

  @override
  String get name => 'Function Optimization';

  @override
  String get description => 'Maximize f(x) = x · sin(x) + 10 over continuous interval x ∈ [0, 31.875].';

  @override
  int get chromosomeLength => bitLength;

  @override
  Chromosome<int> generateRandomChromosome() {
    List<Gene<int>> genes = List.generate(
      bitLength,
      (_) => Gene<int>(value: _random.nextBool() ? 1 : 0),
    );
    return Chromosome<int>(genes: genes);
  }

  /// Decode binary string chromosome into continuous double x value
  double decodeX(Chromosome<int> chromosome) {
    int intVal = 0;
    for (int i = 0; i < chromosome.genes.length; i++) {
      intVal = (intVal << 1) | chromosome.genes[i].value;
    }
    int maxInt = (1 << bitLength) - 1;
    return minX + (intVal / maxInt) * (maxX - minX);
  }

  /// Calculate mathematical function f(x) = x * sin(x) + 10
  double calculateFunctionValue(double x) {
    return x * sin(x) + 10;
  }

  @override
  double evaluateFitness(Chromosome<int> chromosome) {
    double x = decodeX(chromosome);
    double val = calculateFunctionValue(x);
    // Ensure positive fitness
    return val > 0 ? val : 0.001;
  }

  @override
  String decodeSolution(Chromosome<int> chromosome) {
    double x = decodeX(chromosome);
    double fx = calculateFunctionValue(x);
    return 'x = ${x.toStringAsFixed(3)} ⇒ f(x) = ${fx.toStringAsFixed(3)}';
  }
}
