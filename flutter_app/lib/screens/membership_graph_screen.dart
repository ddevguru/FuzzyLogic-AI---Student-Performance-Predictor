import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/prediction_model.dart';
import '../theme/app_theme.dart';
import '../widgets/membership_chart_widget.dart';

class MembershipGraphScreen extends StatefulWidget {
  final PredictionInputs inputs;

  const MembershipGraphScreen({super.key, required this.inputs});

  @override
  State<MembershipGraphScreen> createState() => _MembershipGraphScreenState();
}

class _MembershipGraphScreenState extends State<MembershipGraphScreen> {
  MembershipInputType _selectedType = MembershipInputType.attendance;

  double get _currentValue {
    switch (_selectedType) {
      case MembershipInputType.attendance:
        return widget.inputs.attendance;
      case MembershipInputType.testScore:
        return widget.inputs.testScore;
      case MembershipInputType.assignmentScore:
        return widget.inputs.assignmentScore;
      case MembershipInputType.studyHours:
        return widget.inputs.studyHours;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fuzzy Membership Curves'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Membership Function Curves',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Visualizes overlapping triangular & trapezoidal fuzzy set curves with your current crisp input line.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Selector Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('Attendance'),
                    selected: _selectedType == MembershipInputType.attendance,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = MembershipInputType.attendance);
                    },
                    selectedColor: AppTheme.navy,
                    labelStyle: TextStyle(
                      color: _selectedType == MembershipInputType.attendance ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Test Score'),
                    selected: _selectedType == MembershipInputType.testScore,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = MembershipInputType.testScore);
                    },
                    selectedColor: AppTheme.navy,
                    labelStyle: TextStyle(
                      color: _selectedType == MembershipInputType.testScore ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Assignment'),
                    selected: _selectedType == MembershipInputType.assignmentScore,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = MembershipInputType.assignmentScore);
                    },
                    selectedColor: AppTheme.navy,
                    labelStyle: TextStyle(
                      color: _selectedType == MembershipInputType.assignmentScore ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Study Hours'),
                    selected: _selectedType == MembershipInputType.studyHours,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedType = MembershipInputType.studyHours);
                    },
                    selectedColor: AppTheme.navy,
                    labelStyle: TextStyle(
                      color: _selectedType == MembershipInputType.studyHours ? Colors.white : null,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // FL Chart Graph
            MembershipChartWidget(
              inputType: _selectedType,
              currentCrispVal: _currentValue,
            ),
            const SizedBox(height: 24),

            // Description Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.accentGold.withOpacity(0.4)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: AppTheme.accentGold, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'The dashed vertical line indicates where your crisp input value intersects with the Low, Medium, and High fuzzy membership curves.',
                      style: TextStyle(fontSize: 13, height: 1.4),
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
