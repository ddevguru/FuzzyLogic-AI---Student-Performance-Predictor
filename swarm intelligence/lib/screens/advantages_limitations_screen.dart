import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../widgets/common/custom_card.dart';

class AdvantagesLimitationsScreen extends StatelessWidget {
  const AdvantagesLimitationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final limitationsData = [
      {
        'title': 'No Guarantee of Global Optimality',
        'why': 'Swarm intelligence algorithms are stochastic metaheuristics, not exact mathematical proofs.',
        'effect': 'The algorithm returns high-quality near-optimal approximations, but cannot prove if an absolute global minimum was found.',
        'mitigation': 'Run multiple trials with varied random seeds, use hybrid local search (e.g. 2-opt for ACO), or set rigorous fitness acceptance thresholds.',
      },
      {
        'title': 'Premature Convergence & Stagnation',
        'why': 'Social attraction (gbest or intense pheromones) overwhelms exploration, causing all agents to collapse into a deceptive local minimum.',
        'effect': 'Particles stop exploring fresh valleys; convergence charts flatten out early on suboptimal peaks.',
        'mitigation': 'Increase inertia weight w or mutation rates; implement scout bee abandonment; maintain minimum pheromone floors (tau_min).',
      },
      {
        'title': 'Sensitivity to Hyperparameters',
        'why': 'Complex nonlinear interplay between parameters (e.g., alpha vs beta in ACO, or inertia vs cognitive/social coefficients in PSO).',
        'effect': 'Poor parameter choices cause either erratic chaotic wandering (over-exploration) or instant freezing (under-exploration).',
        'mitigation': 'Use time-varying parameter schedules (linearly decreasing inertia w from 0.9 to 0.4) or adaptive parameter tuning.',
      },
      {
        'title': 'Stochastic Variability Across Runs',
        'why': 'Initial population placement and neighborhood perturbations rely on pseudo-random numbers.',
        'effect': 'Consecutive simulation runs may discover slightly different final solutions and take varying iteration counts.',
        'mitigation': 'Conduct statistical benchmarking across multiple independent runs (reporting mean and standard deviation) or lock seeds for reproducibility.',
      },
      {
        'title': 'Computational Cost with High Agent Counts',
        'why': 'Evaluating objective functions N times per iteration scales linearly with population size and dimensionality.',
        'effect': 'Very large swarms on complex objective functions can slow down execution frames and consume significant battery/CPU.',
        'mitigation': 'Use population throttling, surrogate objective models, or multi-threaded background isolate execution.',
      },
      {
        'title': 'ACO Stagnation on High-Dimensional Graphs',
        'why': 'As city count scales above 100, the graph edge count grows quadratically (N^2), requiring many ants and iterations to lay meaningful pheromones.',
        'effect': 'Early iterations wander randomly before positive stigmergy crystallizes.',
        'mitigation': 'Employ Max-Min Ant System (MMAS) bounds, candidate lists, and local search heuristics like 2-opt.',
      },
      {
        'title': 'PSO Particle Velocity Divergence & Chaos',
        'why': 'Excessive cognitive (c1) or social (c2) acceleration can fling particles beyond landscape boundaries.',
        'effect': 'Particles oscillate wildly or escape search bounds.',
        'mitigation': 'Enforce velocity clamping (-v_max to +v_max) and boundary reflection or damping.',
      },
      {
        'title': 'ABC Sensitivity to Abandonment Limit',
        'why': 'If the trial limit is set too low, good food sources get abandoned prematurely; if set too high, bees waste time in dead ends.',
        'effect': 'Slow convergence or frequent disruptive scout respawns.',
        'mitigation': 'Scale abandonment limit proportionally to food source count multiplied by problem dimension: limit = SN * D.',
      },
    ];

    final advantagesData = [
      'Derivative-Free Optimization: Operates without requiring mathematical derivatives or gradients (ideal for discontinuous, black-box, or non-differentiable fitness landscapes).',
      'Robust Population-Based Search: Multiple parallel search agents explore diverse regions simultaneously, avoiding single-point gradient trap vulnerability.',
      'Decentralized Self-Healing Architecture: No central coordinator or single point of failure; if individual agents fail or get trapped, the collective swarm succeeds.',
      'Broad Problem Representation Flexibility: Readily adapted to continuous real-valued optimization, discrete combinatorial graphs, or binary routing.',
      'Tunable Exploration-Exploitation Trade-Off: Parameters (w, alpha, beta, limits) provide precise control over global breadth vs local refinement.',
      'Scalable Parallelism: Agent evaluations are embarrassingly parallelizable across CPU threads, GPUs, or distributed compute clusters.',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Advantages & Limitations'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Advantages Section
            CustomCard(
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
                        child: const Icon(Icons.thumb_up_alt_rounded, color: AppColors.green, size: 22),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Core Algorithmic Advantages',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  ...advantagesData.map((adv) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                adv,
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
            ),
            const SizedBox(height: 24),

            // Limitations Section
            const Text(
              'Algorithmic Limitations, Causes & Mitigations',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'A scientifically accurate engineering evaluation requires understanding why limitations occur and how computational intelligence engineers mitigate them:',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
              ),
            ),
            const SizedBox(height: 14),

            ...limitationsData.map((lim) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: CustomCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                lim['title']!,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        _buildLimitationSubItem('Why it Occurs:', lim['why']!, isDark),
                        _buildLimitationSubItem('Its Effect:', lim['effect']!, isDark),
                        _buildLimitationSubItem('Engineering Mitigation:', lim['mitigation']!, isDark, isHighlight: true),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitationSubItem(String label, String text, bool isDark, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isHighlight ? AppColors.green : (isDark ? Colors.white70 : AppColors.mainText),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
