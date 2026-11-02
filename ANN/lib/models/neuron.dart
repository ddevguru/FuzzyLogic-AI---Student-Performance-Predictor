import 'dart:math' as math;

class Neuron {
  List<double> weights;
  double bias;
  double z; // Weighted sum: z = sum(w_i * x_i) + bias
  double output; // Activation: a = activation(z)
  double delta; // Gradient delta for backprop
  List<double> lastInputs; // Recorded inputs from forward pass
  List<double> weightGradients;
  double biasGradient;

  Neuron({
    required this.weights,
    this.bias = 0.0,
    this.z = 0.0,
    this.output = 0.0,
    this.delta = 0.0,
    List<double>? lastInputs,
    List<double>? weightGradients,
    this.biasGradient = 0.0,
  })  : lastInputs = lastInputs ?? List.filled(weights.length, 0.0),
        weightGradients = weightGradients ?? List.filled(weights.length, 0.0);

  factory Neuron.random(int numInputs, {double scale = 1.0, math.Random? random}) {
    final r = random ?? math.Random();
    List<double> initialWeights = List.generate(
      numInputs,
      (_) => (r.nextDouble() * 2 - 1) * scale,
    );
    double initialBias = (r.nextDouble() * 2 - 1) * 0.1;
    return Neuron(
      weights: initialWeights,
      bias: initialBias,
    );
  }

  Neuron copyWith({
    List<double>? weights,
    double? bias,
    double? z,
    double? output,
    double? delta,
    List<double>? lastInputs,
    List<double>? weightGradients,
    double? biasGradient,
  }) {
    return Neuron(
      weights: weights ?? List<double>.from(this.weights),
      bias: bias ?? this.bias,
      z: z ?? this.z,
      output: output ?? this.output,
      delta: delta ?? this.delta,
      lastInputs: lastInputs ?? List<double>.from(this.lastInputs),
      weightGradients: weightGradients ?? List<double>.from(this.weightGradients),
      biasGradient: biasGradient ?? this.biasGradient,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weights': weights,
      'bias': bias,
      'z': z,
      'output': output,
      'delta': delta,
    };
  }
}
