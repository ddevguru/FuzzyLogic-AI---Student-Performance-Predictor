import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/individual.dart';

class PopulationDistributionChart<T> extends StatelessWidget {
  final List<Individual<T>> population;

  const PopulationDistributionChart({
    super.key,
    required this.population,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    int bestCount = 0;
    int goodCount = 0;
    int avgCount = 0;
    int weakCount = 0;

    for (var ind in population) {
      switch (ind.rankBadge) {
        case RankBadge.best:
          bestCount++;
          break;
        case RankBadge.good:
          goodCount++;
          break;
        case RankBadge.average:
          avgCount++;
          break;
        case RankBadge.weak:
          weakCount++;
          break;
      }
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(14),
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
              Text(
                'POPULATION FITNESS DISTRIBUTION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                '4 Rank Tiers',
                style: TextStyle(fontSize: 10, color: AppColors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: BarChart(
              BarChartData(
                barGroups: [
                  _buildBar(0, bestCount.toDouble(), AppColors.rankBest, 'BEST'),
                  _buildBar(1, goodCount.toDouble(), AppColors.rankGood, 'GOOD'),
                  _buildBar(2, avgCount.toDouble(), AppColors.rankAverage, 'AVG'),
                  _buildBar(3, weakCount.toDouble(), AppColors.rankWeak, 'WEAK'),
                ],
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text('BEST', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.rankBest));
                          case 1:
                            return const Text('GOOD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.rankGood));
                          case 2:
                            return const Text('AVG', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.rankAverage));
                          case 3:
                            return const Text('WEAK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.rankWeak));
                          default:
                            return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBar(int x, double y, Color color, String label) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
        ),
      ],
    );
  }
}
