import 'dart:math';
import '../models/chromosome.dart';
import '../models/gene.dart';

class GACrossover {
  static final Random _random = Random();

  /// Single Point Crossover for Binary / Value strings
  static (Chromosome<T>, Chromosome<T>) singlePointCrossover<T>(
    Chromosome<T> parentA,
    Chromosome<T> parentB,
    double crossoverRate,
  ) {
    if (_random.nextDouble() > crossoverRate || parentA.length <= 1) {
      return (parentA, parentB);
    }

    int point = 1 + _random.nextInt(parentA.length - 1);

    List<Gene<T>> childAGenes = [];
    List<Gene<T>> childBGenes = [];

    for (int i = 0; i < parentA.length; i++) {
      if (i < point) {
        childAGenes.add(parentA.genes[i]);
        childBGenes.add(parentB.genes[i]);
      } else {
        childAGenes.add(parentB.genes[i]);
        childBGenes.add(parentA.genes[i]);
      }
    }

    return (
      Chromosome<T>(genes: childAGenes, crossoverPoint: point),
      Chromosome<T>(genes: childBGenes, crossoverPoint: point),
    );
  }

  /// Ordered Crossover (OX1) specifically for TSP Permutations
  static (Chromosome<int>, Chromosome<int>) orderedCrossover(
    Chromosome<int> parentA,
    Chromosome<int> parentB,
    double crossoverRate,
  ) {
    if (_random.nextDouble() > crossoverRate || parentA.length <= 2) {
      return (parentA, parentB);
    }

    int len = parentA.length;
    int point1 = _random.nextInt(len - 1);
    int point2 = point1 + 1 + _random.nextInt(len - point1 - 1);

    List<int> childAValues = List.filled(len, -1);
    List<int> childBValues = List.filled(len, -1);

    // Copy slice from parentA to childA, parentB to childB
    for (int i = point1; i <= point2; i++) {
      childAValues[i] = parentA.genes[i].value;
      childBValues[i] = parentB.genes[i].value;
    }

    // Fill remaining for childA from parentB
    _fillOX(childAValues, parentB.rawValues, point2);
    // Fill remaining for childB from parentA
    _fillOX(childBValues, parentA.rawValues, point2);

    return (
      Chromosome<int>(
        genes: childAValues.map((v) => Gene<int>(value: v)).toList(),
        crossoverPoint: point2,
      ),
      Chromosome<int>(
        genes: childBValues.map((v) => Gene<int>(value: v)).toList(),
        crossoverPoint: point2,
      ),
    );
  }

  static void _fillOX(List<int> child, List<int> parent, int point2) {
    int len = child.length;
    int currentIdx = (point2 + 1) % len;
    int parentIdx = (point2 + 1) % len;

    for (int count = 0; count < len; count++) {
      int val = parent[parentIdx];
      if (!child.contains(val)) {
        child[currentIdx] = val;
        currentIdx = (currentIdx + 1) % len;
      }
      parentIdx = (parentIdx + 1) % len;
    }
  }
}
