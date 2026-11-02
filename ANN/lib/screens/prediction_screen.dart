import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simulation_service.dart';
import '../services/training_service.dart';
import '../services/settings_service.dart';
import '../models/prediction_result.dart';
import '../core/constants/app_colors.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({super.key});

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  PredictionResult? _latestPrediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simService = context.watch<SimulationService>();
    final trainService = context.watch<TrainingService>();
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    final dataset = simService.selectedDataset;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prediction Playground',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Enter feature inputs and execute forward inference on current network weights',
            style: TextStyle(
              color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),

          // Untrained Network Warning Banner (if no training run performed yet)
          if (trainService.networksTrainedCount == 0) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.gold),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'The network is currently using random initial weights. For accurate predictions, train your model first.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Input Slider Form Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Input Features (${dataset.featureNames.join(', ')})',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...List.generate(simService.currentInputs.length, (idx) {
                  final featureName = idx < dataset.featureNames.length
                      ? dataset.featureNames[idx]
                      : 'Feature ${idx + 1}';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(featureName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(
                              simService.currentInputs[idx].toStringAsFixed(2),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                        Slider(
                          value: simService.currentInputs[idx],
                          min: -1.0,
                          max: 1.0,
                          divisions: 40,
                          activeColor: AppColors.electricBlue,
                          onChanged: (val) {
                            simService.setSingleInput(idx, val);
                          },
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.psychology_rounded),
                    label: const Text('RUN PREDICTION'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      final pred = simService.predict(simService.currentInputs);
                      setState(() {
                        _latestPrediction = pred;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Output Prediction Display Card
          if (_latestPrediction != null) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.accentGreen.withOpacity(0.6),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentGreen.withOpacity(0.1),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Prediction Results',
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _latestPrediction!.label,
                          style: const TextStyle(
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildResultRow('Network Architecture:', simService.network.architectureSummary),
                  _buildResultRow('Raw Model Output Vector:', _latestPrediction!.outputs.map((o) => o.toStringAsFixed(4)).toList().toString()),
                  if (_latestPrediction!.isClassification)
                    _buildResultRow('Calibrated Confidence:', '${(_latestPrediction!.confidence * 100).toStringAsFixed(1)}%'),
                  const SizedBox(height: 16),

                  // Visual Bar / Gauge Representation
                  Text(
                    'Visual Output Intensity',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: _latestPrediction!.outputs[0].clamp(0.0, 1.0),
                      minHeight: 14,
                      backgroundColor: Colors.grey.shade800,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _latestPrediction!.outputs[0] >= 0.5 ? AppColors.accentGreen : AppColors.electricBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
