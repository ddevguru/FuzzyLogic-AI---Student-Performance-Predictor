import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatting_utils.dart';
import '../../models/individual.dart';

class PopulationGrid<T> extends StatelessWidget {
  final List<Individual<T>> population;
  final ValueChanged<Individual<T>>? onIndividualTap;

  const PopulationGrid({
    super.key,
    required this.population,
    this.onIndividualTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'LIVE POPULATION INDIVIDUALS (${population.length})',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                letterSpacing: 1.0,
              ),
            ),
            const Text(
              'Ranked by Fitness',
              style: TextStyle(fontSize: 11, color: AppColors.blue, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: population.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final ind = population[index];
              Color rankColor;
              String badgeText;

              switch (ind.rankBadge) {
                case RankBadge.best:
                  rankColor = AppColors.rankBest;
                  badgeText = 'BEST';
                  break;
                case RankBadge.good:
                  rankColor = AppColors.rankGood;
                  badgeText = 'GOOD';
                  break;
                case RankBadge.average:
                  rankColor = AppColors.rankAverage;
                  badgeText = 'AVG';
                  break;
                case RankBadge.weak:
                  rankColor = AppColors.rankWeak;
                  badgeText = 'WEAK';
                  break;
              }

              return InkWell(
                onTap: () => onIndividualTap?.call(ind),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 155,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: ind.rankBadge == RankBadge.best
                          ? AppColors.gold
                          : (isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder),
                      width: ind.rankBadge == RankBadge.best ? 1.5 : 1.0,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '#${ind.rank}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: isDark ? Colors.white : AppColors.navy,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: rankColor.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: rankColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ind.chromosome.toString(),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Fitness:',
                            style: TextStyle(fontSize: 10, color: Colors.grey),
                          ),
                          Text(
                            FormattingUtils.formatFitness(ind.fitness),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: rankColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
