import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/training_result.dart';
import '../core/constants/app_colors.dart';

class TrainingChart extends StatelessWidget {
  final List<EpochMetric> epochMetrics;
  final bool showAccuracy;
  final bool isDarkMode;

  const TrainingChart({
    super.key,
    required this.epochMetrics,
    this.showAccuracy = false,
    this.isDarkMode = true,
  });

  @override
  Widget build(BuildContext context) {
    if (epochMetrics.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        child: Text(
          'No training metrics recorded yet.',
          style: TextStyle(
            color: isDarkMode ? AppColors.textSubtleDark : AppColors.textSubtleLight,
          ),
        ),
      );
    }

    final trainLossSpots = <FlSpot>[];
    final valLossSpots = <FlSpot>[];
    final accuracySpots = <FlSpot>[];

    for (var m in epochMetrics) {
      trainLossSpots.add(FlSpot(m.epoch.toDouble(), m.trainLoss));
      if (m.valLoss != null) {
        valLossSpots.add(FlSpot(m.epoch.toDouble(), m.valLoss!));
      }
      accuracySpots.add(FlSpot(m.epoch.toDouble(), m.trainAccuracy));
    }

    return Container(
      height: 240,
      padding: const EdgeInsets.fromLTRB(12, 16, 20, 12),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            getDrawingHorizontalLine: (val) => FlLine(
              color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.06),
              strokeWidth: 1,
            ),
            getDrawingVerticalLine: (val) => FlLine(
              color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.06),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              axisNameWidget: const Text('Epoch', style: TextStyle(fontSize: 11)),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  if (value % (epochMetrics.length > 20 ? (epochMetrics.length / 5).round() : 2) == 0) {
                    return Text(
                      value.toInt().toString(),
                      style: const TextStyle(fontSize: 10),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              axisNameWidget: Text(showAccuracy ? 'Accuracy (%)' : 'Loss', style: const TextStyle(fontSize: 11)),
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(showAccuracy ? 0 : 2),
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(
              color: (isDarkMode ? Colors.white : Colors.black).withOpacity(0.1),
            ),
          ),
          lineBarsData: showAccuracy
              ? [
                  LineChartBarData(
                    spots: accuracySpots,
                    isCurved: true,
                    color: AppColors.accentGreen,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.accentGreen.withOpacity(0.15),
                    ),
                  ),
                ]
              : [
                  // Train Loss
                  LineChartBarData(
                    spots: trainLossSpots,
                    isCurved: true,
                    color: AppColors.electricBlue,
                    barWidth: 2.5,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.electricBlue.withOpacity(0.15),
                    ),
                  ),
                  // Val Loss (if present)
                  if (valLossSpots.isNotEmpty)
                    LineChartBarData(
                      spots: valLossSpots,
                      isCurved: true,
                      color: AppColors.gold,
                      barWidth: 2.0,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: false),
                    ),
                ],
        ),
      ),
    );
  }
}
