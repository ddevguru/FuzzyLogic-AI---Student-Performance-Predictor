import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../theme/app_theme.dart';

class FuzzyProgressBarSection extends StatelessWidget {
  final String title;
  final FuzzySetMemberships memberships;
  final String label1;
  final String label2;
  final String label3;

  const FuzzyProgressBarSection({
    super.key,
    required this.title,
    required this.memberships,
    this.label1 = 'LOW',
    this.label2 = 'MEDIUM',
    this.label3 = 'HIGH',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'Fuzzified',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _FuzzyBarRow(
            label: label1,
            value: memberships.low,
            color: AppTheme.poorColor,
          ),
          const SizedBox(height: 8),
          _FuzzyBarRow(
            label: label2,
            value: memberships.medium,
            color: AppTheme.averageColor,
          ),
          const SizedBox(height: 8),
          _FuzzyBarRow(
            label: label3,
            value: memberships.high,
            color: AppTheme.veryGoodColor,
          ),
        ],
      ),
    );
  }
}

class _FuzzyBarRow extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _FuzzyBarRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final clampedVal = value.clamp(0.0, 1.0);

    return Row(
      children: [
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: clampedVal,
              minHeight: 10,
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white12
                  : Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 40,
          child: Text(
            clampedVal.toStringAsFixed(2),
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: clampedVal > 0 ? color : Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
