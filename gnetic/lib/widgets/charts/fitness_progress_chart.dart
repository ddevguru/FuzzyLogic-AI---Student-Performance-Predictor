import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatting_utils.dart';
import '../../models/generation.dart';

class FitnessProgressChart<T> extends StatelessWidget {
  final List<Generation<T>> history;

  const FitnessProgressChart({
    super.key,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (history.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: const Text('No generation data available yet.'),
      );
    }

    List<FlSpot> bestSpots = [];
    List<FlSpot> avgSpots = [];

    for (int i = 0; i < history.length; i++) {
      final gen = history[i];
      bestSpots.add(FlSpot(gen.generationNumber.toDouble(), gen.bestIndividual.fitness));
      avgSpots.add(FlSpot(gen.generationNumber.toDouble(), gen.averageFitness));
    }

    double maxFit = history.fold(0.0, (maxVal, g) => g.bestIndividual.fitness > maxVal ? g.bestIndividual.fitness : maxVal);
    if (maxFit == 0) maxFit = 10;

    return Container(
      height: 240,
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
                  Icon(Icons.show_chart_rounded, color: AppColors.gold, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'FITNESS VS GENERATION EVOLUTION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildLegendItem('Best Fitness', AppColors.gold),
                  const SizedBox(width: 12),
                  _buildLegendItem('Avg Fitness', AppColors.blue),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: (history.length / 5).clamp(1.0, 50.0),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          'G${value.toInt()}',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          FormattingUtils.formatFitness(value),
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (history.length - 1).toDouble(),
                minY: 0,
                maxY: maxFit * 1.15,
                lineBarsData: [
                  // Best Fitness Line
                  LineChartBarData(
                    spots: bestSpots,
                    isCurved: true,
                    color: AppColors.gold,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.gold.withOpacity(0.12),
                    ),
                  ),
                  // Average Fitness Line
                  LineChartBarData(
                    spots: avgSpots,
                    isCurved: true,
                    color: AppColors.blue,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }
}
