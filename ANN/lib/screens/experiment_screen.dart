import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/neural_network.dart';
import '../models/training_result.dart';
import '../engine/ann_engine.dart';
import '../engine/loss_functions.dart';
import '../engine/optimizers.dart';
import '../engine/activation_functions.dart';
import '../datasets/dataset_base.dart';
import '../datasets/xor_dataset.dart';
import '../services/settings_service.dart';
import '../core/constants/app_colors.dart';

class ExperimentItem {
  final String name;
  final double learningRate;
  final int hiddenNeurons;
  final ActivationType activation;
  final int epochs;
  TrainingResult? result;

  ExperimentItem({
    required this.name,
    required this.learningRate,
    required this.hiddenNeurons,
    required this.activation,
    required this.epochs,
    this.result,
  });
}

class ExperimentScreen extends StatefulWidget {
  const ExperimentScreen({super.key});

  @override
  State<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen> {
  final AppDataset _dataset = XorDataset();
  bool _isRunning = false;

  final List<ExperimentItem> _experiments = [
    ExperimentItem(
      name: 'Exp A (LR=0.1, Sigmoid)',
      learningRate: 0.1,
      hiddenNeurons: 4,
      activation: ActivationType.sigmoid,
      epochs: 300,
    ),
    ExperimentItem(
      name: 'Exp B (LR=0.5, ReLU)',
      learningRate: 0.5,
      hiddenNeurons: 4,
      activation: ActivationType.relu,
      epochs: 300,
    ),
    ExperimentItem(
      name: 'Exp C (LR=0.01, Tanh)',
      learningRate: 0.01,
      hiddenNeurons: 6,
      activation: ActivationType.tanh,
      epochs: 300,
    ),
  ];

  Future<void> _runAllExperiments() async {
    setState(() {
      _isRunning = true;
    });

    for (var exp in _experiments) {
      final net = NeuralNetwork.create(
        inputSize: _dataset.trainSamples.first.inputs.length,
        hiddenSizes: [exp.hiddenNeurons],
        outputSize: _dataset.trainSamples.first.targets.length,
        hiddenActivation: exp.activation,
        outputActivation: ActivationType.sigmoid,
        seed: 42, // Fixed reproducible seed
      );

      final optimizer = Optimizer(learningRate: exp.learningRate);
      final engine = AnnEngine(
        network: net,
        lossType: LossType.mse,
        optimizer: optimizer,
      );

      final res = await engine.train(
        trainSamples: _dataset.trainSamples,
        valSamples: _dataset.valSamples,
        epochs: exp.epochs,
        datasetName: _dataset.name,
        isClassification: _dataset.isClassification,
      );

      exp.result = res;
      setState(() {});
    }

    setState(() {
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hyperparameter Experiment Suite'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Parallel Configuration Comparison',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Reproducible benchmark testing across hyperparameter setups',
                      style: TextStyle(
                        color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: _isRunning ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.play_arrow_rounded),
                  label: Text(_isRunning ? 'RUNNING...' : 'RUN BENCHMARK'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricBlue),
                  onPressed: _isRunning ? null : _runAllExperiments,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Experiments Comparison Table Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Experiment')),
                    DataColumn(label: Text('Learning Rate')),
                    DataColumn(label: Text('Activation')),
                    DataColumn(label: Text('Final Loss')),
                    DataColumn(label: Text('Accuracy')),
                    DataColumn(label: Text('Duration')),
                  ],
                  rows: _experiments.map((exp) {
                    final res = exp.result;
                    return DataRow(
                      cells: [
                        DataCell(Text(exp.name, style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(exp.learningRate.toString())),
                        DataCell(Text(ActivationFunctions.getName(exp.activation))),
                        DataCell(Text(res != null ? res.finalLoss.toStringAsFixed(4) : '--', style: const TextStyle(fontFamily: 'monospace'))),
                        DataCell(Text(res != null ? '${res.finalAccuracy.toStringAsFixed(1)}%' : '--', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentGreen))),
                        DataCell(Text(res != null ? '${res.trainingDuration.inMilliseconds} ms' : '--')),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
