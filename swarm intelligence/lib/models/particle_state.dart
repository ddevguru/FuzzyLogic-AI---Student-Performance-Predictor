class ParticleState {
  final int id;
  List<double> position;
  List<double> velocity;
  List<double> personalBestPosition;
  double personalBestFitness;
  double currentFitness;

  ParticleState({
    required this.id,
    required this.position,
    required this.velocity,
    required this.personalBestPosition,
    required this.personalBestFitness,
    required this.currentFitness,
  });

  ParticleState clone() {
    return ParticleState(
      id: id,
      position: List<double>.from(position),
      velocity: List<double>.from(velocity),
      personalBestPosition: List<double>.from(personalBestPosition),
      personalBestFitness: personalBestFitness,
      currentFitness: currentFitness,
    );
  }
}
