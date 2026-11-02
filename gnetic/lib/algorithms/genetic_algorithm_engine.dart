import 'dart:math';
import '../models/chromosome.dart';
import '../models/ga_config.dart';
import '../models/generation.dart';
import '../models/individual.dart';
import '../models/problem_type.dart';
import '../models/simulation_result.dart';
import '../problems/base_problem.dart';
import 'crossover.dart';
import 'mutation.dart';
import 'selection.dart';

class GeneticAlgorithmEngine {
  final BaseProblem<int> problem;
  final GAConfig config;
  final Random _random = Random();

  List<Generation<int>> _generationHistory = [];
  int _currentGenNumber = 0;
  List<Individual<int>> _currentPopulation = [];

  GeneticAlgorithmEngine({
    required this.problem,
    required this.config,
  });

  List<Generation<int>> get generationHistory => List.unmodifiable(_generationHistory);
  int get currentGenNumber => _currentGenNumber;
  Generation<int>? get latestGeneration =>
      _generationHistory.isNotEmpty ? _generationHistory.last : null;

  /// Step 1: Initialize random population and evaluate fitness
  Generation<int> initialize() {
    _generationHistory.clear();
    _currentGenNumber = 0;
    _currentPopulation.clear();

    List<Individual<int>> rawPop = [];
    for (int i = 0; i < config.populationSize; i++) {
      Chromosome<int> chromo = problem.generateRandomChromosome();
      double fitness = problem.evaluateFitness(chromo);
      String decoded = problem.decodeSolution(chromo);
      rawPop.add(Individual<int>(
        id: i + 1,
        chromosome: chromo,
        fitness: fitness,
        decodedSolution: decoded,
      ));
    }

    _currentPopulation = problem.rankPopulation(rawPop);
    Generation<int> initialGen = _createGenerationSnapshot(0, _currentPopulation);
    _generationHistory.add(initialGen);
    return initialGen;
  }

  /// Step 2-7: Evolve population to the next generation
  Generation<int> nextGeneration() {
    if (_currentPopulation.isEmpty) {
      initialize();
    }

    _currentGenNumber++;
    List<Individual<int>> nextPopRaw = [];

    // Elitism: Copy top elites directly to next generation intact
    if (config.elitism && config.elitismCount > 0) {
      int count = min(config.elitismCount, _currentPopulation.length);
      for (int i = 0; i < count; i++) {
        nextPopRaw.add(_currentPopulation[i].copyWith(id: i + 1));
      }
    }

    // Fill remaining population with reproduction offspring
    int indIdCounter = nextPopRaw.length + 1;
    while (nextPopRaw.length < config.populationSize) {
      // Selection
      Individual<int> parentA = GASelection.select(
        _currentPopulation,
        config.selectionMethod,
        tournamentSize: config.tournamentSize,
      );
      Individual<int> parentB = GASelection.select(
        _currentPopulation,
        config.selectionMethod,
        tournamentSize: config.tournamentSize,
      );

      // Crossover
      Chromosome<int> childChromoA;
      Chromosome<int> childChromoB;

      if (problem.problemType == ProblemType.tsp) {
        final (cA, cB) = GACrossover.orderedCrossover(
          parentA.chromosome,
          parentB.chromosome,
          config.crossoverRate,
        );
        childChromoA = cA;
        childChromoB = cB;
      } else {
        final (cA, cB) = GACrossover.singlePointCrossover(
          parentA.chromosome,
          parentB.chromosome,
          config.crossoverRate,
        );
        childChromoA = cA;
        childChromoB = cB;
      }

      // Mutation
      if (problem.problemType == ProblemType.tsp) {
        childChromoA = GAMutation.swapMutation(childChromoA, config.mutationRate);
        childChromoB = GAMutation.swapMutation(childChromoB, config.mutationRate);
      } else if (problem.problemType == ProblemType.scheduling) {
        childChromoA = GAMutation.discreteRandomMutation(childChromoA, config.mutationRate, 4);
        childChromoB = GAMutation.discreteRandomMutation(childChromoB, config.mutationRate, 4);
      } else {
        childChromoA = GAMutation.bitFlipMutation(childChromoA, config.mutationRate);
        childChromoB = GAMutation.bitFlipMutation(childChromoB, config.mutationRate);
      }

      // Evaluate Child A
      double fitA = problem.evaluateFitness(childChromoA);
      String decA = problem.decodeSolution(childChromoA);
      nextPopRaw.add(Individual<int>(
        id: indIdCounter++,
        chromosome: childChromoA,
        fitness: fitA,
        decodedSolution: decA,
      ));

      if (nextPopRaw.length < config.populationSize) {
        // Evaluate Child B
        double fitB = problem.evaluateFitness(childChromoB);
        String decB = problem.decodeSolution(childChromoB);
        nextPopRaw.add(Individual<int>(
          id: indIdCounter++,
          chromosome: childChromoB,
          fitness: fitB,
          decodedSolution: decB,
        ));
      }
    }

    _currentPopulation = problem.rankPopulation(nextPopRaw);
    Generation<int> genSnapshot = _createGenerationSnapshot(_currentGenNumber, _currentPopulation);
    _generationHistory.add(genSnapshot);
    return genSnapshot;
  }

  /// Run complete simulation synchronously for experiment/analytics benchmark mode
  SimulationResult<int> runFullSimulation() {
    Stopwatch sw = Stopwatch()..start();
    initialize();

    for (int gen = 1; gen <= config.maxGenerations; gen++) {
      nextGeneration();
    }
    sw.stop();

    return SimulationResult<int>(
      generations: List.from(_generationHistory),
      initialBest: _generationHistory.first.bestIndividual,
      finalBest: _generationHistory.last.bestIndividual,
      totalGenerationsExecuted: _generationHistory.length - 1,
      executionTime: sw.elapsed,
      problemName: problem.name,
    );
  }

  Generation<int> _createGenerationSnapshot(int genNum, List<Individual<int>> pop) {
    double totalFit = pop.fold(0.0, (sum, i) => sum + i.fitness);
    double avgFit = totalFit / pop.length;
    double worstFit = pop.last.fitness;

    // Calculate diversity as proportion of unique chromosome string representation
    Set<String> uniqueChromo = pop.map((i) => i.chromosome.toString()).toSet();
    double diversity = (uniqueChromo.length / pop.length) * 100;

    return Generation<int>(
      generationNumber: genNum,
      population: pop,
      bestIndividual: pop.first,
      averageFitness: avgFit,
      worstFitness: worstFit,
      diversity: diversity,
    );
  }
}
