import 'package:flutter/material.dart';
import '../engine/activation_functions.dart';
import '../datasets/dataset_base.dart';
import '../datasets/xor_dataset.dart';
import '../datasets/classification_dataset.dart';
import '../datasets/regression_dataset.dart';
import '../core/constants/app_colors.dart';

class ParameterControls extends StatelessWidget {
  final double learningRate;
  final int epochs;
  final int hiddenLayers;
  final int neuronsPerHidden;
  final ActivationType activationType;
  final AppDataset selectedDataset;
  final ValueChanged<double>? onLearningRateChanged;
  final ValueChanged<int>? onEpochsChanged;
  final ValueChanged<int>? onHiddenLayersChanged;
  final ValueChanged<int>? onNeuronsChanged;
  final ValueChanged<ActivationType>? onActivationChanged;
  final ValueChanged<AppDataset>? onDatasetChanged;

  const ParameterControls({
    super.key,
    required this.learningRate,
    required this.epochs,
    required this.hiddenLayers,
    required this.neuronsPerHidden,
    required this.activationType,
    required this.selectedDataset,
    this.onLearningRateChanged,
    this.onEpochsChanged,
    this.onHiddenLayersChanged,
    this.onNeuronsChanged,
    this.onActivationChanged,
    this.onDatasetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
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
            'Hyperparameters & Dataset',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Dataset Selector
          if (onDatasetChanged != null) ...[
            Text('Dataset Selection', style: _labelStyle(isDark)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDatasetChip(context, XorDataset(), 'XOR Gate'),
                _buildDatasetChip(context, BinaryClassificationDataset(), '2D Circles'),
                _buildDatasetChip(context, FunctionRegressionDataset(), 'Sine Wave'),
              ],
            ),
            const SizedBox(height: 16),
          ],
          // Learning Rate Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Learning Rate (η):', style: _labelStyle(isDark)),
              Text(
                learningRate.toStringAsFixed(3),
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          Slider(
            value: learningRate,
            min: 0.001,
            max: 1.0,
            divisions: 100,
            activeColor: AppColors.electricBlue,
            onChanged: onLearningRateChanged,
          ),
          // Training Epochs Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Training Epochs:', style: _labelStyle(isDark)),
              Text(
                '$epochs',
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          Slider(
            value: epochs.toDouble(),
            min: 10,
            max: 1000,
            divisions: 99,
            activeColor: AppColors.gold,
            onChanged: onEpochsChanged != null ? (v) => onEpochsChanged!(v.toInt()) : null,
          ),
          // Hidden Layers Count
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hidden Layers:', style: _labelStyle(isDark)),
              Text(
                '$hiddenLayers',
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          Slider(
            value: hiddenLayers.toDouble(),
            min: 1,
            max: 4,
            divisions: 3,
            activeColor: AppColors.accentGreen,
            onChanged: onHiddenLayersChanged != null ? (v) => onHiddenLayersChanged!(v.toInt()) : null,
          ),
          // Neurons per Layer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Neurons per Hidden Layer:', style: _labelStyle(isDark)),
              Text(
                '$neuronsPerHidden',
                style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ],
          ),
          Slider(
            value: neuronsPerHidden.toDouble(),
            min: 1,
            max: 12,
            divisions: 11,
            activeColor: AppColors.electricBlue,
            onChanged: onNeuronsChanged != null ? (v) => onNeuronsChanged!(v.toInt()) : null,
          ),
          const SizedBox(height: 8),
          // Activation Function Dropdown/Segmented
          Text('Hidden Activation Function:', style: _labelStyle(isDark)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ActivationType.sigmoid,
              ActivationType.relu,
              ActivationType.tanh,
              ActivationType.linear,
            ].map((type) {
              final isSelected = type == activationType;
              return ChoiceChip(
                label: Text(ActivationFunctions.getName(type)),
                selected: isSelected,
                selectedColor: AppColors.gold,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : (isDark ? Colors.white : Colors.black87),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                onSelected: onActivationChanged != null ? (_) => onActivationChanged!(type) : null,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  TextStyle _labelStyle(bool isDark) {
    return TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
    );
  }

  Widget _buildDatasetChip(BuildContext context, AppDataset ds, String label) {
    final isSelected = selectedDataset.type == ds.type;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.electricBlue,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) {
        if (onDatasetChanged != null) onDatasetChanged!(ds);
      },
    );
  }
}
