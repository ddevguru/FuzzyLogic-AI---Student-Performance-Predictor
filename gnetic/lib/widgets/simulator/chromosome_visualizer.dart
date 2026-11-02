import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/chromosome.dart';
import '../common/info_tooltip_button.dart';

class ChromosomeVisualizer<T> extends StatelessWidget {
  final Chromosome<T> chromosome;
  final String title;
  final bool showCrossoverPoint;

  const ChromosomeVisualizer({
    super.key,
    required this.chromosome,
    this.title = 'Chromosome Inspection',
    this.showCrossoverPoint = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.line_style_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(width: 6),
                const InfoTooltipButton(topicKey: 'Chromosome', size: 15),
              ],
            ),
            Text(
              '${chromosome.genes.length} Genes',
              style: const TextStyle(fontSize: 11, color: AppColors.blue, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(chromosome.genes.length, (idx) {
              final gene = chromosome.genes[idx];
              final isCrossoverAfter = showCrossoverPoint &&
                  chromosome.crossoverPoint != null &&
                  idx == chromosome.crossoverPoint! - 1;

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: gene.isMutated
                          ? AppColors.accentRed.withOpacity(0.2)
                          : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: gene.isMutated
                            ? AppColors.accentRed
                            : (isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder),
                        width: gene.isMutated ? 2.0 : 1.0,
                      ),
                      boxShadow: gene.isMutated
                          ? [
                              BoxShadow(
                                color: AppColors.accentRed.withOpacity(0.4),
                                blurRadius: 6,
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          gene.value.toString(),
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: gene.isMutated
                                ? AppColors.accentRed
                                : (isDark ? Colors.white : AppColors.navy),
                          ),
                        ),
                        if (gene.isMutated) ...[
                          const SizedBox(height: 2),
                          const Text(
                            'MUT',
                            style: TextStyle(
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              color: AppColors.accentRed,
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                  if (isCrossoverAfter) ...[
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 24,
                      width: 2,
                      color: AppColors.gold,
                    ),
                    const Icon(Icons.cut_rounded, size: 14, color: AppColors.gold),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 24,
                      width: 2,
                      color: AppColors.gold,
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ],
    );
  }
}
