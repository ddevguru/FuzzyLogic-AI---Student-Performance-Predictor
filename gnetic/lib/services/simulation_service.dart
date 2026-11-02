import 'dart:async';
import 'package:flutter/material.dart';
import '../algorithms/genetic_algorithm_engine.dart';
import '../models/ga_config.dart';
import '../models/generation.dart';
import '../models/individual.dart';
import '../models/problem_type.dart';
import '../models/simulation_result.dart';
import '../problems/base_problem.dart';
import '../problems/function_optimization_problem.dart';
import '../problems/knapsack_problem.dart';
import '../problems/scheduling_problem.dart';
import '../problems/tsp_problem.dart';

enum SimulationState { idle, running, paused, completed }

class SessionAnalytics {
  int totalSimulationsRun = 0;
  double overallBestFitness = 0.0;
  List<int> generationsToCompletion = [];
  List<double> fitnessImprovementPercentages = [];

  double get averageGenerations {
    if (generationsToCompletion.isEmpty) return 0.0;
    return generationsToCompletion.reduce((a, b) => a + b) / generationsToCompletion.length;
  }

  double get averageImprovement {
    if (fitnessImprovementPercentages.isEmpty) return 0.0;
    return fitnessImprovementPercentages.reduce((a, b) => a + b) / fitnessImprovementPercentages.length;
  }

  void recordResult(SimulationResult result) {
    totalSimulationsRun++;
    if (result.finalFitness > overallBestFitness) {
      overallBestFitness = result.finalFitness;
    }
    generationsToCompletion.add(result.totalGenerationsExecuted);
    fitnessImprovementPercentages.add(result.percentageImprovement);
  }
}

class SimulationService extends ChangeNotifier {
  ProblemType _selectedProblemType = ProblemType.functionOptimization;
  late BaseProblem<int> _currentProblem;
  late GAConfig _config;
  late GeneticAlgorithmEngine _engine;

  SimulationState _state = SimulationState.idle;
  int _speedMs = 350;
  Timer? _timer;

  final SessionAnalytics _analytics = SessionAnalytics();

  SimulationService() {
    _config = const GAConfig();
    _currentProblem = FunctionOptimizationProblem();
    _engine = GeneticAlgorithmEngine(problem: _currentProblem, config: _config);
    _engine.initialize();
  }

  ProblemType get selectedProblemType => _selectedProblemType;
  BaseProblem<int> get currentProblem => _currentProblem;
  GAConfig get config => _config;
  GeneticAlgorithmEngine get engine => _engine;
  SimulationState get state => _state;
  int get speedMs => _speedMs;
  SessionAnalytics get analytics => _analytics;

  bool get isRunning => _state == SimulationState.running;
  bool get isPaused => _state == SimulationState.paused;
  bool get isCompleted => _state == SimulationState.completed;

  Generation<int>? get currentGen => _engine.latestGeneration;
  Individual<int>? get bestIndividual => currentGen?.bestIndividual;

  void selectProblem(ProblemType type) {
    if (_selectedProblemType == type) return;
    _stopTimer();
    _selectedProblemType = type;
    switch (type) {
      case ProblemType.functionOptimization:
        _currentProblem = FunctionOptimizationProblem();
        break;
      case ProblemType.knapsack:
        _currentProblem = KnapsackProblem();
        break;
      case ProblemType.tsp:
        _currentProblem = TSPProblem();
        break;
      case ProblemType.scheduling:
        _currentProblem = SchedulingProblem();
        break;
    }
    resetSimulation();
  }

  void updateConfig(GAConfig newConfig) {
    _stopTimer();
    _config = newConfig;
    _engine = GeneticAlgorithmEngine(problem: _currentProblem, config: _config);
    resetSimulation();
  }

  void setSpeed(int ms) {
    _speedMs = ms;
    if (_state == SimulationState.running) {
      _stopTimer();
      _startTimer();
    }
    notifyListeners();
  }

  void resetSimulation() {
    _stopTimer();
    _state = SimulationState.idle;
    _engine = GeneticAlgorithmEngine(problem: _currentProblem, config: _config);
    _engine.initialize();
    notifyListeners();
  }

  void stepSimulation() {
    if (_state == SimulationState.completed) return;
    if (_engine.currentGenNumber >= _config.maxGenerations) {
      _finishSimulation();
      return;
    }

    _engine.nextGeneration();

    if (_engine.currentGenNumber >= _config.maxGenerations) {
      _finishSimulation();
    } else {
      if (_state == SimulationState.idle) _state = SimulationState.paused;
      notifyListeners();
    }
  }

  void startSimulation() {
    if (_state == SimulationState.completed) {
      resetSimulation();
    }
    _state = SimulationState.running;
    _startTimer();
    notifyListeners();
  }

  void pauseSimulation() {
    _stopTimer();
    _state = SimulationState.paused;
    notifyListeners();
  }

  void resumeSimulation() {
    if (_state == SimulationState.paused) {
      _state = SimulationState.running;
      _startTimer();
      notifyListeners();
    }
  }

  SimulationResult<int> runFullExperiment(GAConfig expConfig, ProblemType problemType) {
    BaseProblem<int> expProblem;
    switch (problemType) {
      case ProblemType.functionOptimization:
        expProblem = FunctionOptimizationProblem();
        break;
      case ProblemType.knapsack:
        expProblem = KnapsackProblem();
        break;
      case ProblemType.tsp:
        expProblem = TSPProblem();
        break;
      case ProblemType.scheduling:
        expProblem = SchedulingProblem();
        break;
    }

    GeneticAlgorithmEngine expEngine = GeneticAlgorithmEngine(problem: expProblem, config: expConfig);
    SimulationResult<int> res = expEngine.runFullSimulation();
    _analytics.recordResult(res);
    notifyListeners();
    return res;
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: _speedMs), (timer) {
      if (_engine.currentGenNumber >= _config.maxGenerations) {
        _finishSimulation();
      } else {
        _engine.nextGeneration();
        notifyListeners();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _finishSimulation() {
    _stopTimer();
    _state = SimulationState.completed;
    if (_engine.generationHistory.length > 1) {
      SimulationResult<int> res = SimulationResult<int>(
        generations: List.from(_engine.generationHistory),
        initialBest: _engine.generationHistory.first.bestIndividual,
        finalBest: _engine.generationHistory.last.bestIndividual,
        totalGenerationsExecuted: _engine.currentGenNumber,
        executionTime: Duration(milliseconds: _engine.currentGenNumber * _speedMs),
        problemName: _currentProblem.name,
      );
      _analytics.recordResult(res);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
