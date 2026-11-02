import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EducationalTopic {
  final String title;
  final String definition;
  final String example;
  final String roleInGA;

  const EducationalTopic({
    required this.title,
    required this.definition,
    required this.example,
    required this.roleInGA,
  });

  static const Map<String, EducationalTopic> topics = {
    'Chromosome': EducationalTopic(
      title: 'Chromosome',
      definition: 'A binary string or vector of values representing a single complete candidate solution to an optimization problem.',
      example: '[1, 0, 1, 1, 0, 1, 0] or City permutation [3, 1, 0, 2]',
      roleInGA: 'Carries genetic information of an individual solution through selection, crossover and mutation across generations.',
    ),
    'Gene': EducationalTopic(
      title: 'Gene',
      definition: 'A single atomic element or building block parameter inside a chromosome string.',
      example: 'The 4th bit "1" in binary string [1, 0, 1, 1]',
      roleInGA: 'Encodes specific traits (e.g. single item selection, single city connection, or binary bit value).',
    ),
    'Population': EducationalTopic(
      title: 'Population',
      definition: 'A collection of candidate solution chromosomes maintained together in a single generation generation cycle.',
      example: 'A group of 50 candidate schedules or 50 delivery routes.',
      roleInGA: 'Maintains genetic diversity so evolutionary operations can explore multiple search paths simultaneously.',
    ),
    'Fitness Function': EducationalTopic(
      title: 'Fitness Function',
      definition: 'A objective evaluation metric measuring how close a candidate solution is to solving the target problem.',
      example: 'f(x) = x · sin(x) + 10 or (1000 / Total Route Distance in km)',
      roleInGA: 'Acts as natural selection criteria, assigning higher survival probabilities to superior individuals.',
    ),
    'Selection': EducationalTopic(
      title: 'Selection',
      definition: 'The survival-of-the-fittest mechanism choosing parent chromosomes based on fitness values to breed offspring.',
      example: 'Tournament Selection (k=3) where best candidate out of 3 random candidates wins parent status.',
      roleInGA: 'Drives population convergence toward optimal regions by favoring high-fitness traits.',
    ),
    'Crossover': EducationalTopic(
      title: 'Crossover (Recombination)',
      definition: 'A genetic operator combining genetic material from two selected parent chromosomes to form child chromosomes.',
      example: 'Single-point crossover splitting parents at position 4 to exchange sub-strings.',
      roleInGA: 'Combines partial high-quality solutions (building blocks) from parents to discover superior child solutions.',
    ),
    'Mutation': EducationalTopic(
      title: 'Mutation',
      definition: 'A random transformation applied to one or more gene values with low probability (e.g. 5%).',
      example: 'Bit flip turning bit 0 to 1, or swapping city position 2 and 5.',
      roleInGA: 'Prevents premature convergence by injecting new genetic diversity and helping escape local optima traps.',
    ),
    'Elitism': EducationalTopic(
      title: 'Elitism',
      definition: 'The strategy of copying the top N best individuals directly to the next generation without modification.',
      example: 'Copying top 2 fittest chromosomes intact to Generation N+1.',
      roleInGA: 'Guarantees that the overall best fitness discovered so far never degrades from generation to generation.',
    ),
    'Generation': EducationalTopic(
      title: 'Generation',
      definition: 'One complete evolutionary iteration consisting of evaluation, selection, crossover, mutation, and replacement.',
      example: 'Iterating from Generation 1 to Generation 50.',
      roleInGA: 'Tracks progressive evolutionary milestones towards optimum solution convergence.',
    ),
  };
}

class EducationalPopupDialog extends StatelessWidget {
  final String topicKey;

  const EducationalPopupDialog({super.key, required this.topicKey});

  static void show(BuildContext context, String topicKey) {
    showDialog(
      context: context,
      builder: (ctx) => EducationalPopupDialog(topicKey: topicKey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topic = EducationalTopic.topics[topicKey] ??
        EducationalTopic(
          title: topicKey,
          definition: 'Core Genetic Algorithm concept used for optimization.',
          example: 'Applied dynamically in the local Dart simulation engine.',
          roleInGA: 'Drives candidate evolution toward high fitness.',
        );

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lightbulb_rounded, color: AppColors.gold, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topic.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSection(
              title: 'DEFINITION',
              content: topic.definition,
              icon: Icons.article_outlined,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: 'EXAMPLE',
              content: topic.example,
              icon: Icons.code_rounded,
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildSection(
              title: 'ROLE IN GENETIC ALGORITHM',
              content: topic.roleInGA,
              icon: Icons.auto_awesome_rounded,
              isDark: isDark,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('GOT IT', style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.blue),
              const SizedBox(width: 6),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.blue,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
