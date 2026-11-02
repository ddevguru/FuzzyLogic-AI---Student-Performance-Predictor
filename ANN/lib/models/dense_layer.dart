import 'dart:math' as math;
import 'neuron.dart';
import '../engine/activation_functions.dart';
import '../core/utils/math_utils.dart';

class DenseLayer {
  final int numInputs;
  final int numNeurons;
  final List<Neuron> neurons;
  final ActivationType activationType;

  DenseLayer({
    required this.numInputs,
    required this.numNeurons,
    required this.neurons,
    required this.activationType,
  });

  factory DenseLayer.random({
    required int numInputs,
    required int numNeurons,
    required ActivationType activationType,
    int? seed,
  }) {
    final r = seed != null ? math.Random(seed) : math.Random();
    double scale = activationType == ActivationType.relu
        ? MathUtils.heScale(numInputs)
        : MathUtils.xavierScale(numInputs, numNeurons);

    final neuronList = List.generate(
      numNeurons,
      (_) => Neuron.random(numInputs, scale: scale, random: r),
    );

    return DenseLayer(
      numInputs: numInputs,
      numNeurons: numNeurons,
      neurons: neuronList,
      activationType: activationType,
    );
  }

  /// Forward pass: inputs -> outputs
  List<double> forward(List<double> inputs) {
    if (inputs.length != numInputs) {
      throw ArgumentError(
          'Layer input size mismatch: expected $numInputs, got ${inputs.length}');
    }

    final zValues = <double>[];
    for (var neuron in neurons) {
      neuron.lastInputs = List<double>.from(inputs);
      double sum = neuron.bias;
      for (int i = 0; i < numInputs; i++) {
        sum += neuron.weights[i] * inputs[i];
      }
      neuron.z = sum;
      zValues.add(sum);
    }

    final outputs = ActivationFunctions.activateVector(zValues, activationType);
    for (int i = 0; i < numNeurons; i++) {
      neurons[i].output = outputs[i];
    }

    return outputs;
  }

  DenseLayer copyWith({
    int? numInputs,
    int? numNeurons,
    List<Neuron>? neurons,
    ActivationType? activationType,
  }) {
    return DenseLayer(
      numInputs: numInputs ?? this.numInputs,
      numNeurons: numNeurons ?? this.numNeurons,
      neurons: neurons != null
          ? neurons.map((n) => n.copyWith()).toList()
          : this.neurons.map((n) => n.copyWith()).toList(),
      activationType: activationType ?? this.activationType,
    );
  }
}
