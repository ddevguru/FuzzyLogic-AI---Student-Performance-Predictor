import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../problems/knapsack_problem.dart';

class KnapsackVisualizer extends StatelessWidget {
  final List<int> itemBits;
  final double maxCapacity;

  const KnapsackVisualizer({
    super.key,
    required this.itemBits,
    this.maxCapacity = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    double currentWeight = 0.0;
    double currentValue = 0.0;

    for (int i = 0; i < itemBits.length && i < KnapsackProblem.defaultItems.length; i++) {
      if (itemBits[i] == 1) {
        currentWeight += KnapsackProblem.defaultItems[i].weight;
        currentValue += KnapsackProblem.defaultItems[i].value;
      }
    }

    bool isOverweight = currentWeight > maxCapacity;
    double weightRatio = (currentWeight / maxCapacity).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverweight
              ? AppColors.accentRed
              : (isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder),
          width: isOverweight ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_rounded,
                    color: isOverweight ? AppColors.accentRed : AppColors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'KNAPSACK PACKING STATUS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Text(
                'Total Value: \$${currentValue.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Weight Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: weightRatio,
                    minHeight: 12,
                    backgroundColor: isDark ? Colors.white10 : Colors.black12,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isOverweight ? AppColors.accentRed : AppColors.green,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${currentWeight.toStringAsFixed(1)} / ${maxCapacity.toStringAsFixed(1)} kg',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: isOverweight ? AppColors.accentRed : (isDark ? Colors.white : AppColors.navy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Items Grid
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(KnapsackProblem.defaultItems.length, (idx) {
              if (idx >= itemBits.length) return const SizedBox.shrink();
              final isSelected = itemBits[idx] == 1;
              final item = KnapsackProblem.defaultItems[idx];

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.green.withOpacity(0.18)
                      : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.green : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 12,
                      color: isSelected ? AppColors.green : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.name} (${item.weight}kg)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected
                            ? (isDark ? Colors.white : AppColors.navy)
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
