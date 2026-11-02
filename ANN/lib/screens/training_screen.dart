import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/training_service.dart';
import '../services/simulation_service.dart';
import '../services/settings_service.dart';
import '../widgets/training_chart.dart';
import '../widgets/decision_boundary_visualizer.dart';
import '../widgets/regression_curve_visualizer.dart';
import '../widgets/parameter_controls.dart';
import '../datasets/dataset_base.dart';
import '../core/constants/app_colors.dart';
import 'backprop_screen.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trainService = context.watch<TrainingService>();
    final simService = context.watch<SimulationService>();
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    final isTraining = trainService.isTraining;
    final isPaused = trainService.isPaused;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Train Your Neural Network',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Dataset: ${trainService.dataset.name}',
                    style: TextStyle(
                      color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              _buildStatusBadge(isTraining, isPaused),
            ],
          ),
          const SizedBox(height: 16),

          // Primary Controls Bar (Train, Pause/Resume, Stop, Reset, Backprop Inspection)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.start,
              children: [
                if (!isTraining)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: const Text('TRAIN MODEL'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricBlue),
                    onPressed: () {
                      trainService.startTraining(simService.network);
                    },
                  )
                else ...[
                  if (isPaused)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('RESUME'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentGreen),
                      onPressed: () => trainService.resumeTraining(),
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.pause_rounded),
                      label: const Text('PAUSE'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
                      onPressed: () => trainService.pauseTraining(),
                    ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.stop_rounded),
                    label: const Text('STOP'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () => trainService.stopTraining(),
                  ),
                ],
                OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('RESET'),
                  onPressed: () {
                    trainService.resetTrainingState();
                    simService.resetNetwork();
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.find_in_page_rounded, color: AppColors.gold),
                  label: const Text('INSPECT BACKPROP', style: TextStyle(color: AppColors.gold)),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const BackpropScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Live Training Stats Grid
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.8,
            children: [
              _buildStatCard('Epoch', '${trainService.currentEpoch} / ${trainService.epochs}', isDark),
              _buildStatCard('Loss', trainService.currentTrainLoss.toStringAsFixed(4), isDark),
              _buildStatCard(
                'Accuracy',
                trainService.dataset.isClassification
                    ? '${trainService.currentTrainAccuracy.toStringAsFixed(1)}%'
                    : 'N/A (Regression)',
                isDark,
              ),
              _buildStatCard('Learning Rate', trainService.learningRate.toStringAsFixed(3), isDark),
            ],
          ),
          const SizedBox(height: 20),

          // Training Curves Chart Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Loss vs Epoch Curve',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Icon(Icons.show_chart_rounded, color: AppColors.electricBlue),
                  ],
                ),
                const SizedBox(height: 12),
                TrainingChart(
                  epochMetrics: trainService.liveEpochHistory,
                  isDarkMode: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Visual Model Predictions Output (Decision Boundary or Curve Fit)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  trainService.dataset.isClassification
                      ? 'Decision Boundary Visualization'
                      : 'Function Approximation Curve Fit',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                if (trainService.dataset.type == DatasetType.functionRegression)
                  RegressionCurveVisualizer(
                    network: simService.network,
                    samples: trainService.dataset.trainSamples,
                  )
                else
                  DecisionBoundaryVisualizer(
                    network: simService.network,
                    samples: trainService.dataset.trainSamples,
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Parameter Tuning Controls
          ParameterControls(
            learningRate: trainService.learningRate,
            epochs: trainService.epochs,
            hiddenLayers: simService.numHiddenLayers,
            neuronsPerHidden: simService.numNeuronsPerHidden,
            activationType: simService.hiddenActivation,
            selectedDataset: trainService.dataset,
            onLearningRateChanged: (v) => trainService.setHyperparameters(learningRate: v),
            onEpochsChanged: (v) => trainService.setHyperparameters(epochs: v),
            onHiddenLayersChanged: (v) {
              simService.updateArchitecture(hiddenLayers: v);
              trainService.setHyperparameters(numHiddenLayers: v);
            },
            onNeuronsChanged: (v) {
              simService.updateArchitecture(neuronsPerHidden: v);
              trainService.setHyperparameters(neuronsPerHidden: v);
            },
            onActivationChanged: (v) {
              simService.updateArchitecture(hiddenActivation: v);
              trainService.setHyperparameters(hiddenActivation: v);
            },
            onDatasetChanged: (ds) {
              trainService.selectDataset(ds);
              simService.setDataset(ds);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isTraining, bool isPaused) {
    String text = 'IDLE';
    Color color = Colors.grey;
    if (isTraining) {
      if (isPaused) {
        text = 'PAUSED';
        color = AppColors.gold;
      } else {
        text = 'TRAINING...';
        color = AppColors.accentGreen;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
