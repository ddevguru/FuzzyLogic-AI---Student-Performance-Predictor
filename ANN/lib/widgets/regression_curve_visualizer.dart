import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/neural_network.dart';
import '../models/training_sample.dart';
import '../core/constants/app_colors.dart';

class RegressionCurveVisualizer extends StatelessWidget {
  final NeuralNetwork network;
  final List<TrainingSample> samples;

  const RegressionCurveVisualizer({
    super.key,
    required this.network,
    required this.samples,
  });

  @override
  Widget build(BuildContext context) {
    final actualSpots = <FlSpot>[];
    final predictedSpots = <FlSpot>[];

    // Build actual dataset spots
    for (var sample in samples) {
      actualSpots.add(FlSpot(sample.inputs[0], sample.targets[0]));
    }
    actualSpots.sort((a, b) => a.x.compareTo(b.x));

    // Build predicted curve across smooth resolution steps
    for (int i = 0; i <= 60; i++) {
      final x = -1.0 + (i / 60) * 2.0;
      final out = network.forward([x]);
      predictedSpots.add(FlSpot(x, out[0]));
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
              color: Colors.grey.withOpacity(0.15),
              strokeWidth: 1,
            ),
          ),
          titlesData: const FlTitlesData(
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          lineBarsData: [
            // Actual targets (Gold dots/line)
            LineChartBarData(
              spots: actualSpots,
              isCurved: true,
              color: AppColors.gold,
              barWidth: 2.0,
              dotData: const FlDotData(show: true),
            ),
            // Model prediction (Electric Blue smooth line)
            LineChartBarData(
              spots: predictedSpots,
              isCurved: true,
              color: AppColors.electricBlue,
              barWidth: 3.0,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
