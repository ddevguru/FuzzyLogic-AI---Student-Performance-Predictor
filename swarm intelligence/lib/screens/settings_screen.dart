import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/algorithm_type.dart';
import '../services/settings_service.dart';
import '../widgets/common/custom_card.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsService settings;
  final VoidCallback onOpenAboutProject;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onOpenAboutProject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Toggle
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Appearance & Theme', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Divider(height: 16),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Dark Mode (Scientific Lab Theme)', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Sleek high-contrast dark theme optimized for simulation visuals', style: TextStyle(fontSize: 12)),
                      value: settings.isDarkMode,
                      activeThumbColor: AppColors.gold,
                      onChanged: (val) => settings.toggleTheme(val),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Reduced Motion', style: TextStyle(fontSize: 14)),
                      subtitle: const Text('Minimize background animation effects for low-power performance', style: TextStyle(fontSize: 12)),
                      value: settings.reducedMotion,
                      activeThumbColor: AppColors.blue,
                      onChanged: (val) => settings.setReducedMotion(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Simulation Defaults
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Simulation Engine Defaults', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Divider(height: 16),

                    // Default Algorithm
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Default Startup Algorithm:', style: TextStyle(fontSize: 13)),
                        DropdownButton<AlgorithmType>(
                          value: settings.defaultAlgorithm,
                          dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
                          items: AlgorithmType.values
                              .map((a) => DropdownMenuItem(value: a, child: Text(a.fullName)))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) settings.setDefaultAlgorithm(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Default Simulation Speed
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Step Refresh Rate:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            Text('${settings.simulationSpeedMs}ms per iteration', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                        DropdownButton<int>(
                          value: settings.simulationSpeedMs,
                          dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
                          items: const [
                            DropdownMenuItem(value: 300, child: Text('Slow (300ms)')),
                            DropdownMenuItem(value: 120, child: Text('Normal (120ms)')),
                            DropdownMenuItem(value: 50, child: Text('Fast (50ms)')),
                            DropdownMenuItem(value: 20, child: Text('Turbo (20ms)')),
                          ],
                          onChanged: (val) {
                            if (val != null) settings.setSimulationSpeed(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Default Agent Count
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Default Agent Population:', style: TextStyle(fontSize: 13)),
                        DropdownButton<int>(
                          value: settings.defaultAgentCount,
                          dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
                          items: const [
                            DropdownMenuItem(value: 15, child: Text('15 Agents')),
                            DropdownMenuItem(value: 25, child: Text('25 Agents')),
                            DropdownMenuItem(value: 40, child: Text('40 Agents')),
                            DropdownMenuItem(value: 60, child: Text('60 Agents')),
                          ],
                          onChanged: (val) {
                            if (val != null) settings.setDefaultAgentCount(val);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Default Iterations
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Default Maximum Iterations:', style: TextStyle(fontSize: 13)),
                        DropdownButton<int>(
                          value: settings.defaultIterations,
                          dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
                          items: const [
                            DropdownMenuItem(value: 50, child: Text('50 Iterations')),
                            DropdownMenuItem(value: 80, child: Text('80 Iterations')),
                            DropdownMenuItem(value: 120, child: Text('120 Iterations')),
                            DropdownMenuItem(value: 200, child: Text('200 Iterations')),
                          ],
                          onChanged: (val) {
                            if (val != null) settings.setDefaultIterations(val);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Reset Settings
              CustomCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Reset All Settings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        Text('Restore factory defaults and clear cache', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        settings.resetDefaults();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Settings restored to factory defaults.')),
                        );
                      },
                      icon: const Icon(Icons.restore_rounded, size: 16),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // About Project & Viva Guide
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 20),
                        SizedBox(width: 8),
                        Text('About Swarm Intelligence Lab', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                    const Divider(height: 16),
                    const Text(
                      'Swarm Intelligence Lab is an interactive educational suite designed for engineering students, researchers, and viva presentations. The software operates 100% offline without requiring any server, API, or database connection.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    const Text('• Version: 1.0.0 (Production Release)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const Text('• Framework: Flutter & Dart 3.10+ Material 3', style: TextStyle(fontSize: 12)),
                    const Text('• Algorithms: Ant Colony, Particle Swarm, Artificial Bee Colony', style: TextStyle(fontSize: 12)),
                    const Text('• Execution: 100% Client-Side Pure Computational Intelligence', style: TextStyle(fontSize: 12, color: AppColors.green)),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: onOpenAboutProject,
                        icon: const Icon(Icons.school_rounded, size: 16),
                        label: const Text('Academic Project Details'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
