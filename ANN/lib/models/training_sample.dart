class TrainingSample {
  final List<double> inputs;
  final List<double> targets;

  TrainingSample({
    required this.inputs,
    required this.targets,
  });

  @override
  String toString() => 'Sample(inputs: $inputs, targets: $targets)';
}
