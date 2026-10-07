import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../theme/app_theme.dart';

class RuleCard extends StatelessWidget {
  final FuzzyRuleResult rule;

  const RuleCard({super.key, required this.rule});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final levelColor = AppTheme.getLevelColor(rule.output);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rule.strength > 0 ? levelColor.withOpacity(0.4) : (isDark ? Colors.white10 : Colors.black12),
          width: rule.strength > 0 ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'RULE ${rule.rule}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: levelColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  rule.output.replaceAll('_', ' '),
                  style: TextStyle(
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rule.text,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? Colors.white70 : AppTheme.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text(
                'Rule Strength: ',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: rule.strength.clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(levelColor),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                rule.strength.toStringAsFixed(2),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: levelColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
