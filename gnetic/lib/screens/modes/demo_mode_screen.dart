import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/custom_button.dart';

class DemoModeScreen extends StatefulWidget {
  const DemoModeScreen({super.key});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const DemoModeScreen()),
    );
  }

  @override
  State<DemoModeScreen> createState() => _DemoModeScreenState();
}

class _DemoModeScreenState extends State<DemoModeScreen> {
  int _currentStep = 0;

  final List<_DemoStep> _demoSteps = const [
    _DemoStep(
      stepTitle: 'Step 1: Initialization',
      subtitle: 'Generating Initial Population',
      description: 'The algorithm creates an initial population of candidate solutions randomly. Each individual is represented as a binary chromosome e.g., [1, 0, 1, 1, 0, 1].',
      graphicIcon: Icons.groups_rounded,
      color: AppColors.blue,
      visualSnippet: 'Population Initialized: 50 Individuals\nCandidate #01: [1, 0, 1, 1, 0, 1, 0, 1]\nCandidate #02: [0, 0, 1, 0, 1, 1, 0, 0]',
    ),
    _DemoStep(
      stepTitle: 'Step 2: Fitness Evaluation',
      subtitle: 'Calculating Fitness Scores',
      description: 'Each chromosome is decoded and evaluated against the fitness function f(x) = x · sin(x) + 10 to determine its survival quality score.',
      graphicIcon: Icons.fact_check_rounded,
      color: AppColors.green,
      visualSnippet: 'Candidate #01 Fitness: 42.10 [Average]\nCandidate #02 Fitness: 88.45 [Best - Rank #1]',
    ),
    _DemoStep(
      stepTitle: 'Step 3: Tournament Selection',
      subtitle: 'Selecting High-Fitness Parents',
      description: 'Tournament selection picks 3 random individuals and selects the fittest candidate to become Parent A and Parent B.',
      graphicIcon: Icons.filter_alt_rounded,
      color: AppColors.gold,
      visualSnippet: 'Selected Parent A: [0, 0, 1, 0, 1, 1, 0, 0] (Fitness: 88.45)\nSelected Parent B: [1, 1, 0, 1, 0, 0, 1, 0] (Fitness: 76.20)',
    ),
    _DemoStep(
      stepTitle: 'Step 4: Crossover (Recombination)',
      subtitle: 'Breeding Offspring Chromosomes',
      description: 'Parents exchange chromosome substrings at a random split point (e.g. index 4) to combine partial good traits into child offspring.',
      graphicIcon: Icons.cut_rounded,
      color: AppColors.blueLight,
      visualSnippet: 'Parent A: [0, 0, 1, 0 | 1, 1, 0, 0]\nParent B: [1, 1, 0, 1 | 0, 0, 1, 0]\nChild A:  [0, 0, 1, 0 | 0, 0, 1, 0]',
    ),
    _DemoStep(
      stepTitle: 'Step 5: Mutation',
      subtitle: 'Injecting Genetic Diversity',
      description: 'A random gene bit is flipped (0 → 1 or 1 → 0) with 5% probability to prevent premature convergence and escape local optima.',
      graphicIcon: Icons.auto_fix_high_rounded,
      color: AppColors.accentRed,
      visualSnippet: 'Before Mutation: [0, 0, 1, 0, 0, 0, 1, 0]\nBit 5 Flipped!\nAfter Mutation:  [0, 0, 1, 0, 1, 0, 1, 0] [MUTATED]',
    ),
    _DemoStep(
      stepTitle: 'Step 6: Elitism & Replacement',
      subtitle: 'Forming Next Generation',
      description: 'The top 2 fittest individuals are copied directly intact to Generation N+1 to guarantee non-decreasing best fitness.',
      graphicIcon: Icons.autorenew_rounded,
      color: AppColors.goldLight,
      visualSnippet: 'Elites Preserved: Top 2 Fittest\nGeneration #01 → Generation #02 Population Replaced',
    ),
    _DemoStep(
      stepTitle: 'Step 7: Convergence & Optimum',
      subtitle: 'Optimal Solution Discovered',
      description: 'The algorithm repeats for N generations until the population converges to the global maximum solution!',
      graphicIcon: Icons.emoji_events_rounded,
      color: AppColors.greenLight,
      visualSnippet: 'OPTIMAL SOLUTION DISCOVERED!\nBest Fitness: 98.72% (+92.8% Improvement)\nx = 24.382 ⇒ f(x) = 34.382',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = _demoSteps[_currentStep];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guided GA Interactive Demo Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar
              LinearProgressIndicator(
                value: (_currentStep + 1) / _demoSteps.length,
                minHeight: 8,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                valueColor: AlwaysStoppedAnimation<Color>(step.color),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'STAGE ${_currentStep + 1} OF ${_demoSteps.length}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: step.color,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    step.stepTitle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Main Card
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: step.color, width: 2),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 12, offset: Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: step.color.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(step.graphicIcon, color: step.color, size: 36),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  step.subtitle,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : AppColors.navy,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        step.description,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark ? Colors.white70 : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('LIVE DEMO CODE / DATA SNIPPET:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.gold)),
                      const SizedBox(height: 6),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white12),
                          ),
                          child: Text(
                            step.visualSnippet,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: Colors.white,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Navigation Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomButton(
                    label: 'Previous',
                    icon: Icons.arrow_back_rounded,
                    isOutlined: true,
                    color: Colors.grey,
                    onPressed: _currentStep > 0
                        ? () => setState(() => _currentStep--)
                        : null,
                  ),
                  CustomButton(
                    label: _currentStep < _demoSteps.length - 1 ? 'Next Step' : 'Finish Demo',
                    icon: Icons.arrow_forward_rounded,
                    isPrimary: true,
                    color: step.color,
                    onPressed: () {
                      if (_currentStep < _demoSteps.length - 1) {
                        setState(() => _currentStep++);
                      } else {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoStep {
  final String stepTitle;
  final String subtitle;
  final String description;
  final IconData graphicIcon;
  final Color color;
  final String visualSnippet;

  const _DemoStep({
    required this.stepTitle,
    required this.subtitle,
    required this.description,
    required this.graphicIcon,
    required this.color,
    required this.visualSnippet,
  });
}
