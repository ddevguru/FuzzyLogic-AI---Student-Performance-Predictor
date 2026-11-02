class RouteSolution {
  final List<int> cityIndices;
  final double totalDistance;
  final int antIndex;

  const RouteSolution({
    required this.cityIndices,
    required this.totalDistance,
    this.antIndex = 0,
  });

  RouteSolution copyWith({
    List<int>? cityIndices,
    double? totalDistance,
    int? antIndex,
  }) {
    return RouteSolution(
      cityIndices: cityIndices ?? List.from(this.cityIndices),
      totalDistance: totalDistance ?? this.totalDistance,
      antIndex: antIndex ?? this.antIndex,
    );
  }

  @override
  String toString() {
    return 'RouteSolution(distance: ${totalDistance.toStringAsFixed(1)}km, path: $cityIndices)';
  }
}
