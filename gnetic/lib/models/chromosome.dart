import 'gene.dart';

/// Represents a Chromosome made of a list of Genes.
class Chromosome<T> {
  final List<Gene<T>> genes;
  final int? crossoverPoint;

  const Chromosome({
    required this.genes,
    this.crossoverPoint,
  });

  int get length => genes.length;

  List<T> get rawValues => genes.map((g) => g.value).toList();

  Chromosome<T> copyWith({
    List<Gene<T>>? genes,
    int? crossoverPoint,
  }) {
    return Chromosome<T>(
      genes: genes ?? this.genes,
      crossoverPoint: crossoverPoint ?? this.crossoverPoint,
    );
  }

  @override
  String toString() => genes.map((g) => g.value.toString()).join('');
}
