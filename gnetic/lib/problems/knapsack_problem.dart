import 'dart:math';
import '../models/chromosome.dart';
import '../models/gene.dart';
import '../models/problem_type.dart';
import 'base_problem.dart';

class KnapsackItem {
  final String name;
  final double weight; // in kg
  final double value; // in USD / points
  final String iconName;

  const KnapsackItem({
    required this.name,
    required this.weight,
    required this.value,
    required this.iconName,
  });
}

class KnapsackProblem extends BaseProblem<int> {
  final Random _random = Random();
  final double maxCapacity;

  static const List<KnapsackItem> defaultItems = [
    KnapsackItem(name: 'Laptop', weight: 3.5, value: 1200, iconName: 'laptop'),
    KnapsackItem(name: 'Camera', weight: 1.8, value: 800, iconName: 'camera'),
    KnapsackItem(name: 'Drone', weight: 2.2, value: 950, iconName: 'drone'),
    KnapsackItem(name: 'Smartphone', weight: 0.4, value: 700, iconName: 'phone'),
    KnapsackItem(name: 'Power Bank', weight: 0.8, value: 150, iconName: 'battery'),
    KnapsackItem(name: 'Solar Panel', weight: 3.0, value: 450, iconName: 'solar'),
    KnapsackItem(name: 'Medical Kit', weight: 1.5, value: 500, iconName: 'medkit'),
    KnapsackItem(name: 'Water Purifier', weight: 2.0, value: 350, iconName: 'water'),
    KnapsackItem(name: 'Smart Watch', weight: 0.3, value: 300, iconName: 'watch'),
    KnapsackItem(name: 'Headphones', weight: 0.6, value: 250, iconName: 'headphones'),
  ];

  KnapsackProblem({this.maxCapacity = 10.0});

  @override
  ProblemType get problemType => ProblemType.knapsack;

  @override
  String get name => 'Knapsack Optimization';

  @override
  String get description => 'Maximize total value of packed items without exceeding weight limit of ${maxCapacity.toStringAsFixed(1)} kg.';

  @override
  int get chromosomeLength => defaultItems.length;

  @override
  Chromosome<int> generateRandomChromosome() {
    List<Gene<int>> genes = List.generate(
      defaultItems.length,
      (_) => Gene<int>(value: _random.nextBool() ? 1 : 0),
    );
    return Chromosome<int>(genes: genes);
  }

  (double totalWeight, double totalValue) calculateTotals(Chromosome<int> chromosome) {
    double weight = 0.0;
    double value = 0.0;
    for (int i = 0; i < chromosome.genes.length; i++) {
      if (chromosome.genes[i].value == 1) {
        weight += defaultItems[i].weight;
        value += defaultItems[i].value;
      }
    }
    return (weight, value);
  }

  @override
  double evaluateFitness(Chromosome<int> chromosome) {
    final (totalWeight, totalValue) = calculateTotals(chromosome);
    if (totalWeight > maxCapacity) {
      // Penalty proportional to excess weight
      double excess = totalWeight - maxCapacity;
      double penalty = excess * 250;
      double penalizedVal = totalValue - penalty;
      return penalizedVal > 0 ? penalizedVal : 0.001;
    }
    return totalValue > 0 ? totalValue : 0.001;
  }

  @override
  String decodeSolution(Chromosome<int> chromosome) {
    final (totalWeight, totalValue) = calculateTotals(chromosome);
    List<String> selectedNames = [];
    for (int i = 0; i < chromosome.genes.length; i++) {
      if (chromosome.genes[i].value == 1) {
        selectedNames.add(defaultItems[i].name);
      }
    }
    String status = totalWeight > maxCapacity ? ' [EXCEEDED]' : ' [VALID]';
    return 'Value: \$${totalValue.toStringAsFixed(0)} | Weight: ${totalWeight.toStringAsFixed(1)}/${maxCapacity}kg ($selectedNames.length items)$status';
  }
}
