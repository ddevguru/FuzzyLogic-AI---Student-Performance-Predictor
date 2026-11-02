import 'package:flutter/material.dart';
import '../models/neuron.dart';
import '../engine/activation_functions.dart';
import '../core/constants/app_colors.dart';

class NeuronDetailsCard extends StatelessWidget {
  final int layerIndex;
  final int neuronIndex;
  final Neuron neuron;
  final ActivationType activationType;
  final VoidCallback onClose;

  const NeuronDetailsCard({
    super.key,
    required this.layerIndex,
    required this.neuronIndex,
    required this.neuron,
    required this.activationType,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.gold),
                    ),
                    child: Text(
                      'Layer $layerIndex • Neuron ${neuronIndex + 1}',
                      style: TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: onClose,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Mathematical Formula',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Weighted Sum:  z = ∑ (wᵢ · xᵢ) + b',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: isDark ? Colors.cyanAccent : AppColors.electricBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Activation Output:  a = ${ActivationFunctions.getName(activationType)}(z)',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Calculation Details',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow('Bias (b):', neuron.bias.toStringAsFixed(4), isDark),
          _buildDetailRow('Weighted Sum (z):', neuron.z.toStringAsFixed(4), isDark),
          _buildDetailRow('Final Output (a):', neuron.output.toStringAsFixed(4), isDark),
          if (neuron.delta != 0.0)
            _buildDetailRow('Gradient (δ):', neuron.delta.toStringAsFixed(6), isDark),
          const SizedBox(height: 12),
          Text(
            'Incoming Weights & Inputs',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: neuron.weights.length,
              itemBuilder: (context, idx) {
              final w = neuron.weights[idx];
              final x = idx < neuron.lastInputs.length ? neuron.lastInputs[idx] : 0.0;
              final prod = w * x;

              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: w >= 0 ? AppColors.weightPositive.withOpacity(0.4) : AppColors.weightNegative.withOpacity(0.4),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('w$idx: ${w.toStringAsFixed(3)}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    Text('x$idx: ${x.toStringAsFixed(3)}', style: const TextStyle(fontSize: 11)),
                    const Divider(height: 8),
                    Text('w·x = ${prod.toStringAsFixed(3)}', style: const TextStyle(fontSize: 11, color: AppColors.electricBlue, fontWeight: FontWeight.w600)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ),
  );
  }

  Widget _buildDetailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
