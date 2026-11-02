import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../core/constants/app_colors.dart';

class ArchitectureStep {
  final int stepNum;
  final String title;
  final String whatHappens;
  final String whyRequired;
  final String implementationDetail;
  final String outputProduced;

  const ArchitectureStep({
    required this.stepNum,
    required this.title,
    required this.whatHappens,
    required this.whyRequired,
    required this.implementationDetail,
    required this.outputProduced,
  });
}

class HowAnnWorksScreen extends StatelessWidget {
  const HowAnnWorksScreen({super.key});

  final List<ArchitectureStep> _steps = const [
    ArchitectureStep(
      stepNum: 1,
      title: 'Dataset Selection & Batch Loading',
      whatHappens: 'The user selects a local dataset (XOR, 2D Circles, or Sine Wave). Training sample feature vectors are loaded into memory.',
      whyRequired: 'Neural networks require numerical training vectors with input features and expected target labels to perform supervised learning.',
      implementationDetail: 'Implemented in lib/datasets/ as strongly typed Dart classes returning List<TrainingSample>.',
      outputProduced: 'List of TrainingSample objects containing normalized feature arrays and target labels.',
    ),
    ArchitectureStep(
      stepNum: 2,
      title: 'Network Architecture Instantiation',
      whatHappens: 'The app constructs a multi-layer NeuralNetwork object with specified input nodes, hidden layers, and output nodes.',
      whyRequired: 'Defines the mathematical dimension matrices and parameter capacities for processing feature signals.',
      implementationDetail: 'Implemented in lib/models/neural_network.dart and lib/models/dense_layer.dart.',
      outputProduced: 'A structured network graph containing input dimensions, layer objects, and neuron vectors.',
    ),
    ArchitectureStep(
      stepNum: 3,
      title: 'Xavier / He Weight & Bias Initialization',
      whatHappens: 'Random weights and small non-zero biases are initialized using Glorot or He normal distribution scaling.',
      whyRequired: 'Prevents symmetric neuron activations during initial forward propagation.',
      implementationDetail: 'Implemented in lib/core/utils/math_utils.dart and DenseLayer.random().',
      outputProduced: 'Initialized weight matrices W and bias vectors B.',
    ),
    ArchitectureStep(
      stepNum: 4,
      title: 'Forward Propagation Signal Processing',
      whatHappens: 'Input vector x passes through layers calculating z = Wx + b and activation a = f(z).',
      whyRequired: 'Transforms raw input feature signals into intermediate non-linear representations and final predictions.',
      implementationDetail: 'Implemented in lib/engine/activation_functions.dart and DenseLayer.forward().',
      outputProduced: 'Activated layer outputs and final prediction vector ŷ.',
    ),
    ArchitectureStep(
      stepNum: 5,
      title: 'Loss & Error Computation',
      whatHappens: 'Loss function calculates scalar prediction error between model predictions ŷ and target labels y.',
      whyRequired: 'Quantifies exact error magnitude to guide gradient descent optimization.',
      implementationDetail: 'Implemented in lib/engine/loss_functions.dart (MSE, BCE, CCE).',
      outputProduced: 'Scalar Loss value L.',
    ),
    ArchitectureStep(
      stepNum: 6,
      title: 'Backpropagation Gradient Derivative Calculation',
      whatHappens: 'Chain-rule partial derivatives calculate error gradients δ for output and hidden layers.',
      whyRequired: 'Determines the direction and magnitude by which each weight must change to minimize error.',
      implementationDetail: 'Implemented in lib/engine/backpropagation.dart.',
      outputProduced: 'Layer delta vectors δ and weight gradient matrices dW, dB.',
    ),
    ArchitectureStep(
      stepNum: 7,
      title: 'Stochastic Gradient Descent Parameter Update',
      whatHappens: 'Optimizer updates weights w = w - η · dW and biases b = b - η · dB.',
      whyRequired: 'Adjusts parameter knobs to decrease total dataset prediction error.',
      implementationDetail: 'Implemented in lib/engine/optimizers.dart.',
      outputProduced: 'Updated NeuralNetwork parameter state.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('How ANN Works Inside This App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local Dart Engine Architecture Breakdown',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'A step-by-step technical guide mapping mathematical theory to local Dart code execution',
              style: TextStyle(
                color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _steps.length,
              itemBuilder: (context, idx) {
                final step = _steps[idx];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.electricBlue.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: AppColors.electricBlue,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${step.stepNum}',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step.title,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildBlock('What happens?', step.whatHappens, isDark),
                      _buildBlock('Why is it required?', step.whyRequired, isDark),
                      _buildBlock('How is it implemented in this app?', step.implementationDetail, isDark, isCode: true),
                      _buildBlock('What output does it produce?', step.outputProduced, isDark),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlock(String label, String content, bool isDark, {bool isCode = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold),
          ),
          const SizedBox(height: 2),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              fontFamily: isCode ? 'monospace' : null,
              color: isCode ? Colors.cyanAccent : (isDark ? AppColors.textMainDark : AppColors.textMainLight),
            ),
          ),
        ],
      ),
    );
  }
}
