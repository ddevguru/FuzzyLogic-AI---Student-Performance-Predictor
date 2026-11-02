import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/educational_popup_dialog.dart';
import '../../widgets/common/info_tooltip_button.dart';
import '../../widgets/common/section_header.dart';

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Understanding Genetic Algorithm',
            subtitle: 'Master evolutionary computation principles, biological analogies, and optimization concepts.',
            icon: Icons.school_rounded,
          ),
          const SizedBox(height: 12),

          // What is GA? (Simple + Hinglish/Accessible friendly)
          _buildWhatIsGaCard(isDark),

          const SizedBox(height: 16),

          // Biological Analogy Visual Diagram
          _buildBiologicalAnalogyCard(isDark),

          const SizedBox(height: 16),

          // Terminology Dictionary Grid
          _buildTerminologySection(context, isDark),

          const SizedBox(height: 16),

          // Advantages & Limitations
          _buildProsAndConsSection(isDark),

          const SizedBox(height: 16),

          // GA vs Traditional Optimization Table
          _buildComparisonTable(isDark),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildWhatIsGaCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_rounded, color: AppColors.gold, size: 22),
              SizedBox(width: 8),
              Text(
                'WHAT IS A GENETIC ALGORITHM?',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Genetic Algorithm (GA) is an evolutionary optimization heuristic inspired by Charles Darwin’s theory of natural selection. It searches for optimal or near-optimal solutions by initializing a population of candidate solutions and repeatedly applying Selection, Crossover, and Mutation across multiple generations.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.blue.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.record_voice_over_rounded, color: AppColors.blue, size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Simple Summary: Just like in nature where only the fittest animals survive and pass their genes to offspring, GA retains the best solutions and breeds them to discover even better solutions!',
                    style: TextStyle(fontSize: 12, color: AppColors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiologicalAnalogyCard(bool isDark) {
    final analogies = [
      ('Biological World', 'Genetic Algorithm World'),
      ('Organism / Individual', 'Candidate Solution'),
      ('Chromosome / DNA', 'Binary or Integer Vector'),
      ('Gene', 'Single Bit or Element Parameter'),
      ('Fitness / Survival Strength', 'Fitness Function Score'),
      ('Natural Selection', 'Parent Selection Operator'),
      ('Reproduction / Mating', 'Crossover Operator'),
      ('Genetic Mutation', 'Bit-Flip / Swap Mutation'),
      ('Next Generation', 'Evolved Population Iteration'),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.biotech_rounded, color: AppColors.green, size: 22),
              SizedBox(width: 8),
              Text(
                'BIOLOGICAL ANALOGY MAPPING',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(
              color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
              borderRadius: BorderRadius.circular(10),
            ),
            children: analogies.map((row) {
              final isHeader = row.$1 == 'Biological World';
              return TableRow(
                decoration: BoxDecoration(
                  color: isHeader
                      ? AppColors.navy.withOpacity(0.8)
                      : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      row.$1,
                      style: TextStyle(
                        fontWeight: isHeader ? FontWeight.bold : FontWeight.w600,
                        color: isHeader ? Colors.white : (isDark ? Colors.white70 : AppColors.lightTextPrimary),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      row.$2,
                      style: TextStyle(
                        fontWeight: isHeader ? FontWeight.bold : FontWeight.bold,
                        color: isHeader ? AppColors.gold : AppColors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTerminologySection(BuildContext context, bool isDark) {
    final keys = EducationalTopic.topics.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'CORE GA TERMINOLOGY DICTIONARY',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: 1.6,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: keys.length,
          itemBuilder: (context, idx) {
            final key = keys[idx];
            final topic = EducationalTopic.topics[key]!;

            return InkWell(
              onTap: () => EducationalPopupDialog.show(context, key),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          topic.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: isDark ? Colors.white : AppColors.navy,
                          ),
                        ),
                        InfoTooltipButton(topicKey: key, size: 14),
                      ],
                    ),
                    Text(
                      topic.definition,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProsAndConsSection(bool isDark) {
    final advantages = [
      'Works extremely well for complex non-linear optimization problems.',
      'Does not require mathematical gradient or derivative information.',
      'Searches huge multi-dimensional solution spaces effectively.',
      'Can escape local optima traps through mutation and population diversity.',
      'Maintains multiple candidate solutions simultaneously.',
    ];

    final limitations = [
      ('Computationally expensive for huge populations', 'Requires many fitness calculations per generation', 'Use elitism and smaller population sizes with adaptive mutation.'),
      ('No guaranteed global optimum', 'Heuristic search may stop at near-optimal solution', 'Increase generation limits and tune mutation probability.'),
      ('Premature convergence risk', 'High fitness individual dominates population early', 'Use tournament selection with smaller tournament size (k=2).'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: const [
            Icon(Icons.thumb_up_rounded, color: AppColors.green, size: 20),
            SizedBox(width: 8),
            Text('ADVANTAGES OF GENETIC ALGORITHMS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: advantages
              .map((adv) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 16),
                        const SizedBox(width: 8),
                        Expanded(child: Text(adv, style: const TextStyle(fontSize: 12))),
                      ],
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 14),
        Row(
          children: const [
            Icon(Icons.warning_rounded, color: AppColors.accentOrange, size: 20),
            SizedBox(width: 8),
            Text('LIMITATIONS & PRACTICAL MITIGATIONS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 8),
        Column(
          children: limitations
              .map((lim) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.accentOrange.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ${lim.$1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accentOrange, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text('Why: ${lim.$2}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('Solution: ${lim.$3}', style: const TextStyle(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildComparisonTable(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.compare_arrows_rounded, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text('GA VS TRADITIONAL MATHEMATICAL OPTIMIZATION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 10),
          Table(
            border: TableBorder.all(color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder),
            children: const [
              TableRow(
                decoration: BoxDecoration(color: AppColors.navy),
                children: [
                  Padding(padding: EdgeInsets.all(6), child: Text('Feature', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Traditional Calculus', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Genetic Algorithm', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold, fontSize: 11))),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: EdgeInsets.all(6), child: Text('Derivatives', style: TextStyle(fontSize: 10))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Requires gradient info', style: TextStyle(fontSize: 10))),
                  Padding(padding: EdgeInsets.all(6), child: Text('No derivatives needed', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.green))),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: EdgeInsets.all(6), child: Text('Search Points', style: TextStyle(fontSize: 10))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Single point search', style: TextStyle(fontSize: 10))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Population parallel search', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.green))),
                ],
              ),
              TableRow(
                children: [
                  Padding(padding: EdgeInsets.all(6), child: Text('Local Optima', style: TextStyle(fontSize: 10))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Gets trapped easily', style: TextStyle(fontSize: 10))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Escapes via mutation', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.green))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
