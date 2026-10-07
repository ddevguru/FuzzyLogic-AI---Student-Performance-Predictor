import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prediction_model.dart';
import '../theme/app_theme.dart';
import '../widgets/fuzzy_progress_bar.dart';
import '../widgets/recommendation_card.dart';
import '../widgets/score_gauge.dart';
import 'rule_visualization_screen.dart';
import 'membership_graph_screen.dart';

class PredictionResultScreen extends StatelessWidget {
  final PredictionRecord record;

  const PredictionResultScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final fuzz = record.fuzzification;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result & Fuzzy Pipeline'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Result Gauge
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ScoreGauge(
                  score: record.performanceScore,
                  level: record.performanceLevel,
                  risk: record.riskLevel,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Navigation buttons for visual evaluation
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RuleVisualizationScreen(rules: record.rules),
                        ),
                      );
                    },
                    icon: const Icon(Icons.rule),
                    label: const Text('How AI Decided'),
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
                          builder: (_) => MembershipGraphScreen(inputs: record.inputs),
                        ),
                      );
                    },
                    icon: const Icon(Icons.show_chart),
                    label: const Text('Fuzzy Curves'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Fuzzification Breakdown Header
            Text(
              'Fuzzification Breakdown',
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Membership values computed for each fuzzy input set [0.00 – 1.00]:',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),

            if (fuzz != null) ...[
              FuzzyProgressBarSection(
                title: 'Attendance (${record.inputs.attendance.toStringAsFixed(0)}%)',
                memberships: fuzz.attendance,
              ),
              FuzzyProgressBarSection(
                title: 'Test Score (${record.inputs.testScore.toStringAsFixed(0)}/100)',
                memberships: fuzz.testScore,
              ),
              FuzzyProgressBarSection(
                title: 'Assignment Score (${record.inputs.assignmentScore.toStringAsFixed(0)}%)',
                memberships: fuzz.assignmentScore,
                label1: 'POOR',
                label2: 'AVERAGE',
                label3: 'GOOD',
              ),
              FuzzyProgressBarSection(
                title: 'Study Hours (${record.inputs.studyHours.toStringAsFixed(1)} hrs/day)',
                memberships: fuzz.studyHours,
              ),
            ] else ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Fuzzification data unavailable for this record.'),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Recommendations Header
            if (record.recommendations.isNotEmpty) ...[
              Text(
                'Personalized Recommendations',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...record.recommendations.map((rec) => RecommendationCard(recommendation: rec)),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
