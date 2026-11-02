import '../models/neural_network.dart';

enum OptimizerType {
  sgd,
  sgdmomentum,
}

class Optimizer {
  final double learningRate;
  final double momentum;
  final OptimizerType type;

  // Velocity buffers for SGD with momentum
  final Map<String, double> _weightVelocities = {};
  final Map<String, double> _biasVelocities = {};

  Optimizer({
    this.learningRate = 0.1,
    this.momentum = 0.9,
    this.type = OptimizerType.sgd,
  });

  void updateParameters(NeuralNetwork network) {
    for (int l = 0; l < network.layers.length; l++) {
      final layer = network.layers[l];
      for (int n = 0; n < layer.neurons.length; n++) {
        final neuron = layer.neurons[n];

        // Update bias
        final biasKey = 'b_${l}_$n';
        if (type == OptimizerType.sgdmomentum) {
          final vPrev = _biasVelocities[biasKey] ?? 0.0;
          final vNew = momentum * vPrev + learningRate * neuron.biasGradient;
          _biasVelocities[biasKey] = vNew;
          neuron.bias -= vNew;
        } else {
          neuron.bias -= learningRate * neuron.biasGradient;
        }

        // Update weights
        for (int w = 0; w < neuron.weights.length; w++) {
          final weightKey = 'w_${l}_${n}_$w';
          final grad = neuron.weightGradients[w];

          if (type == OptimizerType.sgdmomentum) {
            final vPrev = _weightVelocities[weightKey] ?? 0.0;
            final vNew = momentum * vPrev + learningRate * grad;
            _weightVelocities[weightKey] = vNew;
            neuron.weights[w] -= vNew;
          } else {
            neuron.weights[w] -= learningRate * grad;
          }
        }
      }
    }
  }

  void reset() {
    _weightVelocities.clear();
    _biasVelocities.clear();
  }
}
