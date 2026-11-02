import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/real_world_app.dart';

class ApplicationDetailScreen extends StatelessWidget {
  final RealWorldApp app;

  const ApplicationDetailScreen({super.key, required this.app});

  static void show(BuildContext context, RealWorldApp app) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ApplicationDetailScreen(app: app),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.blue.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(app.icon, size: 32, color: AppColors.blue),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.gold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                app.category.toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.gold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              app.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildCard(
                    title: 'PROBLEM DESCRIPTION',
                    content: app.problemDescription,
                    icon: Icons.error_outline_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    title: 'TRADITIONAL METHOD CHALLENGE',
                    content: app.traditionalChallenge,
                    icon: Icons.warning_amber_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    title: 'GENETIC ALGORITHM SOLUTION',
                    content: app.gaSolution,
                    icon: Icons.auto_awesome_rounded,
                    isDark: isDark,
                    highlightColor: AppColors.gold,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    title: 'CHROMOSOME REPRESENTATION',
                    content: app.chromosomeRepresentation,
                    icon: Icons.code_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    title: 'FITNESS FUNCTION',
                    content: app.fitnessFunction,
                    icon: Icons.functions_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    title: 'SELECTION / CROSSOVER / MUTATION STRATEGY',
                    content: '• Selection: ${app.selectionStrategy}\n• Crossover: ${app.crossoverStrategy}\n• Mutation: ${app.mutationStrategy}',
                    icon: Icons.alt_route_rounded,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildCard(
                    title: 'EXPECTED OUTPUT & REAL WORLD CASE',
                    content: 'Output: ${app.expectedOutput}\n\nReal-World Case: ${app.realWorldExample}',
                    icon: Icons.domain_rounded,
                    isDark: isDark,
                    highlightColor: AppColors.green,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required String content,
    required IconData icon,
    required bool isDark,
    Color? highlightColor,
  }) {
    final effectiveColor = highlightColor ?? AppColors.blue;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlightColor?.withOpacity(0.5) ??
              (isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: effectiveColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: effectiveColor,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
