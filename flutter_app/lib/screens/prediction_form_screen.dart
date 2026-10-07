import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/prediction_provider.dart';
import '../theme/app_theme.dart';
import 'prediction_result_screen.dart';

class PredictionFormScreen extends StatefulWidget {
  const PredictionFormScreen({super.key});

  @override
  State<PredictionFormScreen> createState() => _PredictionFormScreenState();
}

class _PredictionFormScreenState extends State<PredictionFormScreen> {
  double _attendance = 82.0;
  double _testScore = 76.0;
  double _assignmentScore = 88.0;
  double _studyHours = 5.0;

  void _applyPreset(double att, double test, double asg, double std) {
    setState(() {
      _attendance = att;
      _testScore = test;
      _assignmentScore = asg;
      _studyHours = std;
    });
  }

  void _submitPrediction() async {
    final predProvider = Provider.of<PredictionProvider>(context, listen: false);

    final record = await predProvider.createPrediction(
      attendance: _attendance,
      testScore: _testScore,
      assignmentScore: _assignmentScore,
      studyHours: _studyHours,
    );

    if (record != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PredictionResultScreen(record: record),
        ),
      );
    } else if (mounted && predProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(predProvider.errorMessage!),
          backgroundColor: AppTheme.poorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final predProvider = Provider.of<PredictionProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Prediction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title Header
            Text(
              'Input Academic Indicators',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Adjust sliders to fuzzify student metrics and evaluate Mamdani fuzzy rules.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Demo Presets Chips
            const Text(
              'Quick Demo Presets:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.star, size: 16, color: AppTheme.accentGold),
                    label: const Text('Sample Case (82/76/88/5)'),
                    onPressed: () => _applyPreset(82, 76, 88, 5),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.warning, size: 16, color: AppTheme.highRisk),
                    label: const Text('High Risk (42/35/40/1.5)'),
                    onPressed: () => _applyPreset(42, 35, 40, 1.5),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.horizontal_rule, size: 16, color: AppTheme.moderateRisk),
                    label: const Text('Moderate (68/58/62/3)'),
                    onPressed: () => _applyPreset(68, 58, 62, 3),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Icon(Icons.emoji_events, size: 16, color: AppTheme.veryLowRisk),
                    label: const Text('Excellent (95/92/94/7)'),
                    onPressed: () => _applyPreset(95, 92, 94, 7),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sliders Form
            // 1. Attendance
            _SliderCard(
              title: 'Attendance',
              value: _attendance,
              unit: '%',
              min: 0,
              max: 100,
              divisions: 100,
              icon: Icons.calendar_month,
              activeColor: AppTheme.blue,
              onChanged: (val) => setState(() => _attendance = val),
            ),
            const SizedBox(height: 16),

            // 2. Test Score
            _SliderCard(
              title: 'Test Score',
              value: _testScore,
              unit: '/100',
              min: 0,
              max: 100,
              divisions: 100,
              icon: Icons.assignment_turned_in,
              activeColor: AppTheme.accentGold,
              onChanged: (val) => setState(() => _testScore = val),
            ),
            const SizedBox(height: 16),

            // 3. Assignment Performance
            _SliderCard(
              title: 'Assignment Performance',
              value: _assignmentScore,
              unit: '%',
              min: 0,
              max: 100,
              divisions: 100,
              icon: Icons.folder_special,
              activeColor: AppTheme.green,
              onChanged: (val) => setState(() => _assignmentScore = val),
            ),
            const SizedBox(height: 16),

            // 4. Study Hours
            _SliderCard(
              title: 'Study Hours',
              value: _studyHours,
              unit: ' hrs/day',
              min: 0,
              max: 12,
              divisions: 24,
              icon: Icons.schedule,
              activeColor: Colors.purple,
              onChanged: (val) => setState(() => _studyHours = val),
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: predProvider.isLoading ? null : _submitPrediction,
                icon: predProvider.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  predProvider.isLoading ? 'RUNNING FUZZY INFERENCE...' : 'ANALYZE PERFORMANCE',
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SliderCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final double min;
  final double max;
  final int divisions;
  final IconData icon;
  final Color activeColor;
  final ValueChanged<double> onChanged;

  const _SliderCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.min,
    required this.max,
    required this.divisions,
    required this.icon,
    required this.activeColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.06)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: activeColor, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.toStringAsFixed(unit.contains('hrs') ? 1 : 0)}$unit',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: activeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: activeColor,
              inactiveTrackColor: activeColor.withOpacity(0.15),
              thumbColor: activeColor,
              overlayColor: activeColor.withOpacity(0.2),
              valueIndicatorTextStyle: const TextStyle(color: Colors.white),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: '${value.toStringAsFixed(unit.contains('hrs') ? 1 : 0)}$unit',
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
