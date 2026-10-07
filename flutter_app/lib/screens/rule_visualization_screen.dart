import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prediction_model.dart';
import '../theme/app_theme.dart';
import '../widgets/rule_card.dart';

class RuleVisualizationScreen extends StatelessWidget {
  final List<FuzzyRuleResult> rules;

  const RuleVisualizationScreen({super.key, required this.rules});

  @override
  Widget build(BuildContext context) {
    // Filter active rules (strength > 0)
    final activeRules = rules.where((r) => r.strength > 0).toList();
    activeRules.sort((a, b) => b.strength.compareTo(a.strength));

    return Scaffold(
      appBar: AppBar(
        title: const Text('How the AI Decided'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.psychology, color: AppTheme.blue, size: 36),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Mamdani Fuzzy Rule Evaluation',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppTheme.blue,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'AND = MIN operator evaluates antecedent firing strength. Consequents are aggregated via MAX operator.',
                          style: TextStyle(fontSize: 12, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Activated Rules (${activeRules.length})',
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Total Rules: ${rules.length}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (activeRules.isEmpty) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('No active rules fired for these input conditions.'),
                  ),
                ),
              ),
            ] else ...[
              ...activeRules.map((rule) => RuleCard(rule: rule)),
            ],
          ],
        ),
      ),
    );
  }
}
