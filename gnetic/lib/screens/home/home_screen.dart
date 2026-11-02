import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatting_utils.dart';
import '../../models/problem_type.dart';
import '../../services/simulation_service.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/stat_card.dart';
import 'how_ga_works_section.dart';

class HomeScreen extends StatelessWidget {
  final ValueChanged<int> onNavigate;
  final VoidCallback onLaunchDemo;
  final VoidCallback onLaunchPresentation;

  const HomeScreen({
    super.key,
    required this.onNavigate,
    required this.onLaunchDemo,
    required this.onLaunchPresentation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SimulationService>(
      builder: (context, simService, child) {
        final currentGen = simService.currentGen;
        final bestFit = simService.bestIndividual?.fitness ?? 0.0;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gold.withOpacity(0.6)),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.bolt_rounded, color: AppColors.gold, size: 14),
                              SizedBox(width: 4),
                              Text(
                                'OFFLINE GA ENGINE',
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Optimize Problems Using Evolutionary Intelligence',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Simulate how populations evolve toward optimal solutions using selection, crossover, and mutation inside Dart.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        CustomButton(
                          label: 'Start Simulation',
                          icon: Icons.play_arrow_rounded,
                          isPrimary: false,
                          color: AppColors.gold,
                          onPressed: () => onNavigate(1), // Simulator
                        ),
                        CustomButton(
                          label: 'Learn GA',
                          icon: Icons.menu_book_rounded,
                          isOutlined: true,
                          color: Colors.white,
                          onPressed: () => onNavigate(3), // Learn
                        ),
                        CustomButton(
                          label: 'Demo Mode',
                          icon: Icons.play_circle_outline_rounded,
                          isOutlined: true,
                          color: AppColors.gold,
                          onPressed: onLaunchDemo,
                        ),
                        CustomButton(
                          label: 'Viva Mode',
                          icon: Icons.present_to_all_rounded,
                          isPrimary: true,
                          color: AppColors.blue,
                          onPressed: onLaunchPresentation,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Live Dashboard Statistics Grid
              Text(
                'LIVE GA DASHBOARD STATISTICS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossCount = constraints.maxWidth > 600 ? 4 : 2;
                  return GridView.count(
                    crossAxisCount: crossCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: constraints.maxWidth > 600 ? 2.0 : 1.25,
                    children: [
                      StatCard(
                        title: 'Generation',
                        value: '${currentGen?.generationNumber ?? 0}',
                        subtitle: 'Of ${simService.config.maxGenerations} Max',
                        icon: Icons.sync_rounded,
                        accentColor: AppColors.blue,
                        infoTopicKey: 'Generation',
                      ),
                      StatCard(
                        title: 'Best Fitness',
                        value: FormattingUtils.formatFitness(bestFit),
                        subtitle: simService.selectedProblemType.shortName,
                        icon: Icons.emoji_events_rounded,
                        accentColor: AppColors.gold,
                        infoTopicKey: 'Fitness Function',
                      ),
                      StatCard(
                        title: 'Population Size',
                        value: '${simService.config.populationSize}',
                        subtitle: 'Individuals',
                        icon: Icons.groups_rounded,
                        accentColor: AppColors.green,
                        infoTopicKey: 'Population',
                      ),
                      StatCard(
                        title: 'Mutation Rate',
                        value: '${(simService.config.mutationRate * 100).toStringAsFixed(1)}%',
                        subtitle: 'Probability',
                        icon: Icons.auto_fix_high_rounded,
                        accentColor: AppColors.accentRed,
                        infoTopicKey: 'Mutation',
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 24),

              // Evolutionary Pipeline Graphic
              _buildEvolutionaryPipelineGraphic(isDark),

              const SizedBox(height: 24),

              // How GA Powers This App
              const HowGaWorksSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvolutionaryPipelineGraphic(bool isDark) {
    final stages = [
      ('Population', Icons.groups_rounded, AppColors.blue),
      ('Fitness Eval', Icons.fact_check_rounded, AppColors.green),
      ('Selection', Icons.filter_alt_rounded, AppColors.gold),
      ('Crossover', Icons.cut_rounded, AppColors.blueLight),
      ('Mutation', Icons.auto_fix_high_rounded, AppColors.accentRed),
      ('New Generation', Icons.autorenew_rounded, AppColors.goldLight),
      ('Optimal Solution', Icons.stars_rounded, AppColors.greenLight),
    ];

    return Container(
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
            children: const [
              Expanded(
                child: Text(
                  'GENETIC ALGORITHM WORKFLOW PIPELINE',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                'Evolutionary Cycle',
                style: TextStyle(fontSize: 10, color: AppColors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(stages.length, (idx) {
                final stage = stages[idx];
                final isLast = idx == stages.length - 1;

                return Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: stage.$3.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: stage.$3.withOpacity(0.5)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(stage.$2, size: 20, color: stage.$3),
                          const SizedBox(height: 4),
                          Text(
                            stage.$1,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.navy,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast) ...[
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(Icons.arrow_forward_rounded, size: 16, color: Colors.grey),
                      ),
                    ],
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
