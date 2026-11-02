import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/info_tooltip_button.dart';

class HowGaWorksSection extends StatelessWidget {
  const HowGaWorksSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final steps = [
      _GaWorkflowStep(
        stepNumber: 'STEP 1',
        title: 'Initialization',
        whatHappens: 'Generates an initial population of N candidate solution chromosomes randomly.',
        whyNeeded: 'Establishes a diverse pool of starting candidate solutions across the solution space.',
        howImplemented: 'The simulator creates random binary strings or city permutations using Dart random generators.',
        topicKey: 'Population',
      ),
      _GaWorkflowStep(
        stepNumber: 'STEP 2',
        title: 'Fitness Evaluation',
        whatHappens: 'Calculates a numeric fitness score for every chromosome in the population.',
        whyNeeded: 'Quantifies how effectively each candidate solution solves the target problem.',
        howImplemented: 'Calculates mathematical function values f(x), knapsack total values, or TSP path distances.',
        topicKey: 'Fitness Function',
      ),
      _GaWorkflowStep(
        stepNumber: 'STEP 3',
        title: 'Parent Selection',
        whatHappens: 'Selects higher-performing individuals to become parents for reproduction.',
        whyNeeded: 'Enforces survival of the fittest, giving better solutions higher chance to reproduce.',
        howImplemented: 'Uses Tournament Selection (k=3) or Roulette Wheel Selection in Dart.',
        topicKey: 'Selection',
      ),
      _GaWorkflowStep(
        stepNumber: 'STEP 4',
        title: 'Crossover (Recombination)',
        whatHappens: 'Combines genetic material from two parent chromosomes to construct child offspring.',
        whyNeeded: 'Blends partial good sub-solutions from both parents to discover superior offspring.',
        howImplemented: 'Applies Single-Point Crossover or Ordered Crossover (OX1 for TSP) at probability (e.g. 85%).',
        topicKey: 'Crossover',
      ),
      _GaWorkflowStep(
        stepNumber: 'STEP 5',
        title: 'Mutation',
        whatHappens: 'Applies random subtle modifications to child genes at a low probability (e.g. 5%).',
        whyNeeded: 'Prevents premature population stagnation and helps escape local optima traps.',
        howImplemented: 'Applies Bit-Flip Mutation or Swap Mutation to child chromosome genes.',
        topicKey: 'Mutation',
      ),
      _GaWorkflowStep(
        stepNumber: 'STEP 6',
        title: 'Elitism & Replacement',
        whatHappens: 'Copies top elite individuals intact and forms the next generation population.',
        whyNeeded: 'Guarantees that the absolute best solution discovered never gets lost.',
        howImplemented: 'Preserves top 2 fittest individuals directly into Generation N+1.',
        topicKey: 'Elitism',
      ),
      _GaWorkflowStep(
        stepNumber: 'STEP 7',
        title: 'Termination Check',
        whatHappens: 'Stops execution when maximum generations are reached or target fitness achieved.',
        whyNeeded: 'Terminates search loop once convergence or iteration limits are met.',
        howImplemented: 'Stops simulation timer at max generations (e.g. 50) and highlights final best solution.',
        topicKey: 'Generation',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.auto_awesome_mosaic_rounded, color: AppColors.gold, size: 22),
            SizedBox(width: 8),
            Text(
              'HOW GA POWERS THIS APPLICATION',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'This application uses a Genetic Algorithm engine written entirely in Dart to optimize candidate solutions locally inside Flutter.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          children: steps.map((s) => _buildStepCard(context, s, isDark)).toList(),
        ),
      ],
    );
  }

  Widget _buildStepCard(BuildContext context, _GaWorkflowStep step, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      step.stepNumber,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppColors.navy,
                    ),
                  ),
                ],
              ),
              InfoTooltipButton(topicKey: step.topicKey, size: 16),
            ],
          ),
          const SizedBox(height: 10),
          _buildDetailRow('What happens:', step.whatHappens, isDark),
          const SizedBox(height: 4),
          _buildDetailRow('Why needed:', step.whyNeeded, isDark),
          const SizedBox(height: 4),
          _buildDetailRow('How implemented:', step.howImplemented, isDark, isHighlight: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String text, bool isDark, {bool isHighlight = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.gold : (isDark ? Colors.white70 : AppColors.lightTextPrimary),
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isHighlight
                  ? (isDark ? Colors.white : AppColors.navy)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
          ),
        ),
      ],
    );
  }
}

class _GaWorkflowStep {
  final String stepNumber;
  final String title;
  final String whatHappens;
  final String whyNeeded;
  final String howImplemented;
  final String topicKey;

  const _GaWorkflowStep({
    required this.stepNumber,
    required this.title,
    required this.whatHappens,
    required this.whyNeeded,
    required this.howImplemented,
    required this.topicKey,
  });
}
