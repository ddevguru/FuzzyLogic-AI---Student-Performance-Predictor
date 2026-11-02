import 'dart:async';
import 'package:flutter/material.dart';
import '../algorithms/aco/aco_grid_solver.dart';
import '../algorithms/aco/aco_tsp_solver.dart';
import '../algorithms/pso/pso_solver.dart';
import '../algorithms/abc/abc_solver.dart';
import '../models/algorithm_type.dart';
import '../models/benchmark_function.dart';
import '../models/simulation_metric_point.dart';
import '../problems/grid_environment.dart';
import '../problems/tsp_cities.dart';

enum SimulationStatus { idle, running, paused, completed }

class SimulationController extends ChangeNotifier {
  AlgorithmType _selectedAlgorithm = AlgorithmType.pso;
  AcoProblemMode _selectedAcoMode = AcoProblemMode.tsp;
  BenchmarkType _selectedBenchmark = BenchmarkType.sphere;

  // General Parameters
  int _maxIterations = 100;
  int _agentCount = 30;
  int? _seed;
  int _stepDelayMs = 100;

  // Algorithm-Specific Parameters
  // ACO
  double _acoAlpha = 1.0;
  double _acoBeta = 2.5;
  double _acoEvaporation = 0.1;
  double _acoDeposit = 100.0;

  // PSO
  double _psoInertia = 0.729;
  double _psoCognitive = 1.494;
  double _psoSocial = 1.494;

  // ABC
  int _abcAbandonmentLimit = 40;

  // Active Solvers
  AcoTspSolver? _acoTspSolver;
  AcoGridSolver? _acoGridSolver;
  PsoSolver? _psoSolver;
  AbcSolver? _abcSolver;
  GridEnvironment? _gridEnvironment;

  // State
  SimulationStatus _status = SimulationStatus.idle;
  int _currentIteration = 0;
  int _evaluationsCount = 0;
  double? _initialBestObjective;
  double? _currentBestObjective;
  double? _currentAverageObjective;
  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // App-Wide Aggregate Analytics for Home Dashboard
  int _totalSimulationsCompleted = 0;
  int _totalIterationsExecuted = 0;
  double? _allTimeBestFitness;

  // Getters
  AlgorithmType get selectedAlgorithm => _selectedAlgorithm;
  AcoProblemMode get selectedAcoMode => _selectedAcoMode;
  BenchmarkType get selectedBenchmark => _selectedBenchmark;
  int get maxIterations => _maxIterations;
  int get agentCount => _agentCount;
  int? get seed => _seed;
  int get stepDelayMs => _stepDelayMs;
  SimulationStatus get status => _status;
  bool get isRunning => _status == SimulationStatus.running;
  bool get isPaused => _status == SimulationStatus.paused;
  bool get isIdle => _status == SimulationStatus.idle;
  bool get isCompleted => _status == SimulationStatus.completed;

  int get currentIteration => _currentIteration;
  int get evaluationsCount => _evaluationsCount;
  int get elapsedMs => _stopwatch.elapsedMilliseconds;
  double? get initialBestObjective => _initialBestObjective;
  double? get currentBestObjective => _currentBestObjective;
  double? get currentAverageObjective => _currentAverageObjective;

  // Solvers Exposure
  AcoTspSolver? get acoTspSolver => _acoTspSolver;
  AcoGridSolver? get acoGridSolver => _acoGridSolver;
  PsoSolver? get psoSolver => _psoSolver;
  AbcSolver? get abcSolver => _abcSolver;
  GridEnvironment? get gridEnvironment => _gridEnvironment;

  // Parameter getters
  double get acoAlpha => _acoAlpha;
  double get acoBeta => _acoBeta;
  double get acoEvaporation => _acoEvaporation;
  double get acoDeposit => _acoDeposit;
  double get psoInertia => _psoInertia;
  double get psoCognitive => _psoCognitive;
  double get psoSocial => _psoSocial;
  int get abcAbandonmentLimit => _abcAbandonmentLimit;

