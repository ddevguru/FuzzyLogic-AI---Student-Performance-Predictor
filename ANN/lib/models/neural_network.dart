import 'dense_layer.dart';
import '../engine/activation_functions.dart';

class NeuralNetwork {
  final int numInputs;
  final List<DenseLayer> layers;

  NeuralNetwork({
    required this.numInputs,
    required this.layers,
  });

  int get numOutputs => layers.isEmpty ? 0 : layers.last.numNeurons;
  int get numHiddenLayers => layers.length > 1 ? layers.length - 1 : 0;

  /// Factory constructor to create network architecture with defaults
  factory NeuralNetwork.create({
    required int inputSize,
    required List<int> hiddenSizes,
    required int outputSize,
    required ActivationType hiddenActivation,
    required ActivationType outputActivation,
    int? seed,
  }) {
    final layersList = <DenseLayer>[];
    int currentInputSize = inputSize;

    // Build hidden layers
    for (int i = 0; i < hiddenSizes.length; i++) {
      int layerSize = hiddenSizes[i];
      layersList.add(
        DenseLayer.random(
          numInputs: currentInputSize,
          numNeurons: layerSize,
          activationType: hiddenActivation,
          seed: seed != null ? seed + i : null,
        ),
      );
      currentInputSize = layerSize;
    }

    // Build output layer
    layersList.add(
      DenseLayer.random(
        numInputs: currentInputSize,
        numNeurons: outputSize,
        activationType: outputActivation,
        seed: seed != null ? seed + 999 : null,
      ),
    );

    return NeuralNetwork(
      numInputs: inputSize,
      layers: layersList,
    );
  }

  /// Forward pass through all layers
  List<double> forward(List<double> inputs) {
    List<double> current = List<double>.from(inputs);
    for (var layer in layers) {
      current = layer.forward(current);
    }
    return current;
  }

  /// Get architecture summary text (e.g., "2 → 4 → 1")
  String get architectureSummary {
    final sizes = [numInputs, ...layers.map((l) => l.numNeurons)];
    return sizes.join(' → ');
  }

  /// Count total trainable parameters (weights + biases)
  int get totalParameters {
    int count = 0;
    for (var layer in layers) {
      count += (layer.numInputs * layer.numNeurons) + layer.numNeurons;
    }
    return count;
  }

  NeuralNetwork copyWith() {
    return NeuralNetwork(
      numInputs: numInputs,
      layers: layers.map((l) => l.copyWith()).toList(),
    );
  }
}
