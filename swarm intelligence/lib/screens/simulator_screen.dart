import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/algorithm_type.dart';
import '../models/benchmark_function.dart';
import '../services/simulation_controller.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/common/metric_badge.dart';
import '../widgets/simulation/abc_landscape_canvas.dart';
import '../widgets/simulation/convergence_chart.dart';
import '../widgets/simulation/grid_canvas.dart';
import '../widgets/simulation/parameter_slider.dart';
import '../widgets/simulation/pso_landscape_canvas.dart';
import '../widgets/simulation/simulation_controls_bar.dart';
import '../widgets/simulation/tsp_canvas.dart';

class SimulatorScreen extends StatefulWidget {
  final SimulationController controller;

  const SimulatorScreen({super.key, required this.controller});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final TextEditingController _seedInputController = TextEditingController();

  @override
  void dispose() {
    _seedInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 950;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Selectors (Algorithm & Problem Type)
                  _buildAlgorithmAndProblemSelector(controller, isDark),
                  const SizedBox(height: 12),

                  // Simulation Controls Bar
                  SimulationControlsBar(controller: controller),
                  const SizedBox(height: 16),

                  // Main Interactive Section: Visualization + Charts / Parameters
                  if (isDesktop)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Main Visualizer Canvas
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _buildVisualizationContainer(controller, 460),
                              const SizedBox(height: 16),
                              _buildLiveMetricsCards(controller, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Right Column: Parameters & Live Convergence Chart
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              ConvergenceChart(
                                history: controller.currentHistory,
                                primaryLineColor: controller.selectedAlgorithm.accentColor,
                              ),
                              const SizedBox(height: 16),
                              _buildParameterConfigurationCard(controller, isDark),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        _buildVisualizationContainer(controller, 360),
                        const SizedBox(height: 16),
                        _buildLiveMetricsCards(controller, isDark),
                        const SizedBox(height: 16),
                        ConvergenceChart(
                          history: controller.currentHistory,
                          primaryLineColor: controller.selectedAlgorithm.accentColor,
                        ),
                        const SizedBox(height: 16),
                        _buildParameterConfigurationCard(controller, isDark),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAlgorithmAndProblemSelector(SimulationController controller, bool isDark) {
    return CustomCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Algorithm Tabs
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Algorithm: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppColors.mutedTextLight,
                ),
              ),
              const SizedBox(width: 6),
              SegmentedButton<AlgorithmType>(
                segments: AlgorithmType.values.map((algo) {
                  return ButtonSegment<AlgorithmType>(
                    value: algo,
                    label: Text(algo.shortName),
                    icon: Icon(algo.icon, size: 16),
                  );
                }).toList(),
                selected: {controller.selectedAlgorithm},
                onSelectionChanged: (set) {
                  if (set.isNotEmpty) {
                    controller.setAlgorithm(set.first);
                  }
                },
              ),
            ],
          ),

          // Problem Sub-Selector
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Problem Mode: ',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : AppColors.mutedTextLight,
                ),
              ),
              const SizedBox(width: 6),
              if (controller.selectedAlgorithm == AlgorithmType.aco)
                DropdownButtonHideUnderline(
                  child: DropdownButton<AcoProblemMode>(
                    value: controller.selectedAcoMode,
                    dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.mainText,
                    ),
                    items: AcoProblemMode.values.map((m) {
                      return DropdownMenuItem(value: m, child: Text(m.title));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.setAcoMode(val);
                    },
                  ),
                )
              else
                DropdownButtonHideUnderline(
                  child: DropdownButton<BenchmarkType>(
                    value: controller.selectedBenchmark,
                    dropdownColor: isDark ? AppColors.darkSurface : AppColors.white,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.mainText,
                    ),
                    items: BenchmarkType.values.map((b) {
                      return DropdownMenuItem(value: b, child: Text(b.name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.setBenchmark(val);
                    },
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisualizationContainer(SimulationController controller, double height) {
    return SizedBox(
      height: height,
      child: Stack(
        children: [
          // Active Canvas Painter
          Positioned.fill(
            child: _buildActiveCanvas(controller),
          ),
          // Problem Description Badge (Top Right)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white24, width: 1),
              ),
              child: Text(
                _getProblemTag(controller),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getProblemTag(SimulationController controller) {
    if (controller.selectedAlgorithm == AlgorithmType.aco) {
      return controller.selectedAcoMode == AcoProblemMode.tsp
          ? 'TSP • 8 Cities Circuit'
          : 'Grid Pathfinding • Tap to toggle obstacles';
    } else {
      return '${controller.selectedBenchmark.name} • Min: ${controller.selectedBenchmark.globalOptimumVal}';
    }
  }

  Widget _buildActiveCanvas(SimulationController controller) {
    switch (controller.selectedAlgorithm) {
      case AlgorithmType.aco:
        if (controller.selectedAcoMode == AcoProblemMode.tsp) {
          final solver = controller.acoTspSolver;
          return TspCanvas(
            cities: solver?.cities ?? [],
            globalBestRoute: solver?.globalBestRoute,
            iterationBestRoute: solver?.iterationBestRoute,
            currentAntRoutes: solver?.currentAntRoutes ?? [],
            pheromoneMatrix: solver?.pheromoneMatrix,
          );
        } else {
          final env = controller.gridEnvironment;
          final solver = controller.acoGridSolver;
          if (env == null) return const SizedBox.shrink();
          return GridCanvas(
            environment: env,
            solver: solver,
            onCellTapped: (x, y) {
              setState(() {
                env.toggleObstacle(x, y);
              });
            },
          );
        }

      case AlgorithmType.pso:
        final solver = controller.psoSolver;
        return PsoLandscapeCanvas(
          benchmark: controller.selectedBenchmark,
          particles: solver?.particles ?? [],
          globalBestPosition: solver?.globalBestPosition ?? [0.0, 0.0],
          globalBestFitness: solver?.globalBestFitness ?? double.infinity,
          minBound: solver?.minBound ?? -5.12,
          maxBound: solver?.maxBound ?? 5.12,
        );

      case AlgorithmType.abc:
        final solver = controller.abcSolver;
        return AbcLandscapeCanvas(
          benchmark: controller.selectedBenchmark,
          foodSources: solver?.foodSources ?? [],
          bestFoodSource: solver?.bestFoodSource,
          abandonmentLimit: solver?.abandonmentLimit ?? 40,
          recentScoutReplacements: solver?.iterationScoutReplacements ?? 0,
          minBound: solver?.minBound ?? -5.12,
          maxBound: solver?.maxBound ?? 5.12,
        );
    }
  }

  Widget _buildLiveMetricsCards(SimulationController controller, bool isDark) {
    String extraLabel = 'Swarm Dispersion';
    String extraVal = '0.00';
    IconData extraIcon = Icons.scatter_plot_rounded;

    if (controller.selectedAlgorithm == AlgorithmType.aco) {
      if (controller.selectedAcoMode == AcoProblemMode.tsp) {
        extraLabel = 'Max Pheromone';
        extraVal = controller.acoTspSolver != null
            ? Formatters.formatFitness(controller.acoTspSolver!.pheromoneMatrix.getMaxPheromone(), decimals: 2)
            : '1.0';
        extraIcon = Icons.bubble_chart_rounded;
      } else {
        extraLabel = 'Goal Reached';
        extraVal = '${controller.acoGridSolver?.history.lastOrNull?.extraMetric.toInt() ?? 0} ants';
        extraIcon = Icons.flag_rounded;
      }
    } else if (controller.selectedAlgorithm == AlgorithmType.pso) {
      extraLabel = 'Swarm Dispersion';
      extraVal = controller.psoSolver != null
          ? Formatters.formatFitness(controller.psoSolver!.calculateSwarmDispersion(), decimals: 3)
          : '0.00';
      extraIcon = Icons.blur_on_rounded;
    } else if (controller.selectedAlgorithm == AlgorithmType.abc) {
      extraLabel = 'Scout Replaced';
      extraVal = '${controller.abcSolver?.totalScoutReplacements ?? 0} sources';
      extraIcon = Icons.sync_problem_rounded;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 550;
        return GridView.count(
          crossAxisCount: isWide ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: isWide ? 2.3 : 1.9,
          children: [
            MetricBadge(
              label: 'Best Objective',
              value: controller.currentBestObjective != null
                  ? (controller.selectedAlgorithm == AlgorithmType.aco && controller.selectedAcoMode == AcoProblemMode.tsp
                      ? Formatters.formatDistance(controller.currentBestObjective!)
                      : Formatters.formatFitness(controller.currentBestObjective!))
                  : '—',
              icon: Icons.emoji_events_rounded,
              color: AppColors.gold,
              subtitle: 'Minimization target',
            ),
            MetricBadge(
              label: 'Average Objective',
              value: controller.currentAverageObjective != null
                  ? (controller.selectedAlgorithm == AlgorithmType.aco && controller.selectedAcoMode == AcoProblemMode.tsp
                      ? Formatters.formatDistance(controller.currentAverageObjective!)
                      : Formatters.formatFitness(controller.currentAverageObjective!))
                  : '—',
              icon: Icons.stacked_line_chart_rounded,
              color: AppColors.blue,
              subtitle: 'Population mean',
            ),
            MetricBadge(
              label: 'Evaluations',
              value: '${controller.evaluationsCount}',
              icon: Icons.calculate_rounded,
              color: AppColors.green,
              subtitle: 'Objective queries',
            ),
            MetricBadge(
              label: extraLabel,
              value: extraVal,
              icon: extraIcon,
              color: AppColors.accentCyan,
              subtitle: 'Algorithm metric',
            ),
          ],
        );
      },
    );
  }

  Widget _buildParameterConfigurationCard(SimulationController controller, bool isDark) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Algorithm Hyperparameters',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              IconButton(
                tooltip: 'Reset Parameters to Default',
                icon: const Icon(Icons.restore_rounded, size: 18),
                onPressed: () => controller.initializeSolvers(),
              ),
            ],
          ),
          const Divider(height: 16),

          // Common Parameters
          ParameterSlider(
            label: 'Agent Count (Population)',
            symbol: 'N',
            description: 'Number of parallel search agents in the swarm',
            value: controller.agentCount.toDouble(),
            min: 5,
            max: 80,
            divisions: 15,
            formatValue: (v) => '${v.toInt()}',
            onChanged: (v) => controller.setAgentCount(v.toInt()),
          ),
          ParameterSlider(
            label: 'Maximum Iterations',
            symbol: 'T',
            description: 'Total computational generation budget before halting',
            value: controller.maxIterations.toDouble(),
            min: 10,
            max: 300,
            divisions: 29,
            formatValue: (v) => '${v.toInt()}',
            onChanged: (v) => controller.setMaxIterations(v.toInt()),
          ),

          // Algorithm-Specific Parameters
          if (controller.selectedAlgorithm == AlgorithmType.aco) ...[
            ParameterSlider(
              label: 'Pheromone Influence',
              symbol: 'alpha',
              description: 'Weight of accumulated chemical trails in selection',
              value: controller.acoAlpha,
              min: 0.1,
              max: 4.0,
              divisions: 39,
              onChanged: (v) => controller.setAcoParams(alpha: v),
            ),
            ParameterSlider(
              label: 'Heuristic Influence',
              symbol: 'beta',
              description: 'Weight of greedy distance desirability (1/d)',
              value: controller.acoBeta,
              min: 0.5,
              max: 5.0,
              divisions: 45,
              onChanged: (v) => controller.setAcoParams(beta: v),
            ),
            ParameterSlider(
              label: 'Evaporation Rate',
              symbol: 'rho',
              description: 'Rate of pheromone decay per iteration to prevent stagnation',
              value: controller.acoEvaporation,
              min: 0.02,
              max: 0.5,
              divisions: 24,
              onChanged: (v) => controller.setAcoParams(evaporation: v),
            ),
            ParameterSlider(
              label: 'Deposit Strength',
              symbol: 'Q',
              description: 'Quantity of pheromone deposited by completing ants',
              value: controller.acoDeposit,
              min: 10.0,
              max: 300.0,
              divisions: 29,
              formatValue: (v) => '${v.toInt()}',
              onChanged: (v) => controller.setAcoParams(deposit: v),
            ),
          ] else if (controller.selectedAlgorithm == AlgorithmType.pso) ...[
            ParameterSlider(
              label: 'Inertia Weight',
              symbol: 'w',
              description: 'Momentum coefficient governing previous velocity retention',
              value: controller.psoInertia,
              min: 0.1,
              max: 1.0,
              divisions: 18,
              onChanged: (v) => controller.setPsoParams(inertia: v),
            ),
            ParameterSlider(
              label: 'Cognitive Coefficient',
              symbol: 'c1',
              description: 'Pull weight toward particle\'s own personal best position',
              value: controller.psoCognitive,
              min: 0.2,
              max: 2.5,
              divisions: 23,
              onChanged: (v) => controller.setPsoParams(cognitive: v),
            ),
            ParameterSlider(
              label: 'Social Coefficient',
              symbol: 'c2',
              description: 'Pull weight toward swarm\'s global best discovered position',
              value: controller.psoSocial,
              min: 0.2,
              max: 2.5,
              divisions: 23,
              onChanged: (v) => controller.setPsoParams(social: v),
            ),
          ] else if (controller.selectedAlgorithm == AlgorithmType.abc) ...[
            ParameterSlider(
              label: 'Abandonment Limit',
              symbol: 'limit',
              description: 'Trial threshold before an unimproved source is abandoned to scouts',
              value: controller.abcAbandonmentLimit.toDouble(),
              min: 5,
              max: 100,
              divisions: 19,
              formatValue: (v) => '${v.toInt()}',
              onChanged: (v) => controller.setAbcParams(abandonmentLimit: v.toInt()),
            ),
          ],

          const SizedBox(height: 8),
          // Deterministic Seed Input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _seedInputController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Random Seed (Optional)',
                    hintText: controller.seed != null ? '${controller.seed}' : 'e.g., 42 (Reproducible)',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onSubmitted: (val) {
                    final s = int.tryParse(val.trim());
                    controller.setSeed(s);
                  },
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () {
                  final s = int.tryParse(_seedInputController.text.trim());
                  controller.setSeed(s);
                },
                child: const Text('Apply Seed'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
