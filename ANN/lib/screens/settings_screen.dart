import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';
import '../core/constants/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings & Preferences',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Customize lab themes, animation speed, and default engine hyperparameters',
            style: TextStyle(
              color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // Theme Settings Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Visual Theme', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Dark Theme Mode'),
                  subtitle: const Text('Sleek dark AI laboratory visual design'),
                  value: settings.isDarkMode,
                  activeColor: AppColors.electricBlue,
                  onChanged: (_) => settings.toggleTheme(),
                ),
                SwitchListTile(
                  title: const Text('Reduced Motion'),
                  subtitle: const Text('Disables signal propagation pulse animations for low-spec performance'),
                  value: settings.reducedAnimations,
                  activeColor: AppColors.gold,
                  onChanged: (val) => settings.setReducedAnimations(val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Default Hyperparameters Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Default Engine Parameters', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListTile(
                  title: const Text('Default Learning Rate (η)'),
                  trailing: Text(settings.defaultLearningRate.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                ),
                ListTile(
                  title: const Text('Default Training Epochs'),
                  trailing: Text('${settings.defaultEpochs}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                ),
                ListTile(
                  title: const Text('Default Hidden Neurons'),
                  trailing: Text('${settings.defaultHiddenNeurons}', style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace')),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.restore_rounded),
                  label: const Text('Reset All Settings to Defaults'),
                  onPressed: () => settings.resetToDefaults(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // About Project Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withOpacity(0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.science_rounded, color: AppColors.gold, size: 28),
                    const SizedBox(width: 12),
                    Text(
                      'About ANN Intelligence Lab',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  'ANN Intelligence Lab is a production-quality, 100% offline educational Flutter application designed for engineering major/minor projects, viva demonstrations, and Artificial Neural Network coursework.',
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                const Text('Framework: Flutter (Dart 3)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const Text('Execution Engine: Native Client-side Pure Dart ANN Engine', style: TextStyle(fontSize: 12)),
                const Text('Version: 1.0.0 (Offline Production)', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
