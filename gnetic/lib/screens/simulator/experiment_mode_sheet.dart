import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatting_utils.dart';
import '../../models/ga_config.dart';
import '../../models/problem_type.dart';
import '../../models/simulation_result.dart';
import '../../services/simulation_service.dart';
import '../../widgets/common/custom_button.dart';

class ExperimentModeSheet extends StatefulWidget {
  const ExperimentModeSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExperimentModeSheet(),
    );
  }

  @override
  State<ExperimentModeSheet> createState() => _ExperimentModeSheetState();
}

class _ExperimentModeSheetState extends State<ExperimentModeSheet> {
  ProblemType _selectedProblem = ProblemType.functionOptimization;
  int _popSize = 100;
  int _maxGen = 100;
  double _mutRate = 0.05;
  double _crossRate = 0.85;
  bool _elitism = true;
  SelectionMethod _selection = SelectionMethod.tournament;

  SimulationResult<int>? _result;
  bool _isExecuting = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.science_rounded, color: AppColors.gold, size: 24),
                    SizedBox(width: 8),
                    Text(
                      'GA EXPERIMENT MODE BENCHMARK',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Run an isolated synchronous benchmark test with customized hyperparameters.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Config Controls
            _buildDropdownProblem(isDark),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput('Population Size', _popSize, (val) => setState(() => _popSize = val), isDark),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildNumberInput('Max Generations', _maxGen, (val) => setState(() => _maxGen = val), isDark),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildSliderField('Mutation Rate', '${(_mutRate * 100).toStringAsFixed(1)}%', _mutRate, 0.0, 0.5, (val) => setState(() => _mutRate = val)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSliderField('Crossover Rate', '${(_crossRate * 100).toStringAsFixed(0)}%', _crossRate, 0.1, 1.0, (val) => setState(() => _crossRate = val)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Elitism', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Switch.adaptive(
                  value: _elitism,
                  activeColor: AppColors.gold,
                  onChanged: (val) => setState(() => _elitism = val),
                ),
              ],
            ),
            const SizedBox(height: 16),
            CustomButton(
              label: _isExecuting ? 'EXECUTING BENCHMARK...' : 'RUN EXPERIMENT BENCHMARK',
              icon: Icons.flash_on_rounded,
              isPrimary: true,
              color: AppColors.gold,
              width: double.infinity,
              onPressed: _isExecuting ? null : _runBenchmark,
            ),
            const SizedBox(height: 20),
            if (_result != null) _buildResultView(isDark),
          ],
        ),
      ),
    );
  }

  void _runBenchmark() {
    setState(() => _isExecuting = true);
    final config = GAConfig(
      populationSize: _popSize,
      maxGenerations: _maxGen,
      mutationRate: _mutRate,
      crossoverRate: _crossRate,
      elitism: _elitism,
      selectionMethod: _selection,
    );

    final service = Provider.of<SimulationService>(context, listen: false);
    final res = service.runFullExperiment(config, _selectedProblem);

    setState(() {
      _result = res;
      _isExecuting = false;
    });
  }

  Widget _buildDropdownProblem(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Target Problem Domain', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        DropdownButtonFormField<ProblemType>(
          value: _selectedProblem,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: ProblemType.values
              .map((p) => DropdownMenuItem(value: p, child: Text(p.displayName)))
              .toList(),
          onChanged: (val) => setState(() => _selectedProblem = val!),
        ),
      ],
    );
  }

  Widget _buildNumberInput(String label, int val, ValueChanged<int> onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        const SizedBox(height: 4),
        TextFormField(
          initialValue: val.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.darkSurface : AppColors.lightBackground,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onChanged: (str) {
            int? n = int.tryParse(str);
            if (n != null && n > 0) onChanged(n);
          },
        ),
      ],
    );
  }

  Widget _buildSliderField(String label, String display, double val, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            Text(display, style: const TextStyle(color: AppColors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
          ],
        ),
        Slider.adaptive(value: val, min: min, max: max, activeColor: AppColors.blue, onChanged: onChanged),
      ],
    );
  }

  Widget _buildResultView(bool isDark) {
    final res = _result!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('EXPERIMENT RESULT REPORT', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold, fontSize: 13)),
              Text('${res.executionTime.inMilliseconds} ms execution', style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 12),
          Text('Initial Fitness: ${FormattingUtils.formatFitness(res.initialFitness)}'),
          Text('Final Fitness:   ${FormattingUtils.formatFitness(res.finalFitness)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.green)),
          Text('Improvement:     ${FormattingUtils.formatImprovement(res.initialFitness, res.finalFitness)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold)),
          Text('Generations:     ${res.totalGenerationsExecuted}'),
          const SizedBox(height: 10),
          const Text('Decoded Best Solution:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text(res.finalBest.decodedSolution, style: const TextStyle(fontFamily: 'monospace', fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