  // App-wide metrics
  int get totalSimulationsCompleted => _totalSimulationsCompleted;
  int get totalIterationsExecuted => _totalIterationsExecuted;
  double? get allTimeBestFitness => _allTimeBestFitness;

  List<SimulationMetricPoint> get currentHistory {
    switch (_selectedAlgorithm) {
      case AlgorithmType.aco:
        return _selectedAcoMode == AcoProblemMode.tsp
            ? (_acoTspSolver?.history ?? [])
            : (_acoGridSolver?.history ?? []);
      case AlgorithmType.pso:
        return _psoSolver?.history ?? [];
      case AlgorithmType.abc:
        return _abcSolver?.history ?? [];
    }
  }

  SimulationController() {
    _gridEnvironment = GridEnvironment();
    initializeSolvers();
  }

  void initializeSolvers() {
    _stopTimer();
    _stopwatch.reset();
    _currentIteration = 0;
    _evaluationsCount = 0;
    _initialBestObjective = null;
    _currentBestObjective = null;
    _currentAverageObjective = null;
    _status = SimulationStatus.idle;

    switch (_selectedAlgorithm) {
      case AlgorithmType.aco:
        if (_selectedAcoMode == AcoProblemMode.tsp) {
          _acoTspSolver = AcoTspSolver(
            cities: TspCitiesData.defaultCities,
            antCount: _agentCount,
            alpha: _acoAlpha,
            beta: _acoBeta,
            evaporationRate: _acoEvaporation,
            depositStrength: _acoDeposit,
            seed: _seed,
          );
        } else {
          _gridEnvironment ??= GridEnvironment();
          _acoGridSolver = AcoGridSolver(
            environment: _gridEnvironment!,
            antCount: _agentCount,
            alpha: _acoAlpha,
            beta: _acoBeta,
            evaporationRate: _acoEvaporation,
            depositStrength: _acoDeposit,
            seed: _seed,
          );
        }
        break;

      case AlgorithmType.pso:
        _psoSolver = PsoSolver(
          benchmark: _selectedBenchmark,
          particleCount: _agentCount,
          inertiaWeight: _psoInertia,
          cognitiveWeight: _psoCognitive,
          socialWeight: _psoSocial,
          seed: _seed,
        );
        _currentBestObjective = _psoSolver!.globalBestFitness;
        _initialBestObjective = _psoSolver!.globalBestFitness;
        break;

      case AlgorithmType.abc:
        _abcSolver = AbcSolver(
          benchmark: _selectedBenchmark,
          foodSourceCount: (_agentCount / 2).ceil(),
          onlookerBeeCount: (_agentCount / 2).ceil(),
          abandonmentLimit: _abcAbandonmentLimit,
          seed: _seed,
        );
        _currentBestObjective = _abcSolver!.bestFoodSource?.objectiveValue;
        _initialBestObjective = _abcSolver!.bestFoodSource?.objectiveValue;
        break;
    }

    notifyListeners();
  }

  void setAlgorithm(AlgorithmType algo) {
    if (_selectedAlgorithm != algo) {
      _selectedAlgorithm = algo;
      initializeSolvers();
    }
  }

  void setAcoMode(AcoProblemMode mode) {
    if (_selectedAcoMode != mode) {
      _selectedAcoMode = mode;
      initializeSolvers();
    }
  }

  void setBenchmark(BenchmarkType benchmark) {
    if (_selectedBenchmark != benchmark) {
      _selectedBenchmark = benchmark;
      initializeSolvers();
    }
  }

  void setMaxIterations(int val) {
    _maxIterations = val;
    notifyListeners();
  }

  void setAgentCount(int val) {
    _agentCount = val;
    initializeSolvers();
  }

  void setSeed(int? val) {
    _seed = val;
    initializeSolvers();
  }

  void setStepDelay(int ms) {
    _stepDelayMs = ms;
    if (_status == SimulationStatus.running) {
      _stopTimer();
      _startTimer();
    }
    notifyListeners();
  }

