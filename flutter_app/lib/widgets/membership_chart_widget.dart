import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

enum MembershipInputType { attendance, testScore, assignmentScore, studyHours }

class MembershipChartWidget extends StatelessWidget {
  final MembershipInputType inputType;
  final double currentCrispVal;

  const MembershipChartWidget({
    super.key,
    required this.inputType,
    required this.currentCrispVal,
  });

  String get _title {
    switch (inputType) {
      case MembershipInputType.attendance:
        return 'Attendance Membership Functions (%)';
      case MembershipInputType.testScore:
        return 'Test Score Membership Functions';
      case MembershipInputType.assignmentScore:
        return 'Assignment Score Membership Functions';
      case MembershipInputType.studyHours:
        return 'Study Hours Membership Functions (hrs/day)';
    }
  }

  double get _maxX {
    if (inputType == MembershipInputType.studyHours) return 12.0;
    return 100.0;
  }

  // Generate line chart data points for fuzzy sets
  List<FlSpot> _getLowSpots() {
    if (inputType == MembershipInputType.studyHours) {
      return const [
        FlSpot(0, 1.0),
        FlSpot(1.5, 1.0),
        FlSpot(3.5, 0.0),
      ];
    }
    return const [
      FlSpot(0, 1.0),
      FlSpot(25, 1.0),
      FlSpot(45, 0.0),
    ];
  }

  List<FlSpot> _getMediumSpots() {
    if (inputType == MembershipInputType.studyHours) {
      return const [
        FlSpot(2.0, 0.0),
        FlSpot(4.5, 1.0),
        FlSpot(7.0, 0.0),
      ];
    }
    return const [
      FlSpot(30, 0.0),
      FlSpot(52.5, 1.0),
      FlSpot(75, 0.0),
    ];
  }

  List<FlSpot> _getHighSpots() {
    if (inputType == MembershipInputType.studyHours) {
      return const [
        FlSpot(5.5, 0.0),
        FlSpot(8.5, 1.0),
        FlSpot(12.0, 1.0),
      ];
    }
    return const [
      FlSpot(65, 0.0),
      FlSpot(85, 1.0),
      FlSpot(100, 1.0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  _title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Input = ${currentCrispVal.toStringAsFixed(1)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.blue,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _LegendItem(label: 'Low / Poor', color: AppTheme.poorColor),
              SizedBox(width: 16),
              _LegendItem(label: 'Medium / Avg', color: AppTheme.averageColor),
              SizedBox(width: 16),
              _LegendItem(label: 'High / Good', color: AppTheme.veryGoodColor),
              SizedBox(width: 16),
              _LegendItem(label: 'Current Input', color: AppTheme.navy, isDashed: true),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: _maxX,
                minY: 0,
                maxY: 1.1,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 0.5,
                  getDrawingHorizontalLine: (val) => FlLine(
                    color: isDark ? Colors.white12 : Colors.black12,
                    strokeWidth: 1,
                  ),
                  getDrawingVerticalLine: (val) => FlLine(
                    color: isDark ? Colors.white12 : Colors.black12,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      interval: 0.5,
                      getTitlesWidget: (val, meta) => Text(
                        val.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                ),
                lineBarsData: [
                  // Low Curve
                  LineChartBarData(
                    spots: _getLowSpots(),
                    isCurved: false,
                    color: AppTheme.poorColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.poorColor.withOpacity(0.1),
                    ),
                  ),
                  // Medium Curve
                  LineChartBarData(
                    spots: _getMediumSpots(),
                    isCurved: false,
                    color: AppTheme.averageColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.averageColor.withOpacity(0.1),
                    ),
                  ),
                  // High Curve
                  LineChartBarData(
                    spots: _getHighSpots(),
                    isCurved: false,
                    color: AppTheme.veryGoodColor,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppTheme.veryGoodColor.withOpacity(0.1),
                    ),
                  ),
                  // Current Crisp Input Vertical Line
                  LineChartBarData(
                    spots: [
                      FlSpot(currentCrispVal.clamp(0, _maxX), 0),
                      FlSpot(currentCrispVal.clamp(0, _maxX), 1.0),
                    ],
                    isCurved: false,
                    color: isDark ? Colors.amber : AppTheme.navy,
                    barWidth: 2.5,
                    dashArray: [6, 4],
                    dotData: const FlDotData(show: true),
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

class _LegendItem extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDashed;

  const _LegendItem({
    required this.label,
    required this.color,
    this.isDashed = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 14,
          height: isDashed ? 3 : 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
