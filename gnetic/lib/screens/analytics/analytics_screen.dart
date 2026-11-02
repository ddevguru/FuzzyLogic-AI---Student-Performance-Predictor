import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatting_utils.dart';
import '../../services/simulation_service.dart';
import '../../widgets/charts/fitness_progress_chart.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/common/stat_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SimulationService>(
      builder: (context, simService, child) {
        final analytics = simService.analytics;
        final history = simService.engine.generationHistory;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Analytics & Performance Dashboard',
                subtitle: 'Session performance metrics, convergence trends, and evolutionary statistics.',
                icon: Icons.analytics_rounded,
              ),

              const SizedBox(height: 12),

              // Metrics Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossCount = constraints.maxWidth > 600 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: constraints.maxWidth > 600 ? 1.6 : 1.3,
                    children: [
                      StatCard(
                        title: 'Total Simulations',
                        value: '${analytics.totalSimulationsRun}',
                        subtitle: 'Completed Runs',
                        icon: Icons.play_circle_fill_rounded,
                        accentColor: AppColors.blue,
                      ),
                      StatCard(
                        title: 'Max Fitness Reached',
                        value: FormattingUtils.formatFitness(analytics.overallBestFitness),
                        subtitle: 'Session Record',
                        icon: Icons.emoji_events_rounded,
                        accentColor: AppColors.gold,
                      ),
                      StatCard(
                        title: 'Avg Convergence',
                        value: '${analytics.averageGenerations.toStringAsFixed(1)}',
                        subtitle: 'Generations',
                        icon: Icons.speed_rounded,
                        accentColor: AppColors.green,
                      ),
                      StatCard(
                        title: 'Avg Improvement',
                        value: '+${analytics.averageImprovement.toStringAsFixed(1)}%',
                        subtitle: 'Fitness Boost',
                        icon: Icons.trending_up_rounded,
                        accentColor: AppColors.blueLight,
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              // Active Run Fitness History Chart
              Text(
                'ACTIVE SIMULATION EVOLUTION CHART',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              FitnessProgressChart<int>(history: history),

              const SizedBox(height: 20),

              // Active Generation Diversity Metric
              if (simService.currentGen != null) ...[
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.hub_rounded, color: AppColors.gold, size: 20),
                              SizedBox(width: 8),
                              Text('POPULATION GENETIC DIVERSITY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                          Text(
                            '${simService.currentGen!.diversity.toStringAsFixed(1)}%',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.gold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: (simService.currentGen!.diversity / 100.0).clamp(0.0, 1.0),
                          minHeight: 12,
                          backgroundColor: isDark ? Colors.white10 : Colors.black12,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Diversity represents percentage of unique chromosome structures in current generation. Higher diversity prevents premature convergence.',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
