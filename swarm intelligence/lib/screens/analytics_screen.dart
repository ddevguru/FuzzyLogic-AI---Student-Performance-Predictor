import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/algorithm_type.dart';
import '../services/simulation_controller.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/common/metric_badge.dart';
import '../widgets/simulation/convergence_chart.dart';

class AnalyticsScreen extends StatefulWidget {
  final SimulationController controller;

  const AnalyticsScreen({super.key, required this.controller});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  bool _showRawData = false;

  void _copyToClipboard(String data) {
    Clipboard.setData(ClipboardData(text: data));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Simulation convergence telemetry copied to clipboard!'),
        backgroundColor: AppColors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final controller = widget.controller;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final history = controller.currentHistory;
        final hasData = history.isNotEmpty;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Banner
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.analytics_rounded, color: AppColors.gold, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Real-Time Swarm Analytics Engine',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Active Algorithm: ${controller.selectedAlgorithm.fullName}',
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    if (hasData)
                      ElevatedButton.icon(
                        onPressed: () {
                          final jsonStr = const JsonEncoder.withIndent('  ').convert(
                            history.map((h) => h.toMap()).toList(),
                          );
                          _copyToClipboard(jsonStr);
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Export JSON'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.primaryNavy,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // KPI Metrics Grid
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 650;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: isWide ? 2.2 : 1.7,
                    children: [
                      MetricBadge(
                        label: 'Iterations Executed',
                        value: '${controller.currentIteration} / ${controller.maxIterations}',
                        icon: Icons.sync_rounded,
                        color: AppColors.blue,
                        subtitle: 'Progress: ${Formatters.formatPercent(controller.maxIterations > 0 ? (controller.currentIteration / controller.maxIterations).clamp(0.0, 1.0) : 0)}',
                      ),
                      MetricBadge(
                        label: 'Best Objective Value',
                        value: controller.currentBestObjective != null
                            ? Formatters.formatFitness(controller.currentBestObjective!)
                            : '—',
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.gold,
                        subtitle: 'Minimization target',
                      ),
                      MetricBadge(
                        label: 'Average Population Fitness',
                        value: controller.currentAverageObjective != null
                            ? Formatters.formatFitness(controller.currentAverageObjective!)
                            : '—',
                        icon: Icons.stacked_line_chart_rounded,
                        color: AppColors.green,
                        subtitle: 'Swarm consensus',
                      ),
                      MetricBadge(
                        label: 'Execution Duration',
                        value: Formatters.formatDuration(controller.elapsedMs),
                        icon: Icons.timer_rounded,
                        color: AppColors.accentCyan,
                        subtitle: '${controller.evaluationsCount} queries executed',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),

              // Convergence Chart
              ConvergenceChart(
                title: '${controller.selectedAlgorithm.shortName} Convergence Trajectory (Fitness vs Iteration)',
                history: history,
                primaryLineColor: controller.selectedAlgorithm.accentColor,
              ),
              const SizedBox(height: 20),

              // Algorithm-Specific Analytics Breakdown
              _buildAlgorithmSpecificAnalytics(controller, isDark),
              const SizedBox(height: 20),

              // Raw Data Telemetry Toggle
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Telemetry Log & Telemetry Table', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        TextButton.icon(
                          onPressed: () => setState(() => _showRawData = !_showRawData),
                          icon: Icon(_showRawData ? Icons.expand_less : Icons.expand_more),
                          label: Text(_showRawData ? 'Hide Records' : 'View Iteration Records'),
                        ),
                      ],
                    ),
                    if (_showRawData) ...[
                      const Divider(height: 16),
                      if (!hasData)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(child: Text('No telemetry available. Run a simulation to populate records.')),
                        )
                      else
                        SizedBox(
                          height: 260,
                          child: ListView.separated(
                            itemCount: history.length,
                            separatorBuilder: (_, index) => const Divider(height: 1),
                            itemBuilder: (context, i) {
                              final p = history[i];
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Iter ${p.iteration}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    Text('Best: ${Formatters.formatFitness(p.bestObjective)}', style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600)),
                                    Text('Avg: ${Formatters.formatFitness(p.averageObjective)}', style: const TextStyle(fontSize: 12, color: AppColors.blue)),
                                    Text('Aux: ${p.extraMetric.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAlgorithmSpecificAnalytics(SimulationController controller, bool isDark) {
    if (controller.selectedAlgorithm == AlgorithmType.aco) {
      final solver = controller.acoTspSolver;
      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.alt_route_rounded, color: AppColors.gold, size: 20),
                SizedBox(width: 8),
                Text('ACO Route & Pheromone Analytics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const Divider(height: 16),
            Text(
              'Global Best Tour: ${solver?.globalBestRoute != null ? solver!.globalBestRoute!.cityIndices.map((i) => solver.cities[i].name).join(' → ') : 'None yet'}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Max Pheromone Peak: ${solver != null ? solver.pheromoneMatrix.getMaxPheromone().toStringAsFixed(3) : '1.0'}',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight),
            ),
            const SizedBox(height: 4),
            Text(
              'Evaporation Rate: ${controller.acoEvaporation} | Q Constant: ${controller.acoDeposit}',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight),
            ),
          ],
        ),
      );
    } else if (controller.selectedAlgorithm == AlgorithmType.pso) {
      final solver = controller.psoSolver;
      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.grain_rounded, color: AppColors.blue, size: 20),
                SizedBox(width: 8),
                Text('PSO Swarm Topology & Convergence Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const Divider(height: 16),
            Text(
              'Global Best Coordinate: (${solver != null ? solver.globalBestPosition[0].toStringAsFixed(5) : '0.0'}, ${solver != null ? solver.globalBestPosition[1].toStringAsFixed(5) : '0.0'})',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Swarm Spatial Dispersion (Radius): ${solver != null ? solver.calculateSwarmDispersion().toStringAsFixed(4) : '0.0'}',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight),
            ),
            const SizedBox(height: 4),
            Text(
              'Inertia w: ${controller.psoInertia} | Cognitive c1: ${controller.psoCognitive} | Social c2: ${controller.psoSocial}',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight),
            ),
          ],
        ),
      );
    } else {
      final solver = controller.abcSolver;
      return CustomCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.hive_rounded, color: AppColors.green, size: 20),
                SizedBox(width: 8),
                Text('ABC Foraging Phases & Scout Replacements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ],
            ),
            const Divider(height: 16),
            Text(
              'Winning Food Source: ${solver?.bestFoodSource != null ? '(${solver!.bestFoodSource!.position[0].toStringAsFixed(5)}, ${solver.bestFoodSource!.position[1].toStringAsFixed(5)})' : 'None yet'}',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              'Total Scout Bee Replacements: ${solver?.totalScoutReplacements ?? 0} exhausted nectar sources',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight),
            ),
            const SizedBox(height: 4),
            Text(
              'Abandonment Limit: ${controller.abcAbandonmentLimit} trials | Food Sources: ${solver?.foodSources.length ?? 0}',
              style: TextStyle(fontSize: 12, color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight),
            ),
          ],
        ),
      );
    }
  }
}
