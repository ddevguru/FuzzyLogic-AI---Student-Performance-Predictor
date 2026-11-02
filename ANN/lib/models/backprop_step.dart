import 'neuron.dart';

class LayerDeltaSnapshot {
  final int layerIndex;
  final List<double> neuronDeltas;
  final List<List<double>> weightGradients;
  final List<double> biasGradients;

  LayerDeltaSnapshot({
    required this.layerIndex,
    required this.neuronDeltas,
    required this.weightGradients,
    required this.biasGradients,
  });
}

class NeuronParameterDiff {
  final int layerIndex;
  final int neuronIndex;
  final List<double> oldWeights;
  final List<double> newWeights;
  final double oldBias;
  final double newBias;

  NeuronParameterDiff({
    required this.layerIndex,
    required this.neuronIndex,
    required this.oldWeights,
    required this.newWeights,
    required this.oldBias,
    required this.newBias,
  });
}

class BackpropStepDetail {
  final List<double> inputs;
  final List<double> predictions;
  final List<double> targets;
  final double loss;
  final List<LayerDeltaSnapshot> layerSnapshots;
  final List<NeuronParameterDiff> parameterDiffs;

  BackpropStepDetail({
    required this.inputs,
    required this.predictions,
    required this.targets,
    required this.loss,
    required this.layerSnapshots,
    required this.parameterDiffs,
  });
}
