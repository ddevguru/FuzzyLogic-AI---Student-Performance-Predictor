import '../models/neural_network.dart';
import '../models/neuron.dart';
import '../models/backprop_step.dart';
import 'activation_functions.dart';
import 'loss_functions.dart';
import 'optimizers.dart';

class Backpropagation {
  /// Performs backpropagation for a single training sample.
  /// Calculates gradients, updates network parameters using [optimizer],
  /// and returns a [BackpropStepDetail] for visualization if requested.
  static BackpropStepDetail trainSample(
    NeuralNetwork network,
    List<double> inputs,
    List<double> targets,
    LossType lossType,
    Optimizer optimizer,
  ) {
    // 1. Forward Pass
    final predictions = network.forward(inputs);
    final loss = LossFunctions.computeLoss(predictions, targets, lossType);

    // 2. Output Layer Delta Calculation
    final outputLayer = network.layers.last;
    final lossDerivatives = LossFunctions.computeLossDerivative(predictions, targets, lossType);

    for (int i = 0; i < outputLayer.neurons.length; i++) {
      final neuron = outputLayer.neurons[i];
      final actDeriv = ActivationFunctions.derivative(
        neuron.z,
        neuron.output,
        outputLayer.activationType,
      );

      // Handle Softmax + BCE/CCE simplification or general chain rule
      if (outputLayer.activationType == ActivationType.softmax &&
          (lossType == LossType.binaryCrossEntropy || lossType == LossType.categoricalCrossEntropy)) {
        neuron.delta = predictions[i] - targets[i];
      } else {
        neuron.delta = lossDerivatives[i] * actDeriv;
      }
    }

    // 3. Hidden Layers Delta Calculation (Backwards loop)
    for (int l = network.layers.length - 2; l >= 0; l--) {
      final currentLayer = network.layers[l];
      final nextLayer = network.layers[l + 1];

      for (int j = 0; j < currentLayer.neurons.length; j++) {
        final neuron = currentLayer.neurons[j];
        double sumDeltaW = 0.0;
        for (int k = 0; k < nextLayer.neurons.length; k++) {
          final nextNeuron = nextLayer.neurons[k];
          sumDeltaW += nextNeuron.delta * nextNeuron.weights[j];
        }

        final actDeriv = ActivationFunctions.derivative(
          neuron.z,
          neuron.output,
          currentLayer.activationType,
        );

        neuron.delta = sumDeltaW * actDeriv;
      }
    }

    // 4. Compute Gradients for all neurons
    final layerSnapshots = <LayerDeltaSnapshot>[];
    for (int l = 0; l < network.layers.length; l++) {
      final layer = network.layers[l];
      final neuronDeltas = <double>[];
      final weightGradientsList = <List<double>>[];
      final biasGradientsList = <double>[];

      for (int n = 0; n < layer.neurons.length; n++) {
        final neuron = layer.neurons[n];
        neuronDeltas.add(neuron.delta);

        final prevInputs = neuron.lastInputs;
        final neuronWeightGradients = <double>[];
        for (int w = 0; w < neuron.weights.length; w++) {
          final grad = neuron.delta * prevInputs[w];
          neuron.weightGradients[w] = grad;
          neuronWeightGradients.add(grad);
        }
        neuron.biasGradient = neuron.delta;
        biasGradientsList.add(neuron.delta);
        weightGradientsList.add(neuronWeightGradients);
      }

      layerSnapshots.add(
        LayerDeltaSnapshot(
          layerIndex: l,
          neuronDeltas: neuronDeltas,
          weightGradients: weightGradientsList,
          biasGradients: biasGradientsList,
        ),
      );
    }

    // 5. Record Parameter Diff before update
    final diffs = <NeuronParameterDiff>[];
    for (int l = 0; l < network.layers.length; l++) {
      final layer = network.layers[l];
      for (int n = 0; n < layer.neurons.length; n++) {
        final neuron = layer.neurons[n];
        diffs.add(
          NeuronParameterDiff(
            layerIndex: l,
            neuronIndex: n,
            oldWeights: List<double>.from(neuron.weights),
            oldBias: neuron.bias,
            newWeights: [],
            newBias: 0.0,
          ),
        );
      }
    }

    // 6. Update Parameters via Optimizer
    optimizer.updateParameters(network);

    // 7. Complete Parameter Diff after update
    int diffIdx = 0;
    for (int l = 0; l < network.layers.length; l++) {
      final layer = network.layers[l];
      for (int n = 0; n < layer.neurons.length; n++) {
        final neuron = layer.neurons[n];
        final oldDiff = diffs[diffIdx];
        diffs[diffIdx] = NeuronParameterDiff(
          layerIndex: l,
          neuronIndex: n,
          oldWeights: oldDiff.oldWeights,
          newWeights: List<double>.from(neuron.weights),
          oldBias: oldDiff.oldBias,
          newBias: neuron.bias,
        );
        diffIdx++;
      }
    }

    return BackpropStepDetail(
      inputs: inputs,
      predictions: predictions,
      targets: targets,
      loss: loss,
      layerSnapshots: layerSnapshots,
      parameterDiffs: diffs,
    );
  }
}