  void setAcoParams({double? alpha, double? beta, double? evaporation, double? deposit}) {
    if (alpha != null) _acoAlpha = alpha;
    if (beta != null) _acoBeta = beta;
    if (evaporation != null) _acoEvaporation = evaporation;
    if (deposit != null) _acoDeposit = deposit;
    initializeSolvers();
  }

  void setPsoParams({double? inertia, double? cognitive, double? social}) {
    if (inertia != null) _psoInertia = inertia;
    if (cognitive != null) _psoCognitive = cognitive;
    if (social != null) _psoSocial = social;
    initializeSolvers();
  }

  void setAbcParams({int? abandonmentLimit}) {
    if (abandonmentLimit != null) _abcAbandonmentLimit = abandonmentLimit;
    initializeSolvers();
  }

  void start() {
    if (_status == SimulationStatus.completed) {
      initializeSolvers();
    }
    _status = SimulationStatus.running;
    _stopwatch.start();
    _startTimer();
    notifyListeners();
  }

  void pause() {
    if (_status == SimulationStatus.running) {
      _status = SimulationStatus.paused;
      _stopTimer();
      _stopwatch.stop();
      notifyListeners();
    }
  }

  void resume() {
    if (_status == SimulationStatus.paused) {
      _status = SimulationStatus.running;
      _stopwatch.start();
      _startTimer();
      notifyListeners();
    }
  }

  void stop() {
    _stopTimer();
    _stopwatch.stop();
    _status = SimulationStatus.completed;
    _recordCompletionStats();
    notifyListeners();
  }

  void reset() {
    initializeSolvers();
  }

  void stepSingle() {
    if (_status == SimulationStatus.completed) return;
    _executeOneIteration();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: _stepDelayMs), (_) {
      _executeOneIteration();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _executeOneIteration() {
    if (_currentIteration >= _maxIterations) {
      stop();
      return;
    }

    SimulationMetricPoint? point;

    switch (_selectedAlgorithm) {
      case AlgorithmType.aco:
        if (_selectedAcoMode == AcoProblemMode.tsp) {
          if (_acoTspSolver != null) {
            point = _acoTspSolver!.stepIteration();
            _evaluationsCount += _agentCount;
            _currentBestObjective = _acoTspSolver!.globalBestRoute?.totalDistance;
          }
        } else {
          if (_acoGridSolver != null) {
            point = _acoGridSolver!.stepIteration();
            _evaluationsCount += _agentCount;
            _currentBestObjective = _acoGridSolver!.globalBestPath?.stepCount.toDouble();
          }
        }
        break;

      case AlgorithmType.pso:
        if (_psoSolver != null) {
          point = _psoSolver!.stepIteration();
          _evaluationsCount += _agentCount;
          _currentBestObjective = _psoSolver!.globalBestFitness;
        }
        break;

      case AlgorithmType.abc:
        if (_abcSolver != null) {
          point = _abcSolver!.stepIteration();
          // In ABC, evaluations happen in employed and onlooker phases
          _evaluationsCount += _abcSolver!.foodSources.length + _abcSolver!.onlookerBeeCount;
          _currentBestObjective = _abcSolver!.bestFoodSource?.objectiveValue;
        }
        break;
    }

    if (point != null) {
      _currentIteration = point.iteration;
      _currentAverageObjective = point.averageObjective;
      _initialBestObjective ??= point.bestObjective;
      _totalIterationsExecuted++;
    }

    if (_currentIteration >= _maxIterations) {
      stop();
    } else {
      notifyListeners();
    }
  }

  void _recordCompletionStats() {
    _totalSimulationsCompleted++;
    if (_currentBestObjective != null) {
      if (_allTimeBestFitness == null || _currentBestObjective! < _allTimeBestFitness!) {
        _allTimeBestFitness = _currentBestObjective;
      }
    }
  }

  @override
  void dispose() {
    _stopTimer();
    _stopwatch.stop();
    super.dispose();
  }
}
