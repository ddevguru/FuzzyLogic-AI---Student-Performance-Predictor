import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/individual.dart';
import '../../models/problem_type.dart';
import '../../services/simulation_service.dart';
import '../../widgets/charts/fitness_progress_chart.dart';
import '../../widgets/charts/population_distribution_chart.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/simulator/best_solution_card.dart';
import '../../widgets/simulator/chromosome_visualizer.dart';
import '../../widgets/simulator/function_plot_visualizer.dart';
import '../../widgets/simulator/knapsack_visualizer.dart';
import '../../widgets/simulator/parameter_controls.dart';
import '../../widgets/simulator/population_grid.dart';
import '../../widgets/simulator/problem_selector.dart';
import '../../widgets/simulator/scheduling_timetable_view.dart';
import '../../widgets/simulator/tsp_canvas_visualizer.dart';
import 'experiment_mode_sheet.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  Individual<int>? _selectedIndividualForInspection;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<SimulationService>(
      builder: (context, simService, child) {
        final currentGen = simService.currentGen;
        final history = simService.engine.generationHistory;
        final initialBest = history.isNotEmpty ? history.first.bestIndividual : null;
        final currentBest = currentGen?.bestIndividual;
        final inspectTarget = _selectedIndividualForInspection ?? currentBest;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Screen Header
              const SectionHeader(
                title: 'Genetic Algorithm Simulator',
                subtitle: 'Configure parameters and observe evolutionary optimization in real time.',
                icon: Icons.memory_rounded,
                infoTopicKey: 'Generation',
              ),

              const SizedBox(height: 12),

              // Problem Selector
              ProblemSelector(
                selectedProblem: simService.selectedProblemType,
                onProblemSelected: (probType) {
                  setState(() => _selectedIndividualForInspection = null);
                  simService.selectProblem(probType);
                },
              ),

              const SizedBox(height: 16),

              // Simulation Control Bar & Speed Selector
              _buildControlPanel(context, simService, isDark),

              const SizedBox(height: 16),

              // Hyperparameter Expansion Panel
              ParameterControls(
                config: simService.config,
                onChanged: (newConfig) {
                  setState(() => _selectedIndividualForInspection = null);
                  simService.updateConfig(newConfig);
                },
              ),

              const SizedBox(height: 16),

              // Active Problem Domain Visualizer
              _buildActiveProblemVisualizer(simService),

              const SizedBox(height: 16),

              // Best Solution Card
              BestSolutionCard<int>(
                bestIndividual: currentBest,
                initialBestIndividual: initialBest,
                currentGenerationNumber: simService.engine.currentGenNumber,
              ),

              const SizedBox(height: 16),

              // Live Population Grid
              if (currentGen != null) ...[
                PopulationGrid<int>(
                  population: currentGen.population,
                  onIndividualTap: (ind) {
                    setState(() => _selectedIndividualForInspection = ind);
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Chromosome Inspector
              if (inspectTarget != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'INSPECTING INDIVIDUAL #${inspectTarget.rank} (Fitness: ${inspectTarget.fitness.toStringAsFixed(2)})',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          if (_selectedIndividualForInspection != null)
                            TextButton(
                              onPressed: () => setState(() => _selectedIndividualForInspection = null),
                              child: const Text('RESET TO BEST', style: TextStyle(fontSize: 10)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ChromosomeVisualizer<int>(
                        chromosome: inspectTarget.chromosome,
                        title: 'Chromosome Bit / Gene Structure',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Live Charts: Fitness vs Generation & Population Distribution
              FitnessProgressChart<int>(history: history),

              const SizedBox(height: 16),

              if (currentGen != null) ...[
                PopulationDistributionChart<int>(population: currentGen.population),
                const SizedBox(height: 16),
              ],

              // Advanced Experiment Mode Button
              CustomButton(
                label: 'OPEN EXPERIMENT BENCHMARK MODE',
                icon: Icons.science_rounded,
                isOutlined: true,
                color: AppColors.gold,
                width: double.infinity,
                onPressed: () => ExperimentModeSheet.show(context),
              ),

              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildControlPanel(BuildContext context, SimulationService simService, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATUS: ${simService.state.name.toUpperCase()}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: simService.isRunning
                      ? AppColors.green
                      : (simService.isPaused ? AppColors.gold : AppColors.blue),
                  letterSpacing: 1.0,
                ),
              ),
              Row(
                children: [
                  const Text('Speed: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  DropdownButton<int>(
                    value: simService.speedMs,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 800, child: Text('Slow (800ms)')),
                      DropdownMenuItem(value: 350, child: Text('Normal (350ms)')),
                      DropdownMenuItem(value: 80, child: Text('Fast (80ms)')),
                    ],
                    onChanged: (val) {
                      if (val != null) simService.setSpeed(val);
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (!simService.isRunning)
                CustomButton(
                  label: simService.isPaused ? 'Resume' : 'Start',
                  icon: Icons.play_arrow_rounded,
                  isPrimary: true,
                  color: AppColors.green,
                  onPressed: () {
                    if (simService.isPaused) {
                      simService.resumeSimulation();
                    } else {
                      simService.startSimulation();
                    }
                  },
                )
              else
                CustomButton(
                  label: 'Pause',
                  icon: Icons.pause_rounded,
                  isPrimary: true,
                  color: AppColors.gold,
                  onPressed: () => simService.pauseSimulation(),
                ),
              CustomButton(
                label: 'Step',
                icon: Icons.skip_next_rounded,
                isOutlined: true,
                color: AppColors.blue,
                onPressed: simService.isRunning ? null : () => simService.stepSimulation(),
              ),
              CustomButton(
                label: 'Reset',
                icon: Icons.refresh_rounded,
                isOutlined: true,
                color: AppColors.accentRed,
                onPressed: () {
                  setState(() => _selectedIndividualForInspection = null);
                  simService.resetSimulation();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveProblemVisualizer(SimulationService simService) {
    final bestInd = simService.currentGen?.bestIndividual;
    if (bestInd == null) return const SizedBox.shrink();

    switch (simService.selectedProblemType) {
      case ProblemType.functionOptimization:
        return FunctionPlotVisualizer(population: simService.currentGen?.population ?? []);
      case ProblemType.knapsack:
        return KnapsackVisualizer(
          itemBits: bestInd.chromosome.rawValues,
          maxCapacity: 10.0,
        );
      case ProblemType.tsp:
        return TSPCanvasVisualizer(cityOrder: bestInd.chromosome.rawValues);
      case ProblemType.scheduling:
        return SchedulingTimetableView(slotAssignments: bestInd.chromosome.rawValues);
    }
  }
}
