import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/prediction_provider.dart';
import '../theme/app_theme.dart';
import 'prediction_result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final List<String> _filters = ['All', 'Excellent', 'Very Good', 'Good', 'Average', 'Poor'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final predProvider = Provider.of<PredictionProvider>(context, listen: false);
      predProvider.fetchHistory('All');
    });
  }

  @override
  Widget build(BuildContext context) {
    final predProvider = Provider.of<PredictionProvider>(context);
    final history = predProvider.history;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction History'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: isDark ? AppTheme.darkSurface : Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = predProvider.selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      selectedColor: AppTheme.navy,
                      onSelected: (val) {
                        if (val) predProvider.fetchHistory(filter);
                      },
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : null,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // History List
          Expanded(
            child: predProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : history.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.history_toggle_off, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No prediction history found.'),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => predProvider.fetchHistory(predProvider.selectedFilter),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            final item = history[index];
                            final levelColor = AppTheme.getLevelColor(item.performanceLevel);
                            final formattedDate = DateFormat('dd MMM yyyy, hh:mm a').format(item.createdAt);

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
                                onTap: () {
                                  predProvider.setActivePrediction(item);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PredictionResultScreen(record: item),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            formattedDate,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: levelColor.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              item.performanceLevel.toUpperCase(),
                                              style: TextStyle(
                                                color: levelColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Text(
                                            item.performanceScore.toStringAsFixed(1),
                                            style: GoogleFonts.outfit(
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                              color: levelColor,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Risk: ${item.riskLevel}',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                    color: AppTheme.getRiskColor(item.riskLevel),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Att: ${item.inputs.attendance.toStringAsFixed(0)}%  |  Test: ${item.inputs.testScore.toStringAsFixed(0)}  |  Asg: ${item.inputs.assignmentScore.toStringAsFixed(0)}%  |  Study: ${item.inputs.studyHours.toStringAsFixed(1)}h',
                                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right, color: Colors.grey),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
