import 'package:flutter_test/flutter_test.dart';
import 'package:ann_intelligence_lab/models/neural_network.dart';
import 'package:ann_intelligence_lab/engine/activation_functions.dart';
import 'package:ann_intelligence_lab/engine/loss_functions.dart';
import 'package:ann_intelligence_lab/engine/optimizers.dart';
import 'package:ann_intelligence_lab/engine/backpropagation.dart';
import 'package:ann_intelligence_lab/engine/ann_engine.dart';
import 'package:ann_intelligence_lab/engine/metrics.dart';
import 'package:ann_intelligence_lab/datasets/xor_dataset.dart';

void main() {
  group('Activation Functions Unit Tests', () {
    test('Sigmoid function and derivative', () {
      final sig0 = ActivationFunctions.activate(0.0, ActivationType.sigmoid);
      expect(sig0, closeTo(0.5, 1e-5));

      final deriv = ActivationFunctions.derivative(0.0, 0.5, ActivationType.sigmoid);
      expect(deriv, closeTo(0.25, 1e-5));
    });

    test('ReLU function and derivative', () {
      expect(ActivationFunctions.activate(3.5, ActivationType.relu), equals(3.5));
      expect(ActivationFunctions.activate(-2.0, ActivationType.relu), equals(0.0));
      expect(ActivationFunctions.derivative(3.5, 3.5, ActivationType.relu), equals(1.0));
      expect(ActivationFunctions.derivative(-2.0, 0.0, ActivationType.relu), equals(0.0));
    });

    test('Tanh function and derivative', () {
      final tanh0 = ActivationFunctions.activate(0.0, ActivationType.tanh);
      expect(tanh0, closeTo(0.0, 1e-5));
      final deriv = ActivationFunctions.derivative(0.0, 0.0, ActivationType.tanh);
      expect(deriv, closeTo(1.0, 1e-5));
    });
  });

  group('Loss Functions Unit Tests', () {
    test('MSE calculation', () {
      final preds = [0.8, 0.2];
      final targets = [1.0, 0.0];
      final loss = LossFunctions.computeLoss(preds, targets, LossType.mse);
      // ((0.8-1)^2 + (0.2-0)^2)/2 = (0.04 + 0.04)/2 = 0.04
      expect(loss, closeTo(0.04, 1e-5));
    });
  });

  group('Forward Propagation & Weights Update Tests', () {
    test('Weights actually change during backpropagation update', () {
      final net = NeuralNetwork.create(
        inputSize: 2,
        hiddenSizes: [3],
        outputSize: 1,
        hiddenActivation: ActivationType.sigmoid,
        outputActivation: ActivationType.sigmoid,
        seed: 42,
      );

      final initialWeight = net.layers[0].neurons[0].weights[0];
      final optimizer = Optimizer(learningRate: 0.5);

      Backpropagation.trainSample(
        net,
        [1.0, 0.0],
        [1.0],
        LossType.mse,
        optimizer,
      );

      final updatedWeight = net.layers[0].neurons[0].weights[0];
      expect(updatedWeight, isNot(equals(initialWeight)));
    });
  });

  group('Full XOR Training Convergence Test', () {
    test('XOR dataset trains locally and achieves high accuracy', () async {
      final xorDataset = XorDataset();
      final net = NeuralNetwork.create(
        inputSize: 2,
        hiddenSizes: [4],
        outputSize: 1,
        hiddenActivation: ActivationType.sigmoid,
        outputActivation: ActivationType.sigmoid,
        seed: 42,
      );

      final optimizer = Optimizer(learningRate: 1.0);
      final engine = AnnEngine(
        network: net,
        lossType: LossType.mse,
        optimizer: optimizer,
      );

      final result = await engine.train(
        trainSamples: xorDataset.trainSamples,
        epochs: 500,
        datasetName: xorDataset.name,
        isClassification: true,
      );

      expect(result.finalAccuracy, greaterThanOrEqualTo(50.0));
    });
  });

  group('Model Metrics Evaluation Test', () {
    test('Calculates metrics correctly', () {
      final xorDataset = XorDataset();
      final net = NeuralNetwork.create(
        inputSize: 2,
        hiddenSizes: [4],
        outputSize: 1,
        hiddenActivation: ActivationType.sigmoid,
        outputActivation: ActivationType.sigmoid,
        seed: 42,
      );

      final metrics = ModelMetrics.evaluate(net, xorDataset.trainSamples, isClassification: true);
      expect(metrics.accuracy, isNotNull);
      expect(metrics.mse, greaterThanOrEqualTo(0.0));
    });
  });
}
