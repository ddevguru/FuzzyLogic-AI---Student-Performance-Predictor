import 'dart:math';
import '../models/chromosome.dart';
import '../models/gene.dart';
import '../models/problem_type.dart';
import 'base_problem.dart';

class City {
  final int id;
  final String name;
  final double x; // normalized 0..100
  final double y; // normalized 0..100

  const City({
    required this.id,
    required this.name,
    required this.x,
    required this.y,
  });

  double distanceTo(City other) {
    double dx = x - other.x;
    double dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }
}

class TSPProblem extends BaseProblem<int> {
  final Random _random = Random();

  static const List<City> cities = [
    City(id: 0, name: 'Mumbai', x: 20, y: 70),
    City(id: 1, name: 'Pune', x: 30, y: 75),
    City(id: 2, name: 'Nashik', x: 28, y: 55),
    City(id: 3, name: 'Aurangabad', x: 42, y: 56),
    City(id: 4, name: 'Nagpur', x: 75, y: 40),
    City(id: 5, name: 'Goa', x: 22, y: 92),
    City(id: 6, name: 'Surat', x: 22, y: 38),
    City(id: 7, name: 'Ahmedabad', x: 18, y: 22),
  ];

  @override
  ProblemType get problemType => ProblemType.tsp;

  @override
  String get name => 'Traveling Salesman (TSP)';

  @override
  String get description => 'Find the shortest path visiting all 8 cities (Mumbai, Pune, Nashik, etc.) and returning to starting city.';

  @override
  int get chromosomeLength => cities.length;

  @override
  Chromosome<int> generateRandomChromosome() {
    List<int> indices = List.generate(cities.length, (i) => i);
    indices.shuffle(_random);
    List<Gene<int>> genes = indices.map((idx) => Gene<int>(value: idx)).toList();
    return Chromosome<int>(genes: genes);
  }

  double calculateTotalDistance(Chromosome<int> chromosome) {
    double totalDist = 0.0;
    List<int> order = chromosome.rawValues;
    for (int i = 0; i < order.length; i++) {
      City current = cities[order[i]];
      City next = cities[order[(i + 1) % order.length]]; // Loop back to start city
      totalDist += current.distanceTo(next);
    }
    return totalDist;
  }

  @override
  double evaluateFitness(Chromosome<int> chromosome) {
    double dist = calculateTotalDistance(chromosome);
    if (dist <= 0) return 0.001;
    // Fitness is inverse of distance (scaled up for nice decimal readability)
    return 10000.0 / dist;
  }

  @override
  String decodeSolution(Chromosome<int> chromosome) {
    List<int> order = chromosome.rawValues;
    List<String> names = order.map((idx) => cities[idx].name).toList();
    double dist = calculateTotalDistance(chromosome);
    return '${names.join(" → ")} → ${cities[order.first].name} (Dist: ${dist.toStringAsFixed(1)} km)';
  }
}
