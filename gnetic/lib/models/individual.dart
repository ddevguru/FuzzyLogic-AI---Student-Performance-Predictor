import 'chromosome.dart';

enum RankBadge { best, good, average, weak }

/// Represents an Individual candidate solution in the population.
class Individual<T> {
  final int id;
  final Chromosome<T> chromosome;
  final double fitness;
  final String decodedSolution;
  final int rank;
  final RankBadge rankBadge;

  const Individual({
    required this.id,
    required this.chromosome,
    required this.fitness,
    required this.decodedSolution,
    this.rank = 0,
    this.rankBadge = RankBadge.average,
  });

  Individual<T> copyWith({
    int? id,
    Chromosome<T>? chromosome,
    double? fitness,
    String? decodedSolution,
    int? rank,
    RankBadge? rankBadge,
  }) {
    return Individual<T>(
      id: id ?? this.id,
      chromosome: chromosome ?? this.chromosome,
      fitness: fitness ?? this.fitness,
      decodedSolution: decodedSolution ?? this.decodedSolution,
      rank: rank ?? this.rank,
      rankBadge: rankBadge ?? this.rankBadge,
    );
  }
}
