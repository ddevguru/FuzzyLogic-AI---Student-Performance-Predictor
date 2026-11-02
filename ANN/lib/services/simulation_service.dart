import 'package:flutter/foundation.dart';
import '../models/neural_network.dart';
import '../models/neuron.dart';
import '../models/prediction_result.dart';
import '../engine/activation_functions.dart';
import '../datasets/dataset_base.dart';
import '../datasets/xor_dataset.dart';

class SimulationService extends ChangeNotifier {
  late NeuralNetwork _network;
  AppDataset _selectedDataset = XorDataset();
  
  // Interactive inputs for simulator & prediction playground
  List<double> _currentInputs = [0.5, 0.8];
  List<double> _currentOutputs = [0.0];
  
  // Architecture configuration
  int _numInputNeurons = 2;
  int _numHiddenLayers = 1;
  int _numNeuronsPerHidden = 4;
  int _numOutputNeurons = 1;
  ActivationType _hiddenActivation = ActivationType.sigmoid;
  ActivationType _outputActivation = ActivationType.sigmoid;

  // Visual inspection selection
  int? _selectedLayerIndex;
  int? _selectedNeuronIndex;

  // Signal propagation animation status
  bool _isPropagating = false;

  SimulationService() {
    _rebuildNetwork();
  }

  NeuralNetwork get network => _network;
  AppDataset get selectedDataset => _selectedDataset;
  List<double> get currentInputs => _currentInputs;
  List<double> get currentOutputs => _currentOutputs;

  int get numInputNeurons => _numInputNeurons;
  int get numHiddenLayers => _numHiddenLayers;
  int get numNeuronsPerHidden => _numNeuronsPerHidden;
  int get numOutputNeurons => _numOutputNeurons;
  ActivationType get hiddenActivation => _hiddenActivation;
  ActivationType get outputActivation => _outputActivation;

  int? get selectedLayerIndex => _selectedLayerIndex;
  int? get selectedNeuronIndex => _selectedNeuronIndex;
  bool get isPropagating => _isPropagating;

  Neuron? get selectedNeuron {
    if (_selectedLayerIndex != null &&
        _selectedNeuronIndex != null &&
        _selectedLayerIndex! < _network.layers.length &&
        _selectedNeuronIndex! < _network.layers[_selectedLayerIndex!].neurons.length) {
      return _network.layers[_selectedLayerIndex!].neurons[_selectedNeuronIndex!];
    }
    return null;
  }

  void _rebuildNetwork() {
    final hiddenSizes = List.filled(_numHiddenLayers, _numNeuronsPerHidden);
    _network = NeuralNetwork.create(
      inputSize: _numInputNeurons,
      hiddenSizes: hiddenSizes,
      outputSize: _numOutputNeurons,
      hiddenActivation: _hiddenActivation,
      outputActivation: _outputActivation,
      seed: 42,
    );

    // Adjust current inputs array if input size changed
    if (_currentInputs.length != _numInputNeurons) {
      _currentInputs = List.generate(_numInputNeurons, (i) => 0.5);
    }

    runForwardPropagation();
  }

  void updateArchitecture({
    int? inputNeurons,
    int? hiddenLayers,
    int? neuronsPerHidden,
    int? outputNeurons,
    ActivationType? hiddenActivation,
    ActivationType? outputActivation,
  }) {
    if (inputNeurons != null) _numInputNeurons = inputNeurons;
    if (hiddenLayers != null) _numHiddenLayers = hiddenLayers;
    if (neuronsPerHidden != null) _numNeuronsPerHidden = neuronsPerHidden;
    if (outputNeurons != null) _numOutputNeurons = outputNeurons;
    if (hiddenActivation != null) _hiddenActivation = hiddenActivation;
    if (outputActivation != null) _outputActivation = outputActivation;

    _rebuildNetwork();
    notifyListeners();
  }

  void setDataset(AppDataset dataset) {
    _selectedDataset = dataset;
    final sample = dataset.trainSamples.first;
    _numInputNeurons = sample.inputs.length;
    _numOutputNeurons = sample.targets.length;
    _currentInputs = List<double>.from(sample.inputs);

    if (dataset.isClassification) {
      _outputActivation = ActivationType.sigmoid;
    } else {
      _outputActivation = ActivationType.linear;
    }

    _rebuildNetwork();
    notifyListeners();
  }

  void selectNeuron(int? layerIndex, int? neuronIndex) {
    _selectedLayerIndex = layerIndex;
    _selectedNeuronIndex = neuronIndex;
    notifyListeners();
  }

  void updateInputValues(List<double> inputs) {
    _currentInputs = List<double>.from(inputs);
    runForwardPropagation();
  }

  void setSingleInput(int index, double value) {
    if (index >= 0 && index < _currentInputs.length) {
      _currentInputs[index] = value;
      runForwardPropagation();
    }
  }

  void runForwardPropagation() {
    if (_currentInputs.length == _network.numInputs) {
      _currentOutputs = _network.forward(_currentInputs);
      notifyListeners();
    }
  }

  PredictionResult predict(List<double> inputs) {
    final outputs = _network.forward(inputs);
    int predClass = 0;
    double confidence = outputs[0];
    String label = 'Class 0';

    if (_selectedDataset.isClassification) {
      if (outputs.length == 1) {
        predClass = outputs[0] >= 0.5 ? 1 : 0;
        confidence = predClass == 1 ? outputs[0] : (1.0 - outputs[0]);
        label = 'Class $predClass';
      } else {
        predClass = 0;
        double maxP = outputs[0];
        for (int i = 1; i < outputs.length; i++) {
          if (outputs[i] > maxP) {
            maxP = outputs[i];
            predClass = i;
          }
        }
        confidence = maxP;
        label = 'Class $predClass';
      }
    } else {
      label = 'Predicted Value: ${outputs[0].toStringAsFixed(4)}';
      confidence = 1.0;
    }

    return PredictionResult(
      inputs: inputs,
      outputs: outputs,
      predictedClass: predClass,
      confidence: confidence,
      label: label,
      isClassification: _selectedDataset.isClassification,
    );
  }

  void triggerPropagationAnimation() {
    _isPropagating = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1200), () {
      _isPropagating = false;
      notifyListeners();
    });
  }

  void resetNetwork() {
    _rebuildNetwork();
    notifyListeners();
  }
}
