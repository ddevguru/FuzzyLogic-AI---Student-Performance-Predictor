import 'dart:async';
import 'package:flutter/material.dart';
import '../algorithms/abc/abc_solver.dart';
import '../algorithms/aco/aco_tsp_solver.dart';
import '../algorithms/pso/pso_solver.dart';
import '../core/constants/app_colors.dart';
import '../data/presentation_steps_data.dart';
import '../models/algorithm_type.dart';
import '../models/benchmark_function.dart';
import '../models/presentation_step.dart';
import '../problems/tsp_cities.dart';
import '../widgets/common/custom_card.dart';
import '../widgets/simulation/abc_landscape_canvas.dart';
import '../widgets/simulation/pso_landscape_canvas.dart';
import '../widgets/simulation/tsp_canvas.dart';

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  AlgorithmType _selectedAlgorithm = AlgorithmType.pso;
  int _currentStepIndex = 0;
  bool _isAutoPlaying = false;
  Timer? _autoPlayTimer;

  // Active step simulation solvers
  AcoTspSolver? _acoSolver;
  PsoSolver? _psoSolver;
  AbcSolver? _abcSolver;

  @override
  void initState() {
    super.initState();
    _initializeSolvers();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  void _initializeSolvers() {
    _autoPlayTimer?.cancel();
    _isAutoPlaying = false;
    _currentStepIndex = 0;

    _acoSolver = AcoTspSolver(
      cities: TspCitiesData.defaultCities,
      antCount: 15,
      seed: 42,
    );
    _psoSolver = PsoSolver(
      benchmark: BenchmarkType.sphere,
      particleCount: 25,
      seed: 42,
    );
    _abcSolver = AbcSolver(
      benchmark: BenchmarkType.sphere,
      foodSourceCount: 15,
      onlookerBeeCount: 15,
      seed: 42,
    );
    setState(() {});
  }

  List<PresentationStep> get _currentSteps =>
      PresentationStepsData.stepsByAlgorithm[_selectedAlgorithm] ?? [];

  void _nextStep() {
    if (_currentStepIndex < _currentSteps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _executeStepStateChange();
      });
    } else {
      _stopAutoPlay();
    }
  }

  void _previousStep() {
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _executeStepStateChange();
      });
    }
  }

  void _toggleAutoPlay() {
    if (_isAutoPlaying) {
      _stopAutoPlay();
    } else {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    setState(() => _isAutoPlaying = true);
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentStepIndex < _currentSteps.length - 1) {
        _nextStep();
      } else {
        _stopAutoPlay();
      }
    });
  }

  void _stopAutoPlay() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
    setState(() => _isAutoPlaying = false);
  }

  void _executeStepStateChange() {
    // Progress the solver dynamically based on current step
    switch (_selectedAlgorithm) {
      case AlgorithmType.aco:
        if (_acoSolver != null && _currentStepIndex >= 2) {
          _acoSolver!.stepIteration();
        }
        break;
      case AlgorithmType.pso:
        if (_psoSolver != null && _currentStepIndex >= 2) {
          _psoSolver!.stepIteration();
        }
        break;
      case AlgorithmType.abc:
        if (_abcSolver != null && _currentStepIndex >= 2) {
          _abcSolver!.stepIteration();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final steps = _currentSteps;
    final currentStep = steps[_currentStepIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presentation Mode (College Viva Demonstration)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Algorithm Switcher
            CustomCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.co_present_rounded, color: AppColors.gold, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'Demo Algorithm: ',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : AppColors.mutedTextLight,
                        ),
                      ),
                    ],
                  ),
                  SegmentedButton<AlgorithmType>(
                    segments: AlgorithmType.values.map((algo) {
                      return ButtonSegment<AlgorithmType>(
                        value: algo,
                        label: Text(algo.shortName),
                        icon: Icon(algo.icon, size: 16),
                      );
                    }).toList(),
                    selected: {_selectedAlgorithm},
                    onSelectionChanged: (set) {
                      if (set.isNotEmpty) {
                        setState(() {
                          _selectedAlgorithm = set.first;
                          _initializeSolvers();
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Step Progress Timeline Indicator
            _buildStepTimeline(steps, isDark),
            const SizedBox(height: 16),

            // Visualizer Canvas for Current Step
            SizedBox(
              height: 380,
              child: _buildPresentationCanvas(isDark),
            ),
            const SizedBox(height: 16),

            // Playback Controls
            _buildPlaybackControls(steps, isDark),
            const SizedBox(height: 16),

            // Step Academic Explanation Card
            _buildStepExplanationCard(currentStep, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTimeline(List<PresentationStep> steps, bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(steps.length, (i) {
          final isPast = i < _currentStepIndex;
          final isCurrent = i == _currentStepIndex;
          final Color stepColor = isCurrent
              ? _selectedAlgorithm.accentColor
              : isPast
                  ? AppColors.green
                  : Colors.grey;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: InkWell(
              onTap: () {
                setState(() {
                  _currentStepIndex = i;
                  _executeStepStateChange();
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? stepColor.withValues(alpha: 0.2)
                      : (isDark ? const Color(0xFF14233C) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: stepColor, width: isCurrent ? 1.5 : 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: stepColor,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      steps[i].title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                        color: isCurrent ? (isDark ? Colors.white : AppColors.mainText) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPresentationCanvas(bool isDark) {
    switch (_selectedAlgorithm) {
      case AlgorithmType.aco:
        return TspCanvas(
          cities: _acoSolver?.cities ?? [],
          globalBestRoute: _currentStepIndex >= 3 ? _acoSolver?.globalBestRoute : null,
          iterationBestRoute: _currentStepIndex >= 2 ? _acoSolver?.iterationBestRoute : null,
          currentAntRoutes: _currentStepIndex >= 1 ? (_acoSolver?.currentAntRoutes ?? []) : [],
          pheromoneMatrix: _acoSolver?.pheromoneMatrix,
        );

      case AlgorithmType.pso:
        return PsoLandscapeCanvas(
          benchmark: BenchmarkType.sphere,
          particles: _psoSolver?.particles ?? [],
          globalBestPosition: _psoSolver?.globalBestPosition ?? [0.0, 0.0],
          globalBestFitness: _psoSolver?.globalBestFitness ?? double.infinity,
          minBound: _psoSolver?.minBound ?? -5.12,
          maxBound: _psoSolver?.maxBound ?? 5.12,
        );

      case AlgorithmType.abc:
        return AbcLandscapeCanvas(
          benchmark: BenchmarkType.sphere,
          foodSources: _abcSolver?.foodSources ?? [],
          bestFoodSource: _currentStepIndex >= 4 ? _abcSolver?.bestFoodSource : null,
          abandonmentLimit: _abcSolver?.abandonmentLimit ?? 40,
          recentScoutReplacements: _abcSolver?.iterationScoutReplacements ?? 0,
          minBound: _abcSolver?.minBound ?? -5.12,
          maxBound: _abcSolver?.maxBound ?? 5.12,
        );
    }
  }

  Widget _buildPlaybackControls(List<PresentationStep> steps, bool isDark) {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: _currentStepIndex > 0 ? _previousStep : null,
                icon: const Icon(Icons.arrow_back_rounded, size: 18),
                label: const Text('Previous Step'),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: _currentStepIndex < steps.length - 1 ? _nextStep : null,
                icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                label: const Text('Next Step'),
              ),
            ],
          ),
          Row(
            children: [
              IconButton.filledTonal(
                tooltip: _isAutoPlaying ? 'Pause Auto-Play' : 'Start Auto-Play Animation',
                onPressed: _toggleAutoPlay,
                icon: Icon(_isAutoPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded),
                color: AppColors.gold,
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                tooltip: 'Restart Demonstration',
                onPressed: _initializeSolvers,
                icon: const Icon(Icons.replay_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepExplanationCard(PresentationStep step, bool isDark) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _selectedAlgorithm.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Step ${step.stepNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _selectedAlgorithm.accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          const Divider(height: 20),

          // Conceptual Description
          Text(
            step.description,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Mathematical Formula Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F1B2E) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF1E2E47) : const Color(0xFFCBD5E1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Viva Mathematical Formula:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  step.mathematicalFormula,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? AppColors.accentCyan : AppColors.primaryNavy,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // What is happening inside the app
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.check_circle_rounded, color: AppColors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'What is Happening Live in this Simulation: ${step.whatIsHappeningInApp}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
