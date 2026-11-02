import 'package:flutter/foundation.dart';
import '../models/neural_network.dart';
import '../models/training_result.dart';
import '../engine/ann_engine.dart';
import '../engine/loss_functions.dart';
import '../engine/optimizers.dart';
import '../engine/activation_functions.dart';
import '../datasets/dataset_base.dart';
import '../datasets/xor_dataset.dart';

class TrainingService extends ChangeNotifier {
  AnnEngine? _engine;
  AppDataset _dataset = XorDataset();

  // Training Hyperparameters
  double _learningRate = 0.1;
  int _epochs = 300;
  int _numHiddenLayers = 1;
  int _neuronsPerHidden = 4;
  ActivationType _hiddenActivation = ActivationType.sigmoid;
  LossType _lossType = LossType.mse;

  // Training State
  bool _isTraining = false;
  bool _isPaused = false;
  int _currentEpoch = 0;
  double _currentTrainLoss = 0.0;
  double _currentTrainAccuracy = 0.0;
  double? _currentValLoss;
  double? _currentValAccuracy;

  TrainingResult? _latestResult;
  final List<EpochMetric> _liveEpochHistory = [];

  // App-wide persistent statistics
  int _networksTrainedCount = 0;
  int _totalEpochsTrained = 0;
  double _latestModelAccuracy = 0.0;

  TrainingService() {
    _reinitDataset();
  }

  // Getters
  AppDataset get dataset => _dataset;
  double get learningRate => _learningRate;
  int get epochs => _epochs;
  int get numHiddenLayers => _numHiddenLayers;
  int get neuronsPerHidden => _neuronsPerHidden;
  ActivationType get hiddenActivation => _hiddenActivation;
  LossType get lossType => _lossType;

  bool get isTraining => _isTraining;
  bool get isPaused => _isPaused;
  int get currentEpoch => _currentEpoch;
  double get currentTrainLoss => _currentTrainLoss;
  double get currentTrainAccuracy => _currentTrainAccuracy;
  double? get currentValLoss => _currentValLoss;
  double? get currentValAccuracy => _currentValAccuracy;

  TrainingResult? get latestResult => _latestResult;
  List<EpochMetric> get liveEpochHistory => _liveEpochHistory;

  int get networksTrainedCount => _networksTrainedCount;
  int get totalEpochsTrained => _totalEpochsTrained;
  double get latestModelAccuracy => _latestModelAccuracy;

  void setHyperparameters({
    double? learningRate,
    int? epochs,
    int? numHiddenLayers,
    int? neuronsPerHidden,
    ActivationType? hiddenActivation,
    LossType? lossType,
  }) {
    if (learningRate != null) _learningRate = learningRate;
    if (epochs != null) _epochs = epochs;
    if (numHiddenLayers != null) _numHiddenLayers = numHiddenLayers;
    if (neuronsPerHidden != null) _neuronsPerHidden = neuronsPerHidden;
    if (hiddenActivation != null) _hiddenActivation = hiddenActivation;
    if (lossType != null) _lossType = lossType;
    notifyListeners();
  }

  void selectDataset(AppDataset newDataset) {
    _dataset = newDataset;
    _reinitDataset();
    notifyListeners();
  }

  void _reinitDataset() {
    if (_dataset.isClassification) {
      _lossType = LossType.mse; // or BCE
    } else {
      _lossType = LossType.mse;
    }
  }

  Future<void> startTraining(NeuralNetwork network) async {
    if (_isTraining) return;

    _isTraining = true;
    _isPaused = false;
    _currentEpoch = 0;
    _liveEpochHistory.clear();
    notifyListeners();

    final optimizer = Optimizer(learningRate: _learningRate);
    _engine = AnnEngine(
      network: network,
      lossType: _lossType,
      optimizer: optimizer,
    );

    final result = await _engine!.train(
      trainSamples: _dataset.trainSamples,
      valSamples: _dataset.valSamples,
      epochs: _epochs,
      datasetName: _dataset.name,
      isClassification: _dataset.isClassification,
      onProgress: (epoch, total, trainLoss, trainAcc, valLoss, valAcc) {
        _currentEpoch = epoch;
        _currentTrainLoss = trainLoss;
        _currentTrainAccuracy = trainAcc;
        _currentValLoss = valLoss;
        _currentValAccuracy = valAcc;

        _liveEpochHistory.add(EpochMetric(
          epoch: epoch,
          trainLoss: trainLoss,
          valLoss: valLoss,
          trainAccuracy: trainAcc,
          valAccuracy: valAcc,
        ));

        notifyListeners();
      },
    );

    _latestResult = result;
    _isTraining = false;
    _isPaused = false;
    _networksTrainedCount++;
    _totalEpochsTrained += result.totalEpochs;
    _latestModelAccuracy = result.finalAccuracy;

    notifyListeners();
  }

  void pauseTraining() {
    if (_isTraining && _engine != null) {
      _engine!.pause();
      _isPaused = true;
      notifyListeners();
    }
  }

  void resumeTraining() {
    if (_isTraining && _engine != null) {
      _engine!.resume();
      _isPaused = false;
      notifyListeners();
    }
  }

  void stopTraining() {
    if (_isTraining && _engine != null) {
      _engine!.stop();
      _isTraining = false;
      _isPaused = false;
      notifyListeners();
    }
  }

  void resetTrainingState() {
    stopTraining();
    _currentEpoch = 0;
    _currentTrainLoss = 0.0;
    _currentTrainAccuracy = 0.0;
    _currentValLoss = null;
    _currentValAccuracy = null;
    _liveEpochHistory.clear();
    notifyListeners();
  }
}
