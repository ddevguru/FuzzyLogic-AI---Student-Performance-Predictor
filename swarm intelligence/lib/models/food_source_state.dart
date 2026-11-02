class FoodSourceState {
  final int id;
  List<double> position;
  double objectiveValue;
  double fitness;
  int trial;

  FoodSourceState({
    required this.id,
    required this.position,
    required this.objectiveValue,
    required this.fitness,
    this.trial = 0,
  });

  /// Standard ABC fitness calculation from objective function f(x)
  static double computeFitness(double objective) {
    if (objective >= 0) {
      return 1.0 / (1.0 + objective);
    } else {
      return 1.0 + objective.abs();
    }
  }

  FoodSourceState clone() {
    return FoodSourceState(
      id: id,
      position: List<double>.from(position),
      objectiveValue: objectiveValue,
      fitness: fitness,
      trial: trial,
    );
  }
}
