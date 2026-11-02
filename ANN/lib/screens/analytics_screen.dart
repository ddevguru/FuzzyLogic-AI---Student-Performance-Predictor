import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/training_service.dart';
import '../services/simulation_service.dart';
import '../services/settings_service.dart';
import '../widgets/training_chart.dart';
import '../widgets/metric_card.dart';
import '../engine/metrics.dart';
import '../core/constants/app_colors.dart';
import 'experiment_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trainService = context.watch<TrainingService>();
    final simService = context.watch<SimulationService>();
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    final latestResult = trainService.latestResult;
    final isClassification = trainService.dataset.isClassification;

    // Calculate real metrics using engine
    final currentMetrics = ModelMetrics.evaluate(
      simService.network,
      trainService.dataset.trainSamples,
      isClassification: isClassification,
    );

    return SingleChildScrollView(
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
                    'Analytics & Evaluation',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Real-time loss metrics, accuracy, precision, recall & MSE calculations',
                    style: TextStyle(
                      color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.science_rounded),
                label: const Text('EXPERIMENT SUITE'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: Colors.black),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ExperimentScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Real Evaluation Metrics Grid
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.6,
            children: [
              MetricCard(
                title: 'Training Loss (MSE)',
                value: currentMetrics.mse.toStringAsFixed(4),
                subtitle: 'Mean Squared Error',
                icon: Icons.trending_down_rounded,
                iconColor: AppColors.electricBlue,
              ),
              MetricCard(
                title: isClassification ? 'Classification Accuracy' : 'Mean Abs Error (MAE)',
                value: isClassification
                    ? '${currentMetrics.accuracy.toStringAsFixed(1)}%'
                    : currentMetrics.mae.toStringAsFixed(4),
                subtitle: isClassification ? 'Accuracy rate' : 'Mean Absolute Error',
                icon: Icons.check_circle_rounded,
                iconColor: AppColors.accentGreen,
              ),
              MetricCard(
                title: 'Precision / Recall',
                value: isClassification
                    ? '${(currentMetrics.precision * 100).toStringAsFixed(0)}% / ${(currentMetrics.recall * 100).toStringAsFixed(0)}%'
                    : '--',
                subtitle: 'Binary metrics',
                icon: Icons.analytics_rounded,
                iconColor: AppColors.gold,
              ),
              MetricCard(
                title: 'F1-Score',
                value: isClassification ? currentMetrics.f1Score.toStringAsFixed(3) : '--',
                subtitle: 'Harmonic mean',
                icon: Icons.pie_chart_rounded,
                iconColor: Colors.purpleAccent,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Loss vs Epoch Chart Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Training Loss Convergence Curve',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TrainingChart(
                  epochMetrics: trainService.liveEpochHistory,
                  showAccuracy: false,
                  isDarkMode: isDark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Accuracy vs Epoch Chart Card (if classification)
          if (isClassification) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Training Accuracy Progression (%)',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  TrainingChart(
                    epochMetrics: trainService.liveEpochHistory,
                    showAccuracy: true,
                    isDarkMode: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // Session Summary Box
          if (latestResult != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Completed Session Summary',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.gold),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow('Dataset:', latestResult.datasetName),
                  _buildSummaryRow('Architecture:', latestResult.architectureSummary),
                  _buildSummaryRow('Total Epochs:', '${latestResult.totalEpochs}'),
                  _buildSummaryRow('Training Duration:', '${latestResult.trainingDuration.inMilliseconds} ms'),
                  _buildSummaryRow('Final Loss:', latestResult.finalLoss.toStringAsFixed(6)),
                  _buildSummaryRow('Final Accuracy:', '${latestResult.finalAccuracy.toStringAsFixed(1)}%'),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
