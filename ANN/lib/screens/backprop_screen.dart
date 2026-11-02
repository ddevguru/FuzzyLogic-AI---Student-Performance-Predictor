import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simulation_service.dart';
import '../services/settings_service.dart';
import '../engine/backpropagation.dart';
import '../engine/loss_functions.dart';
import '../engine/optimizers.dart';
import '../models/backprop_step.dart';
import '../core/constants/app_colors.dart';

class BackpropScreen extends StatefulWidget {
  const BackpropScreen({super.key});

  @override
  State<BackpropScreen> createState() => _BackpropScreenState();
}

class _BackpropScreenState extends State<BackpropScreen> {
  BackpropStepDetail? _stepDetail;
  int _currentSampleIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _executeStep());
  }

  void _executeStep() {
    final simService = context.read<SimulationService>();
    final dataset = simService.selectedDataset;
    final samples = dataset.trainSamples;

    if (samples.isEmpty) return;

    final sample = samples[_currentSampleIndex % samples.length];
    final optimizer = Optimizer(learningRate: 0.1);

    // Make a clone of network so we don't mutate main simulator network unexpectedly during inspection
    final cloneNet = simService.network.copyWith();

    final detail = Backpropagation.trainSample(
      cloneNet,
      sample.inputs,
      sample.targets,
      LossType.mse,
      optimizer,
    );

    setState(() {
      _stepDetail = detail;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simService = context.watch<SimulationService>();
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    final samples = simService.selectedDataset.trainSamples;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backpropagation Step Inspector'),
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
                      'Single Sample Learning Cycle',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sample ${_currentSampleIndex + 1} of ${samples.length} (${simService.selectedDataset.name})',
                      style: TextStyle(
                        color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.skip_next_rounded),
                  label: const Text('NEXT SAMPLE'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricBlue),
                  onPressed: () {
                    setState(() {
                      _currentSampleIndex = (_currentSampleIndex + 1) % samples.length;
                      _executeStep();
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (_stepDetail != null) ...[
              // Step 1: Forward Pass & Error
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.electricBlue.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.electricBlue,
                            shape: BoxShape.circle,
                          ),
                          child: const Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Forward Pass & Prediction Error',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildRow('Inputs (x):', _stepDetail!.inputs.toString()),
                    _buildRow('Target Output (y):', _stepDetail!.targets.toString()),
                    _buildRow('Model Output (ŷ):', _stepDetail!.predictions.map((p) => p.toStringAsFixed(4)).toList().toString()),
                    _buildRow('Sample MSE Loss:', _stepDetail!.loss.toStringAsFixed(6)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Step 2: Layer Deltas & Gradient Calculations
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.gold.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: const Text('2', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Gradient & Delta Calculation (δ = ∂L/∂z)',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._stepDetail!.layerSnapshots.map((snap) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Layer ${snap.layerIndex + 1} Deltas:',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gold),
                            ),
                            Text(
                              snap.neuronDeltas.map((d) => d.toStringAsFixed(6)).toList().toString(),
                              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Step 3: Parameter Updates (Before vs After Diffs)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accentGreen.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppColors.accentGreen,
                            shape: BoxShape.circle,
                          ),
                          child: const Text('3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Weight & Bias Parameter Updates',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ..._stepDetail!.parameterDiffs.take(4).map((diff) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Layer ${diff.layerIndex + 1} Neuron ${diff.neuronIndex + 1}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Weights Old: ${diff.oldWeights.map((w) => w.toStringAsFixed(4)).toList()}',
                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                            ),
                            Text(
                              'Weights New: ${diff.newWeights.map((w) => w.toStringAsFixed(4)).toList()}',
                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.accentGreen),
                            ),
                            Text(
                              'Bias: ${diff.oldBias.toStringAsFixed(4)} → ${diff.newBias.toStringAsFixed(4)}',
                              style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.electricBlue),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          Text(val, style: const TextStyle(fontSize: 13, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
