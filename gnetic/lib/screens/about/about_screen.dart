import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AboutScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final techDetails = [
      ('Project Title', AppConstants.appTitle),
      ('Subtitle', AppConstants.appSubtitle),
      ('Version', AppConstants.appVersion),
      ('Technology Stack', 'Flutter 3.x + Dart 3.x (100% Offline)'),
      ('Backend Dependency', 'None (No Firebase, No DB, No REST API)'),
      ('Algorithm Engine', 'Genetic Algorithm written natively in Dart'),
      ('Benchmark Domains', 'Function Opt, Knapsack, TSP, Scheduling'),
      ('Purpose', 'Engineering College Project Viva & Academic Demo'),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.gold, width: 2),
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 40),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          AppConstants.appTitle,
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          AppConstants.appSubtitle,
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('PROJECT TECHNICAL ARCHITECTURE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gold)),
                  const SizedBox(height: 10),
                  Table(
                    border: TableBorder.all(color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder),
                    children: techDetails.map((row) {
                      return TableRow(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(row.$2, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : AppColors.lightTextPrimary)),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.offline_pin_rounded, color: AppColors.green, size: 24),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '100% Offline Local Calculation: The complete Genetic Algorithm population evaluation, tournament selection, single-point / ordered crossover, and bit-flip / swap mutations run locally on-device inside native Dart code without any mock data or remote network servers.',
                            style: TextStyle(fontSize: 12, color: AppColors.green, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
