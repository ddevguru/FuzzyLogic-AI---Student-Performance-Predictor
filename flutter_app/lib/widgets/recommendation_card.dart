import 'package:flutter/material.dart';
import '../models/prediction_model.dart';
import '../theme/app_theme.dart';

class RecommendationCard extends StatelessWidget {
  final RecommendationItem recommendation;

  const RecommendationCard({super.key, required this.recommendation});

  Color _getPriorityColor(String priority) {
    if (priority.contains('High')) return AppTheme.highRisk;
    if (priority.contains('Medium')) return AppTheme.moderateRisk;
    return AppTheme.lowRisk;
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'event_busy':
        return Icons.event_busy;
      case 'event_repeat':
        return Icons.event_repeat;
      case 'event_available':
        return Icons.event_available;
      case 'assignment_late':
        return Icons.assignment_late;
      case 'edit_note':
        return Icons.edit_note;
      case 'stars':
        return Icons.stars;
      case 'menu_book':
        return Icons.menu_book;
      case 'fact_check':
        return Icons.fact_check;
      case 'verified':
        return Icons.verified;
      case 'schedule':
        return Icons.schedule;
      case 'timer':
        return Icons.timer;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'warning_amber':
        return Icons.warning_amber;
      case 'emoji_events':
        return Icons.emoji_events;
      default:
        return Icons.lightbulb_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final priorityColor = _getPriorityColor(recommendation.priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: priorityColor.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: priorityColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getIconData(recommendation.icon),
              color: priorityColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      recommendation.category.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: priorityColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        recommendation.priority,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  recommendation.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recommendation.message,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark ? Colors.white70 : const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
