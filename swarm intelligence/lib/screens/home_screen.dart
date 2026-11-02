import 'dart:math';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/algorithm_type.dart';
import '../services/simulation_controller.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/common/metric_badge.dart';

class HomeScreen extends StatefulWidget {
  final SimulationController controller;
  final ValueChanged<int> onNavigateToTab;
  final VoidCallback onOpenPresentationMode;
  final VoidCallback onOpenExperimentMode;
  final VoidCallback onOpenHowItWorks;

  const HomeScreen({
    super.key,
    required this.controller,
    required this.onNavigateToTab,
    required this.onOpenPresentationMode,
    required this.onOpenExperimentMode,
    required this.onOpenHowItWorks,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _heroAnimController;

  @override
  void initState() {
    super.initState();
    _heroAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _heroAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final hasRunSim = controller.totalSimulationsCompleted > 0 || controller.currentIteration > 0;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner with Animated Swarm Canvas
              _buildHeroBanner(isDark),
              const SizedBox(height: 24),

              // Live Dashboard Activity Statistics
              _buildDashboardStats(controller, hasRunSim, isDark),
              const SizedBox(height: 32),

              // Visual Workflow Card
              _buildWorkflowSection(isDark),
              const SizedBox(height: 32),

              // Quick Launch Algorithm Cards
              _buildAlgorithmHighlights(isDark),
              const SizedBox(height: 32),

              // How Swarm Intelligence Works Inside This App
              _buildHowItWorksSection(isDark),
              const SizedBox(height: 32),

              // College Demo & Lab Modes (Presentation & Experiment)
              _buildModesRow(isDark),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroBanner(bool isDark) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.heroGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryNavy.withValues(alpha: 0.3),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background animated particles
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedBuilder(
                animation: _heroAnimController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _HeroSwarmPainter(progress: _heroAnimController.value),
                  );
                },
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.gold, width: 1),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.gold, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Swarm Intelligence Lab',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Small Agents. Collective Intelligence. Better Solutions.',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Explore nature-inspired algorithms that optimize routes, search spaces, and resource allocation.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 10,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => widget.onNavigateToTab(1), // Simulator
                      icon: const Icon(Icons.play_arrow_rounded, color: AppColors.primaryNavy),
                      label: const Text(
                        'Start Simulation',
                        style: TextStyle(color: AppColors.primaryNavy, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => widget.onNavigateToTab(2), // Algorithms
                      icon: const Icon(Icons.hub_rounded, color: Colors.white),
                      label: const Text('Explore Algorithms', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => widget.onNavigateToTab(3), // Learn
                      icon: const Icon(Icons.school_rounded, color: AppColors.gold),
                      label: const Text(
                        'Learn Swarm Intelligence',
                        style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardStats(SimulationController controller, bool hasRunSim, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lab Activity & Benchmark Metrics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (!hasRunSim)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2E47) : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Awaiting First Run', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 650;
            return GridView.count(
              crossAxisCount: isWide ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isWide ? 2.5 : 2.0,
              children: [
                MetricBadge(
                  label: 'Simulations Run',
                  value: '${controller.totalSimulationsCompleted}',
                  icon: Icons.task_alt_rounded,
                  color: AppColors.green,
                  subtitle: hasRunSim ? 'Local computations' : 'No simulations executed yet',
                ),
                MetricBadge(
                  label: 'Best Fitness',
                  value: controller.currentBestObjective != null
                      ? Formatters.formatFitness(controller.currentBestObjective!)
                      : 'None',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.gold,
                  subtitle: controller.currentBestObjective != null ? 'Minimization optimum' : 'Start simulation to evaluate',
                ),
                MetricBadge(
                  label: 'Active Algorithm',
                  value: controller.selectedAlgorithm.shortName,
                  icon: controller.selectedAlgorithm.icon,
                  color: controller.selectedAlgorithm.accentColor,
                  subtitle: controller.selectedAlgorithm.fullName,
                ),
                MetricBadge(
                  label: 'Iterations Executed',
                  value: '${controller.totalIterationsExecuted + controller.currentIteration}',
                  icon: Icons.sync_rounded,
                  color: AppColors.blue,
                  subtitle: '${controller.evaluationsCount} total evaluations',
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildWorkflowSection(bool isDark) {
    final steps = [
      {'title': 'Initialize Agents', 'desc': 'Spawn population within search bounds', 'icon': Icons.group_add_rounded},
      {'title': 'Observe Environment', 'desc': 'Evaluate objective function values', 'icon': Icons.visibility_rounded},
      {'title': 'Share Information', 'desc': 'Deposit pheromones or broadcast best', 'icon': Icons.share_rounded},
      {'title': 'Update Behaviour', 'desc': 'Adjust velocities or choose paths', 'icon': Icons.update_rounded},
      {'title': 'Explore Search Space', 'desc': 'Balance global search & local exploitation', 'icon': Icons.travel_explore_rounded},
      {'title': 'Discover Better Solutions', 'desc': 'Converge onto mathematical optimum', 'icon': Icons.check_circle_rounded},
    ];

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.account_tree_rounded, color: AppColors.gold, size: 20),
              SizedBox(width: 8),
              Text(
                'Swarm Intelligence Algorithmic Workflow',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'How simple local interactions emerge into collective global intelligence:',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              return isWide
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(steps.length * 2 - 1, (i) {
                        if (i.isOdd) {
                          return const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.gold);
                        }
                        final step = steps[i ~/ 2];
                        return Expanded(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: (isDark ? AppColors.blue : AppColors.primaryNavy).withValues(alpha: 0.15),
                                child: Icon(step['icon'] as IconData, size: 18, color: isDark ? AppColors.accentCyan : AppColors.primaryNavy),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                step['title'] as String,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step['desc'] as String,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    )
                  : Column(
                      children: List.generate(steps.length, (i) {
                        final step = steps[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: (isDark ? AppColors.blue : AppColors.primaryNavy).withValues(alpha: 0.15),
                                child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(step['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(
                                      step['desc'] as String,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAlgorithmHighlights(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Core Swarm Algorithms in This Lab',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAlgoMiniCard(
                AlgorithmType.aco,
                'Ant Colony Optimization',
                'Simulates pheromone trails for TSP routing & obstacle grid navigation.',
                'alpha, beta, rho, Q',
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAlgoMiniCard(
                AlgorithmType.pso,
                'Particle Swarm Optimization',
                'Coordinates particles in continuous space using cognitive and social vectors.',
                'w, c1, c2, bounds',
                isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAlgoMiniCard(
                AlgorithmType.abc,
                'Artificial Bee Colony',
                'Employs foraging phases (Employed, Onlooker, Scout) to discover optimal nectar.',
                'sources, onlookers, limit',
                isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlgoMiniCard(
    AlgorithmType type,
    String title,
    String desc,
    String params,
    bool isDark,
  ) {
    return CustomCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        widget.controller.setAlgorithm(type);
        widget.onNavigateToTab(1); // Go to Simulator
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: type.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(type.icon, color: type.accentColor, size: 20),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'Params: $params',
            style: TextStyle(
              fontSize: 10,
              fontFamily: 'monospace',
              color: type.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(bool isDark) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.psychology_rounded, color: AppColors.green, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How Swarm Intelligence Works Inside This App',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '100% Genuine Dart Execution • Zero Fake Simulations',
                      style: TextStyle(fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Every particle position, velocity vector, ant route, pheromone evaporation, bee nectar evaluation, and convergence metric is calculated in real time locally in Dart. No hardcoded or pre-rendered trajectories are used. When you run a simulation, you are executing real stochastic computational intelligence algorithms.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: widget.onOpenHowItWorks,
              icon: const Icon(Icons.menu_book_rounded, size: 16),
              label: const Text('Read Architectural Breakdown'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModesRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: CustomCard(
            onTap: widget.onOpenPresentationMode,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.co_present_rounded, color: AppColors.gold, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Presentation Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(height: 2),
                      Text('Step-by-step academic viva demonstration', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomCard(
            onTap: widget.onOpenExperimentMode,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.science_rounded, color: AppColors.blue, size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Experiment Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      SizedBox(height: 2),
                      Text('Controlled benchmark testing & export', style: TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroSwarmPainter extends CustomPainter {
  final double progress;

  _HeroSwarmPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42); // fixed seed for aesthetic particle paths
    const agentCount = 35;
    final target = Offset(size.width * 0.85, size.height * 0.5);

    // Target goal glow
    canvas.drawCircle(
      target,
      24,
      Paint()..color = AppColors.gold.withValues(alpha: 0.12),
    );
    canvas.drawCircle(
      target,
      6,
      Paint()..color = AppColors.gold.withValues(alpha: 0.6),
    );

    // Dynamic flock of particles
    for (int i = 0; i < agentCount; i++) {
      final startX = rng.nextDouble() * (size.width * 0.4);
      final startY = rng.nextDouble() * size.height;

      final phase = (progress + (i / agentCount)) % 1.0;
      final curX = startX + (target.dx - startX) * phase + sin(phase * pi * 4 + i) * 15;
      final curY = startY + (target.dy - startY) * phase + cos(phase * pi * 4 + i) * 15;

      final pColor = (i % 3 == 0)
          ? AppColors.gold.withValues(alpha: 0.4)
          : (i % 3 == 1)
              ? Colors.white.withValues(alpha: 0.3)
              : AppColors.accentCyan.withValues(alpha: 0.35);

      canvas.drawCircle(Offset(curX, curY), 2.5, Paint()..color = pColor);
    }
  }

  @override
  bool shouldRepaint(covariant _HeroSwarmPainter oldDelegate) => oldDelegate.progress != progress;
}
