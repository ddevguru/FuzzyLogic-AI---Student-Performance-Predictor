import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/common/custom_card.dart';

class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pipelineSteps = [
      {'num': '1', 'title': 'USER SELECTS A PROBLEM', 'desc': 'User chooses continuous benchmark (Sphere, Rastrigin, Rosenbrock) or combinatorial routing (TSP 8 cities, Grid Pathfinding).'},
      {'num': '2', 'title': 'ALGORITHM & PARAMETERS CONFIGURED', 'desc': 'Engine establishes hyperparameters: agent count (N), iterations (T), alpha/beta/rho (ACO), w/c1/c2 (PSO), or limit (ABC).'},
      {'num': '3', 'title': 'INITIAL AGENTS ARE CREATED', 'desc': 'Dart solver instantiates concrete Agent state models (Ants, ParticleState, FoodSourceState) within search boundaries with seedable RNG.'},
      {'num': '4', 'title': 'AGENTS EVALUATE ENVIRONMENT', 'desc': 'Agents query objective cost functions (distance matrix for TSP, obstacle collision checks for Grid, mathematical equations for continuous landscapes).'},
      {'num': '5', 'title': 'ALGORITHM-SPECIFIC RULES APPLIED', 'desc': 'ACO: ants compute probabilistic transitions. PSO: particles compute cognitive/social accelerations. ABC: employed bees mutate dimensions.'},
      {'num': '6', 'title': 'AGENTS UPDATE POSITIONS OR SOLUTIONS', 'desc': 'Ants append visited nodes to tour. Particles clamp velocities and advance coordinates x(t+1) = x(t) + v(t+1). Food sources undergo greedy replacement.'},
      {'num': '7', 'title': 'FITNESS / OBJECTIVE VALUES CALCULATED', 'desc': 'Exact 64-bit mathematical evaluation calculates total tour distance or function objective score f(x). Objective is strictly minimized.'},
      {'num': '8', 'title': 'INFORMATION IS SHARED OR USED', 'desc': 'ACO: pheromone matrices evaporate and deposit Q/L_k. PSO: global best gbest broadcasts to all particles. ABC: onlooker bees evaluate waggle dance selection probabilities.'},
      {'num': '9', 'title': 'BEST SOLUTION & STATISTICS UPDATED', 'desc': 'Global best memories update; convergence metrics history records (iteration, bestObjective, averageObjective, dispersion).'},
      {'num': '10', 'title': 'PROCESS REPEATS & RESULTS DISPLAYED', 'desc': 'Simulation loops until iteration budget exhausts. Real-time CustomPainter reflects final positions, routes, and telemetry analytics.'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('How Swarm Intelligence Powers This App'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_tree_rounded, color: AppColors.gold, size: 36),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'How Swarm Intelligence Powers This Application',
                          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Complete 10-stage execution pipeline and algorithmic architecture explained.',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 10-Stage Pipeline Flowchart Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('End-to-End Simulation Lifecycle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Divider(height: 16),
                  ...List.generate(pipelineSteps.length, (i) {
                    final item = pipelineSteps[i];
                    return Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: (isDark ? AppColors.blue : AppColors.primaryNavy).withValues(alpha: 0.2),
                              child: Text(
                                item['num']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: isDark ? AppColors.accentCyan : AppColors.primaryNavy,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['desc']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (i < pipelineSteps.length - 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 13, top: 4, bottom: 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 2,
                                height: 16,
                                color: isDark ? const Color(0xFF1E2E47) : const Color(0xFFCBD5E1),
                              ),
                            ),
                          ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Algorithm-Specific Execution Specifics
            const Text('Algorithm-Specific Dart Mechanics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            _buildAlgorithmMechanicsCard(
              title: 'Ant Colony Optimization (ACO)',
              color: AppColors.gold,
              icon: Icons.alt_route_rounded,
              points: [
                'Ants construct routes step-by-step using probabilistic transition equations based on pheromone concentration tau(i,j) and heuristic 1/d.',
                'Pheromone evaporation occurs each iteration across all edges, multiplying existing levels by (1 - rho) to avoid search entrapment.',
                'Traversed edges are deposited with Q / L_k, giving shorter tours exponential positive reinforcement over iterations.',
              ],
              isDark: isDark,
            ),
            const SizedBox(height: 14),

            _buildAlgorithmMechanicsCard(
              title: 'Particle Swarm Optimization (PSO)',
              color: AppColors.blue,
              icon: Icons.grain_rounded,
              points: [
                'Each particle holds continuous position and velocity vectors in R^2, alongside personal best coordinate memory (pbest).',
                'Velocity updates combine inertia weight w * v(t) with cognitive pull toward pbest and social pull toward gbest.',
                'Boundaries clamp velocities and reflect or damp particles hitting search domain edges, maintaining algorithmic stability.',
              ],
              isDark: isDark,
            ),
            const SizedBox(height: 14),

            _buildAlgorithmMechanicsCard(
              title: 'Artificial Bee Colony (ABC)',
              color: AppColors.green,
              icon: Icons.hive_rounded,
              points: [
                'Employed bees explore neighboring food positions v_ij = x_ij + phi * (x_ij - x_kj) and execute greedy replacement.',
                'Onlooker bees in hive evaluate fitness probabilities P_i = fit_i / sum(fit) and focus search on high-nectar sources.',
                'Scout bees track trial failure counters; sources exceeding the abandonment limit are discarded and re-randomized.',
              ],
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmMechanicsCard({
    required String title,
    required Color color,
    required IconData icon,
    required List<String> points,
    required bool isDark,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const Divider(height: 16),
          ...points.map((p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
