import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../algorithms/abc/abc_solver.dart';
import '../algorithms/aco/aco_grid_solver.dart';
import '../algorithms/aco/aco_tsp_solver.dart';
import '../algorithms/pso/pso_solver.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/algorithm_type.dart';
import '../models/benchmark_function.dart';
import '../models/simulation_metric_point.dart';
import '../problems/grid_environment.dart';
import '../problems/tsp_cities.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/common/metric_badge.dart';
import '../widgets/simulation/convergence_chart.dart';
import '../widgets/simulation/parameter_slider.dart';

class ExperimentScreen extends StatefulWidget {
  const ExperimentScreen({super.key});

  @override
  State<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen> {
  AlgorithmType _algorithm = AlgorithmType.pso;
  AcoProblemMode _acoMode = AcoProblemMode.tsp;
  BenchmarkType _benchmark = BenchmarkType.sphere;

  int _iterations = 100;
  int _agentCount = 30;
  int? _seed = 42;

  // ACO Parameters
  double _acoAlpha = 1.0;
  double _acoBeta = 2.5;
  double _acoEvap = 0.1;
  final double _acoDeposit = 100.0;

  // PSO Parameters
  double _psoInertia = 0.729;
  double _psoCognitive = 1.494;
  double _psoSocial = 1.494;

  // ABC Parameters
  int _abcAbandonmentLimit = 40;

  // Experiment Execution Results
  bool _isRunning = false;
  int _completedIterations = 0;
  int _totalEvaluations = 0;
  int _elapsedMs = 0;
  double? _initialBestObjective;
  double? _finalBestObjective;
  String _bestSolutionString = 'None';
  List<SimulationMetricPoint> _history = [];

  void _runExperiment() {
    setState(() {
      _isRunning = true;
      _completedIterations = 0;
      _totalEvaluations = 0;
      _history = [];
      _initialBestObjective = null;
      _finalBestObjective = null;
      _bestSolutionString = 'Running...';
    });

    Future.microtask(() {
      final watch = Stopwatch()..start();

      if (_algorithm == AlgorithmType.aco) {
        if (_acoMode == AcoProblemMode.tsp) {
          final solver = AcoTspSolver(
            cities: TspCitiesData.defaultCities,
            antCount: _agentCount,
            alpha: _acoAlpha,
            beta: _acoBeta,
            evaporationRate: _acoEvap,
            depositStrength: _acoDeposit,
            seed: _seed,
          );

          for (int i = 0; i < _iterations; i++) {
            final pt = solver.stepIteration();
            if (i == 0) _initialBestObjective = pt.bestObjective;
          }
          watch.stop();

          setState(() {
            _isRunning = false;
            _completedIterations = _iterations;
            _totalEvaluations = _iterations * _agentCount;
            _elapsedMs = watch.elapsedMilliseconds;
            _finalBestObjective = solver.globalBestRoute?.totalDistance;
            _initialBestObjective ??= _finalBestObjective;
            _bestSolutionString = solver.globalBestRoute != null
                ? solver.globalBestRoute!.cityIndices.map((idx) => solver.cities[idx].name).join(' → ')
                : 'None';
            _history = List.from(solver.history);
          });
        } else {
          final env = GridEnvironment();
          final solver = AcoGridSolver(
            environment: env,
            antCount: _agentCount,
            alpha: _acoAlpha,
            beta: _acoBeta,
            evaporationRate: _acoEvap,
            depositStrength: _acoDeposit,
            seed: _seed,
          );

          for (int i = 0; i < _iterations; i++) {
            final pt = solver.stepIteration();
            if (i == 0) _initialBestObjective = pt.bestObjective;
          }
          watch.stop();

          setState(() {
            _isRunning = false;
            _completedIterations = _iterations;
            _totalEvaluations = _iterations * _agentCount;
            _elapsedMs = watch.elapsedMilliseconds;
            _finalBestObjective = solver.globalBestPath?.stepCount.toDouble();
            _initialBestObjective ??= _finalBestObjective;
            _bestSolutionString = solver.globalBestPath != null
                ? '${solver.globalBestPath!.stepCount} steps (${solver.globalBestPath!.reachedGoal ? "Goal Reached" : "Blocked"})'
                : 'Unreachable';
            _history = List.from(solver.history);
          });
        }
      } else if (_algorithm == AlgorithmType.pso) {
        final solver = PsoSolver(
          benchmark: _benchmark,
          particleCount: _agentCount,
          inertiaWeight: _psoInertia,
          cognitiveWeight: _psoCognitive,
          socialWeight: _psoSocial,
          seed: _seed,
        );

        _initialBestObjective = solver.globalBestFitness;
        for (int i = 0; i < _iterations; i++) {
          solver.stepIteration();
        }
        watch.stop();

        setState(() {
          _isRunning = false;
          _completedIterations = _iterations;
          _totalEvaluations = _iterations * _agentCount;
          _elapsedMs = watch.elapsedMilliseconds;
          _finalBestObjective = solver.globalBestFitness;
          _bestSolutionString = '(${solver.globalBestPosition[0].toStringAsFixed(5)}, ${solver.globalBestPosition[1].toStringAsFixed(5)})';
          _history = List.from(solver.history);
        });
      } else {
        final solver = AbcSolver(
          benchmark: _benchmark,
          foodSourceCount: (_agentCount / 2).ceil(),
          onlookerBeeCount: (_agentCount / 2).ceil(),
          abandonmentLimit: _abcAbandonmentLimit,
          seed: _seed,
        );

        _initialBestObjective = solver.bestFoodSource?.objectiveValue;
        for (int i = 0; i < _iterations; i++) {
          solver.stepIteration();
        }
        watch.stop();

        setState(() {
          _isRunning = false;
          _completedIterations = _iterations;
          _totalEvaluations = _iterations * (solver.foodSources.length + solver.onlookerBeeCount);
          _elapsedMs = watch.elapsedMilliseconds;
          _finalBestObjective = solver.bestFoodSource?.objectiveValue;
          _bestSolutionString = solver.bestFoodSource != null
              ? '(${solver.bestFoodSource!.position[0].toStringAsFixed(5)}, ${solver.bestFoodSource!.position[1].toStringAsFixed(5)})'
              : 'None';
          _history = List.from(solver.history);
        });
      }
    });
  }

  void _reset() {
    setState(() {
      _isRunning = false;
      _completedIterations = 0;
      _totalEvaluations = 0;
      _elapsedMs = 0;
      _initialBestObjective = null;
      _finalBestObjective = null;
      _bestSolutionString = 'None';
      _history.clear();
    });
  }

  double _calculateImprovement() {
    if (_initialBestObjective == null || _finalBestObjective == null) return 0.0;
    if (_initialBestObjective == 0.0) return 0.0;
    final diff = _initialBestObjective! - _finalBestObjective!;
    if (diff <= 0) return 0.0;
    return (diff / _initialBestObjective!.abs()).clamp(0.0, 1.0);
  }

  void _exportResults() {
    final exportData = {
      'algorithm': _algorithm.fullName,
      'problem': _algorithm == AlgorithmType.aco ? _acoMode.title : _benchmark.name,
      'iterations': _completedIterations,
      'agentCount': _agentCount,
      'seed': _seed,
      'executionDurationMs': _elapsedMs,
      'evaluations': _totalEvaluations,
      'initialBest': _initialBestObjective,
      'finalBest': _finalBestObjective,
      'improvementPercent': '${(_calculateImprovement() * 100).toStringAsFixed(2)}%',
      'solution': _bestSolutionString,
      'telemetry': _history.map((h) => h.toMap()).toList(),
    };

    final jsonStr = const JsonEncoder.withIndent('  ').convert(exportData);
    Clipboard.setData(ClipboardData(text: jsonStr));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Experiment results & JSON telemetry copied to clipboard!'),
        backgroundColor: AppColors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Experiment Mode'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.science_rounded, color: AppColors.gold, size: 36),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Controlled Optimization Laboratory',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Configure deterministic parameters, execute benchmark runs, calculate improvement deltas, and export research telemetry.',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Experiment Setup Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('1. Experiment Configuration', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const Divider(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Algorithm Dropdown
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Algorithm: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          DropdownButton<AlgorithmType>(
                            value: _algorithm,
                            items: AlgorithmType.values.map((a) => DropdownMenuItem(value: a, child: Text(a.shortName))).toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _algorithm = v);
                            },
                          ),
                        ],
                      ),
                      // Problem Dropdown (Strictly compatible problems)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Problem: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          if (_algorithm == AlgorithmType.aco)
                            DropdownButton<AcoProblemMode>(
                              value: _acoMode,
                              items: AcoProblemMode.values.map((m) => DropdownMenuItem(value: m, child: Text(m.title))).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _acoMode = v);
                              },
                            )
                          else
                            DropdownButton<BenchmarkType>(
                              value: _benchmark,
                              items: BenchmarkType.values.map((b) => DropdownMenuItem(value: b, child: Text(b.name))).toList(),
                              onChanged: (v) {
                                if (v != null) setState(() => _benchmark = v);
                              },
                            ),
                        ],
                      ),
                      // Reproducible Seed
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Seed: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          DropdownButton<int?>(
                            value: _seed,
                            items: const [
                              DropdownMenuItem(value: null, child: Text('Random')),
                              DropdownMenuItem(value: 42, child: Text('42 (Standard)')),
                              DropdownMenuItem(value: 100, child: Text('100 (Seed B)')),
                              DropdownMenuItem(value: 999, child: Text('999 (Seed C)')),
                            ],
                            onChanged: (v) => setState(() => _seed = v),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Common Sliders
                  ParameterSlider(
                    label: 'Evaluation Iterations',
                    symbol: 'T',
                    description: 'Number of computational generations to execute',
                    value: _iterations.toDouble(),
                    min: 10,
                    max: 500,
                    divisions: 49,
                    formatValue: (v) => '${v.toInt()}',
                    onChanged: (v) => setState(() => _iterations = v.toInt()),
                  ),
                  ParameterSlider(
                    label: 'Agent Count (Swarm Size)',
                    symbol: 'N',
                    description: 'Population size for search space exploration',
                    value: _agentCount.toDouble(),
                    min: 10,
                    max: 80,
                    divisions: 14,
                    formatValue: (v) => '${v.toInt()}',
                    onChanged: (v) => setState(() => _agentCount = v.toInt()),
                  ),

                  // Algorithm-Specific Parameters
                  if (_algorithm == AlgorithmType.aco) ...[
                    ParameterSlider(
                      label: 'Alpha (Pheromone Weight)',
                      symbol: 'alpha',
                      description: 'Attraction toward existing pheromone trails',
                      value: _acoAlpha,
                      min: 0.1,
                      max: 4.0,
                      divisions: 39,
                      onChanged: (v) => setState(() => _acoAlpha = v),
                    ),
                    ParameterSlider(
                      label: 'Beta (Heuristic Weight)',
                      symbol: 'beta',
                      description: 'Attraction toward greedy distance heuristic (1/d)',
                      value: _acoBeta,
                      min: 0.5,
                      max: 5.0,
                      divisions: 45,
                      onChanged: (v) => setState(() => _acoBeta = v),
                    ),
                    ParameterSlider(
                      label: 'Evaporation Rate',
                      symbol: 'rho',
                      description: 'Pheromone trail decay fraction per iteration',
                      value: _acoEvap,
                      min: 0.05,
                      max: 0.5,
                      divisions: 9,
                      onChanged: (v) => setState(() => _acoEvap = v),
                    ),
                  ] else if (_algorithm == AlgorithmType.pso) ...[
                    ParameterSlider(
                      label: 'Inertia Weight',
                      symbol: 'w',
                      description: 'Momentum damping coefficient',
                      value: _psoInertia,
                      min: 0.2,
                      max: 1.0,
                      divisions: 16,
                      onChanged: (v) => setState(() => _psoInertia = v),
                    ),
                    ParameterSlider(
                      label: 'Cognitive Coefficient',
                      symbol: 'c1',
                      description: 'Personal memory attraction weight',
                      value: _psoCognitive,
                      min: 0.5,
                      max: 2.5,
                      divisions: 20,
                      onChanged: (v) => setState(() => _psoCognitive = v),
                    ),
                    ParameterSlider(
                      label: 'Social Coefficient',
                      symbol: 'c2',
                      description: 'Global swarm attraction weight',
                      value: _psoSocial,
                      min: 0.5,
                      max: 2.5,
                      divisions: 20,
                      onChanged: (v) => setState(() => _psoSocial = v),
                    ),
                  ] else if (_algorithm == AlgorithmType.abc) ...[
                    ParameterSlider(
                      label: 'Abandonment Limit',
                      symbol: 'limit',
                      description: 'Trial exhaustion threshold before scout replacement',
                      value: _abcAbandonmentLimit.toDouble(),
                      min: 10,
                      max: 100,
                      divisions: 18,
                      formatValue: (v) => '${v.toInt()}',
                      onChanged: (v) => setState(() => _abcAbandonmentLimit = v.toInt()),
                    ),
                  ],

                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isRunning ? null : _runExperiment,
                        icon: const Icon(Icons.play_circle_filled_rounded),
                        label: Text(_isRunning ? 'Executing Trial...' : 'Run Experiment'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Reset'),
                      ),
                      if (_history.isNotEmpty)
                        ElevatedButton.icon(
                          onPressed: _exportResults,
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('Export Results Locally'),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Results Section
            if (_completedIterations > 0) ...[
              const Text('2. Experiment Telemetry & Results', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 650;
                  return GridView.count(
                    crossAxisCount: isWide ? 4 : 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: isWide ? 2.2 : 1.7,
                    children: [
                      MetricBadge(
                        label: 'Initial Best Objective',
                        value: _initialBestObjective != null ? Formatters.formatFitness(_initialBestObjective!) : '—',
                        icon: Icons.start_rounded,
                        color: AppColors.blue,
                      ),
                      MetricBadge(
                        label: 'Final Best Objective',
                        value: _finalBestObjective != null ? Formatters.formatFitness(_finalBestObjective!) : '—',
                        icon: Icons.emoji_events_rounded,
                        color: AppColors.gold,
                      ),
                      MetricBadge(
                        label: 'Improvement Delta',
                        value: Formatters.formatPercent(_calculateImprovement()),
                        icon: Icons.trending_up_rounded,
                        color: AppColors.green,
                        subtitle: 'Relative gain',
                      ),
                      MetricBadge(
                        label: 'Execution Time',
                        value: Formatters.formatDuration(_elapsedMs),
                        icon: Icons.timer_rounded,
                        color: AppColors.accentCyan,
                        subtitle: '$_totalEvaluations evaluations',
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),

              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Discovered Optimal Solution Vector', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F1B2E) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _bestSolutionString,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.accentCyan : AppColors.primaryNavy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ConvergenceChart(
                title: 'Experiment Convergence Graph',
                history: _history,
                primaryLineColor: _algorithm.accentColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
