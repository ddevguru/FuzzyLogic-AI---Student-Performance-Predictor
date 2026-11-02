import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../services/settings_service.dart';
import '../../services/simulation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_header.dart';
import '../about/about_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Application Settings',
                subtitle: 'Customize theme appearance, animation speed, and default GA hyperparameters.',
                icon: Icons.settings_rounded,
              ),

              const SizedBox(height: 12),

              // Theme Settings Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('APPEARANCE & THEME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded, color: AppColors.blue),
                            const SizedBox(width: 10),
                            Text(isDark ? 'Dark Theme Active' : 'Light Theme Active', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Switch.adaptive(
                          value: settings.isDarkMode,
                          activeColor: AppColors.gold,
                          onChanged: (val) => settings.toggleTheme(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Speed Settings Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('DEFAULT SIMULATION SPEED', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: settings.animationSpeedMs,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      items: const [
                        DropdownMenuItem(value: 800, child: Text('Slow (800ms per generation)')),
                        DropdownMenuItem(value: 350, child: Text('Normal (350ms per generation)')),
                        DropdownMenuItem(value: 80, child: Text('Fast (80ms per generation)')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          settings.setAnimationSpeed(val);
                          Provider.of<SimulationService>(context, listen: false).setSpeed(val);
                        }
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // About & Reset Action Buttons
              CustomButton(
                label: 'ABOUT GENETIC OPTIMIZATION LAB',
                icon: Icons.info_outline_rounded,
                isOutlined: true,
                color: AppColors.blue,
                width: double.infinity,
                onPressed: () => AboutScreen.show(context),
              ),

              const SizedBox(height: 12),

              CustomButton(
                label: 'RESET DEFAULT SETTINGS',
                icon: Icons.restore_rounded,
                isOutlined: true,
                color: AppColors.accentRed,
                width: double.infinity,
                onPressed: () {
                  settings.resetSettings();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings restored to defaults.')),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
