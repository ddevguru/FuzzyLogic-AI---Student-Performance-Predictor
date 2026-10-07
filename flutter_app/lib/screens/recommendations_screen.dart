import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/prediction_provider.dart';
import '../widgets/recommendation_card.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final predProvider = Provider.of<PredictionProvider>(context);
    final activePred = predProvider.activePrediction;
    final recs = activePred?.recommendations ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Recommendations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Focus & Action Areas',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Personalized recommendations dynamically generated from weak fuzzy input scores.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            if (recs.isEmpty) ...[
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(
                    child: Text('Run a performance prediction to view tailored recommendations.'),
                  ),
                ),
              ),
            ] else ...[
              ...recs.map((rec) => RecommendationCard(recommendation: rec)),
            ],
          ],
        ),
      ),
    );
  }
}
