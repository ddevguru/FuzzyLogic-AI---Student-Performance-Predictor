import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/prediction_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/score_gauge.dart';
import '../widgets/stat_card.dart';
import 'prediction_form_screen.dart';
import 'prediction_result_screen.dart';
import 'recommendations_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final predProvider = Provider.of<PredictionProvider>(context, listen: false);
      predProvider.fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final predProvider = Provider.of<PredictionProvider>(context);
    final user = authProvider.user;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final dashData = predProvider.dashboardData;
    final latestRecord = predProvider.activePrediction ??
        (dashData != null && dashData['latestPrediction'] != null
            ? null
            : null);

    final double currentScore = latestRecord != null
        ? latestRecord.performanceScore
        : (dashData?['latestPrediction'] != null
            ? double.parse(dashData!['latestPrediction']['performance_score'].toString())
            : 82.0);

    final String currentLevel = latestRecord != null
        ? latestRecord.performanceLevel
        : (dashData?['latestPrediction'] != null
            ? dashData!['latestPrediction']['performance_level'].toString()
            : 'Very Good');

    final String currentRisk = latestRecord != null
        ? latestRecord.riskLevel
        : (dashData?['latestPrediction'] != null
            ? dashData!['latestPrediction']['risk_level'].toString()
            : 'Very Low Risk');

    final double attVal = latestRecord != null
        ? latestRecord.inputs.attendance
        : (dashData?['latestPrediction'] != null
            ? double.parse(dashData!['latestPrediction']['attendance'].toString())
            : 82.0);

    final double testVal = latestRecord != null
        ? latestRecord.inputs.testScore
        : (dashData?['latestPrediction'] != null
            ? double.parse(dashData!['latestPrediction']['test_score'].toString())
            : 76.0);

    final double asgVal = latestRecord != null
        ? latestRecord.inputs.assignmentScore
        : (dashData?['latestPrediction'] != null
            ? double.parse(dashData!['latestPrediction']['assignment_score'].toString())
            : 88.0);

    final double studyVal = latestRecord != null
        ? latestRecord.inputs.studyHours
        : (dashData?['latestPrediction'] != null
            ? double.parse(dashData!['latestPrediction']['study_hours'].toString())
            : 5.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎓 Academic Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => predProvider.fetchDashboard(),
          ),
        ],
      ),
      body: predProvider.isLoading && dashData == null
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => predProvider.fetchDashboard(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Banner
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isDark
                              ? [AppTheme.darkSurface, AppTheme.blue.withOpacity(0.4)]
                              : [AppTheme.navy, AppTheme.blue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.navy.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, ${user?.name ?? 'Student'} 👋',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${user?.profile?.course ?? 'B.Tech CS'} • Sem ${user?.profile?.semester ?? 6}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentGold.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppTheme.accentGold, width: 1),
                                  ),
                                  child: const Text(
                                    '⚡ Mamdani Fuzzy Engine Active',
                                    style: TextStyle(
                                      color: AppTheme.accentGold,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white24,
                            child: Icon(Icons.person, size: 36, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Score Gauge Widget
                    Center(
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                          child: Column(
                            children: [
                              ScoreGauge(
                                score: currentScore,
                                level: currentLevel,
                                risk: currentRisk,
                              ),
                              if (latestRecord != null) ...[
                                const SizedBox(height: 16),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PredictionResultScreen(record: latestRecord),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.analytics_outlined),
                                  label: const Text('View Full Fuzzy Pipeline Breakdown'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Metric Cards Grid
                    Text(
                      'Performance Indicators',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.1,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        StatCard(
                          title: 'Attendance',
                          value: '${attVal.toStringAsFixed(0)}%',
                          icon: Icons.calendar_month,
                          color: attVal >= 75 ? AppTheme.veryGoodColor : AppTheme.poorColor,
                          subtitle: attVal >= 75 ? 'Optimal' : 'Needs boost',
                        ),
                        StatCard(
                          title: 'Test Score',
                          value: '${testVal.toStringAsFixed(0)}',
                          icon: Icons.assignment_turned_in,
                          color: testVal >= 60 ? AppTheme.blue : AppTheme.averageColor,
                          subtitle: 'Out of 100',
                        ),
                        StatCard(
                          title: 'Assignments',
                          value: '${asgVal.toStringAsFixed(0)}%',
                          icon: Icons.folder_special,
                          color: AppTheme.accentGold,
                          subtitle: 'Coursework',
                        ),
                        StatCard(
                          title: 'Study Hours',
                          value: '${studyVal.toStringAsFixed(1)} hrs',
                          icon: Icons.timer,
                          color: AppTheme.green,
                          subtitle: 'Daily average',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PredictionFormScreen()),
                              );
                            },
                            icon: const Icon(Icons.add_chart),
                            label: const Text('New Prediction'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.navy,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const RecommendationsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.lightbulb_outline),
                            label: const Text('Advice'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
