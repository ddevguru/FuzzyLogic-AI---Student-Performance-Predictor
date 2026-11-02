import 'package:flutter/material.dart';
import '../algorithms/abc/abc_solver.dart';
import '../algorithms/pso/pso_solver.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/algorithm_type.dart';
import '../models/benchmark_function.dart';
import '../models/comparison_result.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/simulation/convergence_chart.dart';

class AlgorithmsScreen extends StatefulWidget {
  final ValueChanged<AlgorithmType>? onSelectAlgorithmForSimulator;

  const AlgorithmsScreen({super.key, this.onSelectAlgorithmForSimulator});

  @override
  State<AlgorithmsScreen> createState() => _AlgorithmsScreenState();
}

class _AlgorithmsScreenState extends State<AlgorithmsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Comparison State
  BenchmarkType _comparisonBenchmark = BenchmarkType.sphere;
  int _comparisonIterations = 80;
  final int _comparisonAgents = 30;
  int _comparisonSeed = 42;
  bool _isComparing = false;
  ComparisonResult? _psoResult;
  ComparisonResult? _abcResult;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _runComparison() {
    setState(() {
      _isComparing = true;
    });

    Future.microtask(() {
      // 1. Run PSO
      final psoSwarm = PsoSolver(
        benchmark: _comparisonBenchmark,
        particleCount: _comparisonAgents,
        seed: _comparisonSeed,
      );
      final psoWatch = Stopwatch()..start();
      for (int i = 0; i < _comparisonIterations; i++) {
        psoSwarm.stepIteration();
      }
      psoWatch.stop();

      final psoRes = ComparisonResult(
        algorithm: AlgorithmType.pso,
        configurationName: 'Standard PSO (w=0.729, c1=1.494, c2=1.494)',
        problemName: _comparisonBenchmark.name,
        iterations: _comparisonIterations,
        evaluationCount: _comparisonIterations * _comparisonAgents,
        durationMs: psoWatch.elapsedMilliseconds,
        bestObjective: psoSwarm.globalBestFitness,
        finalAverageObjective: psoSwarm.history.lastOrNull?.averageObjective ?? 0.0,
        convergenceHistory: List.from(psoSwarm.history),
        solutionDescription: '(${psoSwarm.globalBestPosition[0].toStringAsFixed(4)}, ${psoSwarm.globalBestPosition[1].toStringAsFixed(4)})',
        parameters: {'w': 0.729, 'c1': 1.494, 'c2': 1.494, 'particles': _comparisonAgents},
      );

      // 2. Run ABC
      final abcSwarm = AbcSolver(
        benchmark: _comparisonBenchmark,
        foodSourceCount: (_comparisonAgents / 2).ceil(),
        onlookerBeeCount: (_comparisonAgents / 2).ceil(),
        abandonmentLimit: _comparisonAgents,
        seed: _comparisonSeed,
      );
      final abcWatch = Stopwatch()..start();
      for (int i = 0; i < _comparisonIterations; i++) {
        abcSwarm.stepIteration();
      }
      abcWatch.stop();

      final abcRes = ComparisonResult(
        algorithm: AlgorithmType.abc,
        configurationName: 'Standard ABC (Employed + Onlooker + Scout)',
        problemName: _comparisonBenchmark.name,
        iterations: _comparisonIterations,
        evaluationCount: _comparisonIterations * (abcSwarm.foodSources.length + abcSwarm.onlookerBeeCount),
        durationMs: abcWatch.elapsedMilliseconds,
        bestObjective: abcSwarm.bestFoodSource?.objectiveValue ?? 0.0,
        finalAverageObjective: abcSwarm.history.lastOrNull?.averageObjective ?? 0.0,
        convergenceHistory: List.from(abcSwarm.history),
        solutionDescription: abcSwarm.bestFoodSource != null
            ? '(${abcSwarm.bestFoodSource!.position[0].toStringAsFixed(4)}, ${abcSwarm.bestFoodSource!.position[1].toStringAsFixed(4)})'
            : '—',
        parameters: {'sources': abcSwarm.foodSources.length, 'onlookers': abcSwarm.onlookerBeeCount, 'limit': _comparisonAgents},
      );

      setState(() {
        _psoResult = psoRes;
        _abcResult = abcRes;
        _isComparing = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          color: isDark ? AppColors.darkSurface : AppColors.white,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.gold,
            labelColor: isDark ? Colors.white : AppColors.primaryNavy,
            unselectedLabelColor: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
            tabs: const [
              Tab(text: 'Ant Colony (ACO)'),
              Tab(text: 'Particle Swarm (PSO)'),
              Tab(text: 'Artificial Bee Colony (ABC)'),
              Tab(text: 'Algorithm Comparison'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAcoDetailTab(isDark),
          _buildPsoDetailTab(isDark),
          _buildAbcDetailTab(isDark),
          _buildComparisonTab(isDark),
        ],
      ),
    );
  }

  Widget _buildAcoDetailTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(
            title: 'Ant Colony Optimization (ACO)',
            subtitle: 'Stigmergy, Pheromone Deposition & Combinatorial Route Construction',
            color: AppColors.gold,
            icon: Icons.alt_route_rounded,
            onLaunch: () => widget.onSelectAlgorithmForSimulator?.call(AlgorithmType.aco),
          ),
          const SizedBox(height: 20),
          _buildMathFormulaCard(
            'ACO Transition Probability Rule',
            'P(i, j) = \\frac{\\tau(i, j)^\\alpha \\cdot \\eta(i, j)^\\beta}{\\sum_{k \\in \\text{allowed}} \\tau(i, k)^\\alpha \\cdot \\eta(i, k)^\\beta}',
            'Where tau(i,j) represents pheromone trail concentration and eta(i,j) = 1/d(i,j) is greedy heuristic desirability. Exponents alpha and beta govern the relative balance between pheromone memory and greedy distance.',
            isDark,
          ),
          const SizedBox(height: 16),
          _buildMathFormulaCard(
            'Pheromone Evaporation & Update Rule',
            '\\tau(i, j) \\leftarrow (1 - \\rho) \\cdot \\tau(i, j) + \\sum_{k=1}^m \\Delta \\tau(i, j)^k, \\quad \\Delta \\tau(i, j)^k = \\frac{Q}{L_k}',
            'Evaporation factor rho (in [0, 1]) removes old pheromone to prevent premature stagnation on suboptimal routes. Successful ants deposit Q / L_k along traversed edges, giving shorter circuits higher reinforcement.',
            isDark,
          ),
          const SizedBox(height: 20),
          _buildParametersTable(
            [
              {'param': 'alpha', 'range': '0.5 – 3.0', 'effect': 'Pheromone weight. Higher values encourage ants to follow established trails.'},
              {'param': 'beta', 'range': '1.0 – 5.0', 'effect': 'Heuristic weight (1/distance). Higher values cause greedy nearest-neighbor hops.'},
              {'param': 'rho', 'range': '0.05 – 0.5', 'effect': 'Evaporation rate. Balances historical memory retention with new route exploration.'},
              {'param': 'Q', 'range': '50 – 200', 'effect': 'Pheromone scaling constant deposited on completed tours.'},
              {'param': 'Ant Count', 'range': '10 – 50', 'effect': 'Number of exploratory ants per iteration. Scales evaluation throughput.'},
            ],
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPsoDetailTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(
            title: 'Particle Swarm Optimization (PSO)',
            subtitle: 'Velocity Vectors, Cognitive Memory & Social Swarm Attraction',
            color: AppColors.blue,
            icon: Icons.grain_rounded,
            onLaunch: () => widget.onSelectAlgorithmForSimulator?.call(AlgorithmType.pso),
          ),
          const SizedBox(height: 20),
          _buildMathFormulaCard(
            'Standard PSO Velocity Update Equation',
            'v_i(t+1) = w \\cdot v_i(t) + c_1 r_1 (pbest_i - x_i(t)) + c_2 r_2 (gbest - x_i(t))',
            'Where w is inertia weight, c1 is cognitive coefficient, c2 is social coefficient, and r1, r2 are random numbers in [0, 1]. Combines existing momentum with individual memory and collective swarm consensus.',
            isDark,
          ),
          const SizedBox(height: 16),
          _buildMathFormulaCard(
            'Position Update Rule & Boundary Clamping',
            'x_i(t+1) = x_i(t) + v_i(t+1), \\quad v_i(t+1) \\in [-v_{max}, v_{max}]',
            'Particles update continuous coordinates by adding newly computed velocity vectors. Velocity bounds prevent chaotic oscillations and runaway divergence across open search landscapes.',
            isDark,
          ),
          const SizedBox(height: 20),
          _buildParametersTable(
            [
              {'param': 'w (Inertia)', 'range': '0.4 – 0.9', 'effect': 'Controls flight momentum. Higher w favors global exploration; lower w favors local convergence.'},
              {'param': 'c1 (Cognitive)', 'range': '1.2 – 2.0', 'effect': 'Attraction weight toward the particle\'s own personal best coordinate.'},
              {'param': 'c2 (Social)', 'range': '1.2 – 2.0', 'effect': 'Attraction weight toward the swarm\'s global best coordinate.'},
              {'param': 'v_max', 'range': '0.1 – 0.3 * Range', 'effect': 'Clamps maximum step per iteration to stabilize search trajectories.'},
              {'param': 'Swarm Size', 'range': '20 – 60', 'effect': 'Number of particles searching the continuous landscape simultaneously.'},
            ],
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAbcDetailTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderBanner(
            title: 'Artificial Bee Colony (ABC)',
            subtitle: 'Employed, Onlooker & Scout Bee Foraging Dynamics',
            color: AppColors.green,
            icon: Icons.hive_rounded,
            onLaunch: () => widget.onSelectAlgorithmForSimulator?.call(AlgorithmType.abc),
          ),
          const SizedBox(height: 20),
          _buildMathFormulaCard(
            'Employed & Onlooker Neighbor Mutation Rule',
            'v_{ij} = x_{ij} + \\phi_{ij} (x_{ij} - x_{kj}), \\quad \\phi_{ij} \\in [-1, 1]',
            'Generates a candidate solution v in the neighborhood of food source x_i by perturbing dimension j relative to another random food source x_k. Uses greedy selection to retain improvements.',
            isDark,
          ),
          const SizedBox(height: 16),
          _buildMathFormulaCard(
            'Onlooker Waggle Dance Selection & Scout Abandonment',
            'P_i = \\frac{fit_i}{\\sum fit_k}, \\quad \\text{if } trial_i \\ge limit \\implies x_i \\sim U(x_{min}, x_{max})',
            'Onlooker bees select food sources proportionally to fitness (nectar quality). If a source cannot be improved within the abandonment limit, it is discarded and replaced with a fresh random scout position.',
            isDark,
          ),
          const SizedBox(height: 20),
          _buildParametersTable(
            [
              {'param': 'Food Sources (SN)', 'range': '10 – 40', 'effect': 'Number of candidate solutions, equal to the number of employed bees.'},
              {'param': 'Onlooker Bees', 'range': '10 – 40', 'effect': 'Bees recruited in hive to exploit high-fitness sources via probability P_i.'},
              {'param': 'Abandonment Limit', 'range': 'SN * Dimension', 'effect': 'Maximum unimproved trials before a food source is abandoned by scout bees.'},
              {'param': 'phi', 'range': '[-1.0, 1.0]', 'effect': 'Random step perturbation multiplier for neighborhood candidate discovery.'},
            ],
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTab(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.compare_arrows_rounded, color: AppColors.gold, size: 24),
                    SizedBox(width: 10),
                    Text(
                      'Controlled Algorithmic Benchmarking',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Run Particle Swarm Optimization (PSO) and Artificial Bee Colony (ABC) on identical objective functions under identical evaluation budgets and random seeds to observe convergence disparities.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<BenchmarkType>(
                      value: _comparisonBenchmark,
                      items: BenchmarkType.values.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => _comparisonBenchmark = v);
                      },
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Iters: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        DropdownButton<int>(
                          value: _comparisonIterations,
                          items: const [
                            DropdownMenuItem(value: 50, child: Text('50')),
                            DropdownMenuItem(value: 80, child: Text('80')),
                            DropdownMenuItem(value: 120, child: Text('120')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _comparisonIterations = v);
                          },
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Seed: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        DropdownButton<int>(
                          value: _comparisonSeed,
                          items: const [
                            DropdownMenuItem(value: 42, child: Text('42')),
                            DropdownMenuItem(value: 100, child: Text('100')),
                            DropdownMenuItem(value: 999, child: Text('999')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _comparisonSeed = v);
                          },
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: _isComparing ? null : _runComparison,
                      icon: const Icon(Icons.play_circle_filled_rounded),
                      label: Text(_isComparing ? 'Running Trial...' : 'Run Comparative Benchmark'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (_psoResult != null && _abcResult != null) ...[
            // Side-by-side Results Table
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Benchmark Results (Lower Objective is Better)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Divider(height: 16),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Metric')),
                        DataColumn(label: Text('PSO')),
                        DataColumn(label: Text('ABC')),
                        DataColumn(label: Text('Winner / Analysis')),
                      ],
                      rows: [
                        DataRow(cells: [
                          const DataCell(Text('Best Objective')),
                          DataCell(Text(Formatters.formatFitness(_psoResult!.bestObjective))),
                          DataCell(Text(Formatters.formatFitness(_abcResult!.bestObjective))),
                          DataCell(Text(
                            _psoResult!.bestObjective < _abcResult!.bestObjective ? 'PSO Superior' : 'ABC Superior',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.green),
                          )),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Final Solution (x, y)')),
                          DataCell(Text(_psoResult!.solutionDescription)),
                          DataCell(Text(_abcResult!.solutionDescription)),
                          DataCell(Text('Theoretical: ${_comparisonBenchmark.globalOptimumVal} at ${_comparisonBenchmark.globalOptimumPos}')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Evaluations')),
                          DataCell(Text('${_psoResult!.evaluationCount}')),
                          DataCell(Text('${_abcResult!.evaluationCount}')),
                          const DataCell(Text('Equal evaluation budget')),
                        ]),
                        DataRow(cells: [
                          const DataCell(Text('Duration')),
                          DataCell(Text('${_psoResult!.durationMs}ms')),
                          DataCell(Text('${_abcResult!.durationMs}ms')),
                          const DataCell(Text('Execution latency')),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Convergence Curves Comparison
            Row(
              children: [
                Expanded(
                  child: ConvergenceChart(
                    title: 'PSO Convergence Curve',
                    history: _psoResult!.convergenceHistory,
                    primaryLineColor: AppColors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ConvergenceChart(
                    title: 'ABC Convergence Curve',
                    history: _abcResult!.convergenceHistory,
                    primaryLineColor: AppColors.green,
                  ),
                ),
              ],
            ),
          ] else
            Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.query_stats_rounded, size: 50, color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight),
                  const SizedBox(height: 12),
                  const Text('Click "Run Comparative Benchmark" to execute simultaneous PSO vs ABC trials locally.', style: TextStyle(fontSize: 13)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner({
    required String title,
    required String subtitle,
    required Color color,
    required IconData icon,
    required VoidCallback onLaunch,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: onLaunch,
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Simulate'),
            style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMathFormulaCard(String title, String formula, String explanation, bool isDark) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1B2E) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF1E2E47) : const Color(0xFFCBD5E1)),
            ),
            child: Text(
              formula,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppColors.accentCyan : AppColors.primaryNavy,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(explanation, style: TextStyle(fontSize: 12, color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight, height: 1.4)),
        ],
      ),
    );
  }

  Widget _buildParametersTable(List<Map<String, String>> params, bool isDark) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recommended Parameters & Sensitivity Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const Divider(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('Parameter')),
                DataColumn(label: Text('Typical Range')),
                DataColumn(label: Text('Effect & Tuning Behavior')),
              ],
              rows: params.map((p) {
                return DataRow(cells: [
                  DataCell(Text(p['param']!, style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'))),
                  DataCell(Text(p['range']!)),
                  DataCell(Text(p['effect']!)),
                ]);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
