class PheromoneMatrix {
  final int size;
  final double initialPheromone;
  final double minPheromone;
  final double maxPheromone;
  late List<List<double>> values;

  PheromoneMatrix({
    required this.size,
    this.initialPheromone = 1.0,
    this.minPheromone = 0.001,
    this.maxPheromone = 50.0,
  }) {
    reset();
  }

  void reset() {
    values = List.generate(
      size,
      (_) => List.filled(size, initialPheromone),
    );
  }

  double get(int i, int j) => values[i][j];

  void set(int i, int j, double val) {
    final clamped = val.clamp(minPheromone, maxPheromone);
    values[i][j] = clamped;
    values[j][i] = clamped;
  }

  void evaporate(double rho) {
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        values[i][j] = (values[i][j] * (1.0 - rho)).clamp(minPheromone, maxPheromone);
      }
    }
  }

  void deposit(int i, int j, double delta) {
    final newVal = (values[i][j] + delta).clamp(minPheromone, maxPheromone);
    values[i][j] = newVal;
    values[j][i] = newVal;
  }

  double getMaxPheromone() {
    double m = 0.0;
    for (int i = 0; i < size; i++) {
      for (int j = 0; j < size; j++) {
        if (values[i][j] > m) m = values[i][j];
      }
    }
    return m;
  }
}
