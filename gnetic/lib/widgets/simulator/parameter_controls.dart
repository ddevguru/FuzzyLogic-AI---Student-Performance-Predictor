import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/ga_config.dart';
import '../common/info_tooltip_button.dart';

class ParameterControls extends StatelessWidget {
  final GAConfig config;
  final ValueChanged<GAConfig> onChanged;

  const ParameterControls({
    super.key,
    required this.config,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ExpansionTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      collapsedBackgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      title: Row(
        children: const [
          Icon(Icons.tune_rounded, color: AppColors.blue, size: 20),
          SizedBox(width: 8),
          Text(
            'GA Hyperparameters Configuration',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
      subtitle: Text(
        'Pop: ${config.populationSize} | Gen: ${config.maxGenerations} | Mut: ${(config.mutationRate * 100).toStringAsFixed(1)}% | Cross: ${(config.crossoverRate * 100).toStringAsFixed(0)}%',
        style: TextStyle(
          fontSize: 11,
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Population Size Slider
              _buildSliderRow(
                context: context,
                label: 'Population Size',
                valueStr: '${config.populationSize} individuals',
                value: config.populationSize.toDouble(),
                min: 10,
                max: 200,
                divisions: 19,
                infoTopicKey: 'Population',
                onChanged: (val) => onChanged(config.copyWith(populationSize: val.toInt())),
              ),
              const SizedBox(height: 12),
              // Max Generations Slider
              _buildSliderRow(
                context: context,
                label: 'Max Generations',
                valueStr: '${config.maxGenerations} gens',
                value: config.maxGenerations.toDouble(),
                min: 10,
                max: 300,
                divisions: 29,
                infoTopicKey: 'Generation',
                onChanged: (val) => onChanged(config.copyWith(maxGenerations: val.toInt())),
              ),
              const SizedBox(height: 12),
              // Mutation Rate Slider
              _buildSliderRow(
                context: context,
                label: 'Mutation Rate',
                valueStr: '${(config.mutationRate * 100).toStringAsFixed(1)}%',
                value: config.mutationRate,
                min: 0.0,
                max: 0.30,
                divisions: 30,
                infoTopicKey: 'Mutation',
                onChanged: (val) => onChanged(config.copyWith(mutationRate: val)),
              ),
              const SizedBox(height: 12),
              // Crossover Rate Slider
              _buildSliderRow(
                context: context,
                label: 'Crossover Rate',
                valueStr: '${(config.crossoverRate * 100).toStringAsFixed(0)}%',
                value: config.crossoverRate,
                min: 0.1,
                max: 1.0,
                divisions: 18,
                infoTopicKey: 'Crossover',
                onChanged: (val) => onChanged(config.copyWith(crossoverRate: val)),
              ),
              const SizedBox(height: 12),
              // Elitism Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Text(
                        'Elitism (Preserve Top 2 Fittest)',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      SizedBox(width: 6),
                      InfoTooltipButton(topicKey: 'Elitism', size: 16),
                    ],
                  ),
                  Switch.adaptive(
                    value: config.elitism,
                    activeTrackColor: AppColors.gold,
                    onChanged: (val) => onChanged(config.copyWith(elitism: val)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow({
    required BuildContext context,
    required String label,
    required String valueStr,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String infoTopicKey,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                const SizedBox(width: 6),
                InfoTooltipButton(topicKey: infoTopicKey, size: 16),
              ],
            ),
            Text(
              valueStr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.blue,
              ),
            ),
          ],
        ),
        Slider.adaptive(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppColors.blue,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
