import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/prediction_provider.dart';
import '../theme/app_theme.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final predProvider = Provider.of<PredictionProvider>(context, listen: false);
      predProvider.fetchDashboard();
      predProvider.fetchHistory('All');
    });
  }

  @override
  Widget build(BuildContext context) {
    final predProvider = Provider.of<PredictionProvider>(context);
    final history = predProvider.history;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<FlSpot> trendSpots = [];
    for (int i = 0; i < history.length; i++) {
      // Reversed for chronological left to right
      final record = history[history.length - 1 - i];
      trendSpots.add(FlSpot(i.toDouble(), record.performanceScore));
    }

    // Input comparison from latest prediction
    final latest = history.isNotEmpty ? history.first : null;
    final double att = latest?.inputs.attendance ?? 82;
    final double test = latest?.inputs.testScore ?? 76;
    final double asg = latest?.inputs.assignmentScore ?? 88;
    final double study = (latest?.inputs.studyHours ?? 5) * 8.33; // Normalized to ~100 scale for visual chart

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Analytics'),
      ),
      body: predProvider.isLoading && history.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Academic Progress Analytics',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Visualizing score trends, risk distribution, and metric balance.',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // 1. Line Chart: Performance Trend
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📈 Performance Score Trend',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: trendSpots.isEmpty
                              ? const Center(child: Text('No historical prediction data'))
                              : LineChart(
                                  LineChartData(
                                    minY: 0,
                                    maxY: 100,
                                    gridData: FlGridData(
                                      show: true,
                                      getDrawingHorizontalLine: (val) => FlLine(
                                        color: isDark ? Colors.white12 : Colors.black12,
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 32,
                                          interval: 20,
                                          getTitlesWidget: (val, meta) => Text(
                                            '${val.toInt()}',
                                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                                          ),
                                        ),
                                      ),
                                      bottomTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                      topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: trendSpots,
                                        isCurved: true,
                                        color: AppTheme.blue,
                                        barWidth: 3.5,
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: AppTheme.blue.withOpacity(0.15),
                                        ),
                                        dotData: const FlDotData(show: true),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Bar Chart: Input Comparison
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📊 Indicator Balance Comparison',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: BarChart(
                            BarChartData(
                              maxY: 100,
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: att,
                                      color: AppTheme.blue,
                                      width: 18,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: test,
                                      color: AppTheme.accentGold,
                                      width: 18,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 2,
                                  barRods: [
                                    BarChartRodData(
                                      toY: asg,
                                      color: AppTheme.green,
                                      width: 18,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 3,
                                  barRods: [
                                    BarChartRodData(
                                      toY: study,
                                      color: Colors.purple,
                                      width: 18,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ],
                                ),
                              ],
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (val, meta) {
                                      switch (val.toInt()) {
                                        case 0:
                                          return const Text('Attendance', style: TextStyle(fontSize: 10));
                                        case 1:
                                          return const Text('Test', style: TextStyle(fontSize: 10));
                                        case 2:
                                          return const Text('Assignment', style: TextStyle(fontSize: 10));
                                        case 3:
                                          return const Text('Study (x8)', style: TextStyle(fontSize: 10));
                                        default:
                                          return const Text('');
                                      }
                                    },
                                  ),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 28,
                                    getTitlesWidget: (val, meta) => Text(
                                      '${val.toInt()}',
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    ),
                                  ),
                                ),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
