import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatting_utils.dart';
import '../../models/problem_type.dart';
import '../../services/simulation_service.dart';
import '../../widgets/charts/fitness_progress_chart.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/simulator/function_plot_visualizer.dart';
import '../../widgets/simulator/knapsack_visualizer.dart';
import '../../widgets/simulator/scheduling_timetable_view.dart';
import '../../widgets/simulator/tsp_canvas_visualizer.dart';

class PresentationModeScreen extends StatefulWidget {
  const PresentationModeScreen({super.key});

  static void show(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PresentationModeScreen()),
    );
  }

  @override
  State<PresentationModeScreen> createState() => _PresentationModeScreenState();
}

class _PresentationModeScreenState extends State<PresentationModeScreen> {
  int _presenterStepIndex = 0;

  final List<String> _vivaStages = [
    'Stage 1: Problem Definition & Initial Population',
    'Stage 2: Fitness Function Evaluation',
    'Stage 3: Tournament Parent Selection',
    'Stage 4: Crossover Operator Breeding',
    'Stage 5: Bit-Flip / Swap Mutation',
    'Stage 6: Elitism & Replacement',
    'Stage 7: Multi-Generation Convergence to Optimum',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        title: Row(
          children: const [
            Icon(Icons.present_to_all_rounded, color: AppColors.gold, size: 24),
            SizedBox(width: 8),
            Text(
              'COLLEGE PROJECT VIVA / PRESENTATION MODE',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Consumer<SimulationService>(
        builder: (context, simService, child) {
          final currentGen = simService.currentGen;
          final bestInd = currentGen?.bestIndividual;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Presentation Banner Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.gold, width: 1.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'GENETIC OPTIMIZATION LAB',
                              style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Active Domain: ${simService.selectedProblemType.displayName}',
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.green),
                          ),
                          child: Text(
                            _vivaStages[_presenterStepIndex],
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Middle Main Display
                  Expanded(
                    child: Row(
                      children: [
                        // Left Visualizer Column
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.darkSurface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.darkSurfaceBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'REAL-TIME PROBLEM SOLUTION STATE',
                                  style: TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(height: 10),
                                Expanded(child: _buildProblemVisualizer(simService)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Right Metrics & Chart Column
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              // Stat Cards
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildPresenterStatCard(
                                      'Gen #',
                                      '${currentGen?.generationNumber ?? 0}',
                                      AppColors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildPresenterStatCard(
                                      'Best Fitness',
                                      FormattingUtils.formatFitness(bestInd?.fitness ?? 0),
                                      AppColors.gold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Chart
                              Expanded(
                                child: FitnessProgressChart<int>(
                                  history: simService.engine.generationHistory,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Bottom Presenter Controller Bar
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.darkSurfaceBorder),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          label: 'Reset Simulation',
                          icon: Icons.refresh_rounded,
                          isOutlined: true,
                          color: AppColors.accentRed,
                          onPressed: () {
                            setState(() => _presenterStepIndex = 0);
                            simService.resetSimulation();
                          },
                        ),
                        Row(
                          children: [
                            CustomButton(
                              label: 'STEP GENERATION',
                              icon: Icons.skip_next_rounded,
                              isOutlined: true,
                              color: AppColors.blue,
                              onPressed: () {
                                simService.stepSimulation();
                                setState(() {
                                  _presenterStepIndex = (_presenterStepIndex + 1) % _vivaStages.length;
                                });
                              },
                            ),
                            const SizedBox(width: 12),
                            CustomButton(
                              label: simService.isRunning ? 'PAUSE EVOLUTION' : 'RUN CONTINUOUS EVOLUTION',
                              icon: simService.isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              isPrimary: true,
                              color: simService.isRunning ? AppColors.gold : AppColors.green,
                              onPressed: () {
                                if (simService.isRunning) {
                                  simService.pauseSimulation();
                                } else {
                                  simService.startSimulation();
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPresenterStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
    );
  }

  Widget _buildProblemVisualizer(SimulationService simService) {
    final bestInd = simService.currentGen?.bestIndividual;
    if (bestInd == null) return const SizedBox.shrink();

    switch (simService.selectedProblemType) {
      case ProblemType.functionOptimization:
        return FunctionPlotVisualizer(population: simService.currentGen?.population ?? []);
      case ProblemType.knapsack:
        return KnapsackVisualizer(itemBits: bestInd.chromosome.rawValues);
      case ProblemType.tsp:
        return TSPCanvasVisualizer(cityOrder: bestInd.chromosome.rawValues);
      case ProblemType.scheduling:
        return SchedulingTimetableView(slotAssignments: bestInd.chromosome.rawValues);
    }
  }
}
