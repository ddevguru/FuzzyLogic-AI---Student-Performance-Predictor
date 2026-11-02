import 'dart:math';
import '../models/chromosome.dart';
import '../models/gene.dart';

class GAMutation {
  static final Random _random = Random();

  /// Bit Flip Mutation for Binary Chromosomes (0/1)
  static Chromosome<int> bitFlipMutation(
    Chromosome<int> chromosome,
    double mutationRate,
  ) {
    List<Gene<int>> newGenes = [];
    for (var gene in chromosome.genes) {
      if (_random.nextDouble() < mutationRate) {
        int flipped = gene.value == 1 ? 0 : 1;
        newGenes.add(Gene<int>(value: flipped, isMutated: true));
      } else {
        newGenes.add(gene.copyWith(isMutated: false));
      }
    }
    return Chromosome<int>(
      genes: newGenes,
      crossoverPoint: chromosome.crossoverPoint,
    );
  }

  /// Swap Mutation for Permutation Chromosomes (TSP)
  static Chromosome<int> swapMutation(
    Chromosome<int> chromosome,
    double mutationRate,
  ) {
    if (_random.nextDouble() >= mutationRate || chromosome.length < 2) {
      return chromosome;
    }

    List<Gene<int>> genes = List.from(chromosome.genes);
    int idx1 = _random.nextInt(genes.length);
    int idx2 = _random.nextInt(genes.length);
    while (idx1 == idx2) {
      idx2 = _random.nextInt(genes.length);
    }

    Gene<int> temp = genes[idx1];
    genes[idx1] = Gene<int>(value: genes[idx2].value, isMutated: true);
    genes[idx2] = Gene<int>(value: temp.value, isMutated: true);

    return Chromosome<int>(
      genes: genes,
      crossoverPoint: chromosome.crossoverPoint,
    );
  }

  /// Discrete Value Random Mutation for integer genes (Scheduling slots)
  static Chromosome<int> discreteRandomMutation(
    Chromosome<int> chromosome,
    double mutationRate,
    int maxDiscreteVal,
  ) {
    List<Gene<int>> newGenes = [];
    for (var gene in chromosome.genes) {
      if (_random.nextDouble() < mutationRate) {
        int newVal = _random.nextInt(maxDiscreteVal);
        newGenes.add(Gene<int>(value: newVal, isMutated: true));
      } else {
        newGenes.add(gene.copyWith(isMutated: false));
      }
    }
    return Chromosome<int>(
      genes: newGenes,
      crossoverPoint: chromosome.crossoverPoint,
    );
  }
}
