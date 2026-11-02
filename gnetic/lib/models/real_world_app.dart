import 'package:flutter/material.dart';

class RealWorldApp {
  final String id;
  final String title;
  final String category;
  final IconData icon;
  final String problemDescription;
  final String traditionalChallenge;
  final String gaSolution;
  final String chromosomeRepresentation;
  final String fitnessFunction;
  final String selectionStrategy;
  final String crossoverStrategy;
  final String mutationStrategy;
  final String expectedOutput;
  final String realWorldExample;

  const RealWorldApp({
    required this.id,
    required this.title,
    required this.category,
    required this.icon,
    required this.problemDescription,
    required this.traditionalChallenge,
    required this.gaSolution,
    required this.chromosomeRepresentation,
    required this.fitnessFunction,
    required this.selectionStrategy,
    required this.crossoverStrategy,
    required this.mutationStrategy,
    required this.expectedOutput,
    required this.realWorldExample,
  });
}

class RealWorldAppData {
  static const List<RealWorldApp> applications = [
    RealWorldApp(
      id: 'route_opt',
      title: 'Route & Delivery Optimization',
      category: 'Transportation',
      icon: Icons.local_shipping_rounded,
      problemDescription: 'Find optimal delivery routes for fleet vehicles across dozens or hundreds of delivery locations.',
      traditionalChallenge: 'Extremely high NP-hard factorial complexity (N!). Brute force requires centuries for 20+ cities.',
      gaSolution: 'Evolves route permutations across multiple generations to converge on near-optimal path length and fuel efficiency.',
      chromosomeRepresentation: 'Permutation array of city IDs e.g., [3, 1, 7, 0, 5, 2, 4, 6]',
      fitnessFunction: 'Inverse of total route distance + vehicle capacity penalty (1 / Total Distance).',
      selectionStrategy: 'Tournament selection (k=3) preserving high-fitness route fragments.',
      crossoverStrategy: 'Ordered Crossover (OX) ensuring no duplicated cities in child route.',
      mutationStrategy: 'Swap Mutation or Inversion Mutation to break out of local distance traps.',
      expectedOutput: 'Shortest total distance route with balanced load across vehicles.',
      realWorldExample: 'Used by FedEx, DHL, and Amazon Logistics for daily route dispatch optimization.',
    ),
    RealWorldApp(
      id: 'timetable_sched',
      title: 'Timetable & Job Scheduling',
      category: 'Scheduling',
      icon: Icons.calendar_month_rounded,
      problemDescription: 'Assign university courses, professors, labs, and classrooms into weekly time slots without conflicts.',
      traditionalChallenge: 'Over-constrained problem space where deterministic constraint logic fails or deadlocks.',
      gaSolution: 'Simultaneously evaluates soft and hard constraints in population chromosomes to produce clash-free schedules.',
      chromosomeRepresentation: 'Vector of slot-room gene tuples for each scheduled course module.',
      fitnessFunction: '100 - (Hard Conflicts × 10 + Soft Conflicts × 1). Perfect schedule = 100.',
      selectionStrategy: 'Roulette Wheel selection or Rank selection.',
      crossoverStrategy: 'Single-point crossover swapping timetable blocks between parents.',
      mutationStrategy: 'Randomly re-assigning a course to a different available time slot or room.',
      expectedOutput: 'Conflict-free weekly timetable with optimal teacher workload distribution.',
      realWorldExample: 'Used in engineering colleges and airlines for pilot/crew duty rostering.',
    ),
    RealWorldApp(
      id: 'portfolio_opt',
      title: 'Financial Portfolio Optimization',
      category: 'Finance',
      icon: Icons.pie_chart_rounded,
      problemDescription: 'Select asset weights in an investment portfolio to maximize returns while minimizing risk.',
      traditionalChallenge: 'Non-linear risk-return search space with asset correlations and strict budget constraints.',
      gaSolution: 'Navigates the Pareto-optimal frontier to locate ideal risk-return balances according to investor risk tolerance.',
      chromosomeRepresentation: 'Array of continuous real numbers representing percentage asset allocations summing to 100%.',
      fitnessFunction: 'Sharpe Ratio = (Expected Return - Risk Free Rate) / Portfolio Standard Deviation.',
      selectionStrategy: 'Tournament Selection combined with Elitism.',
      crossoverStrategy: 'Arithmetic / Blend Crossover (BLX-alpha).',
      mutationStrategy: 'Gaussian mutation adding small noise to asset weights.',
      expectedOutput: 'Optimal portfolio asset allocation maximizing Sharpe ratio.',
      realWorldExample: 'Used by quantitative hedge funds and robo-advisors for asset management.',
    ),
    RealWorldApp(
      id: 'feature_select',
      title: 'ML Feature Selection',
      category: 'AI & Machine Learning',
      icon: Icons.bubble_chart_rounded,
      problemDescription: 'Select the most informative subset of features from high-dimensional datasets to train ML models.',
      traditionalChallenge: 'Combinatorial explosion 2^N feature combinations; high dimensional data leads to overfitting.',
      gaSolution: 'Binary GA searches 2^N combinations to identify minimal feature sets with maximum classification accuracy.',
      chromosomeRepresentation: 'Binary vector [1, 0, 1, 1, 0...] where 1 = feature included, 0 = feature omitted.',
      fitnessFunction: 'Model Accuracy - (Penalty × Number of Selected Features).',
      selectionStrategy: 'Tournament selection favoring compact, accurate feature subsets.',
      crossoverStrategy: 'Uniform crossover.',
      mutationStrategy: 'Bit-flip mutation to test adding/removing individual features.',
      expectedOutput: 'Optimal subset of features boosting ML model speed and predictive accuracy.',
      realWorldExample: 'Genomic feature selection in bioinformatics & medical diagnostics.',
    ),
    RealWorldApp(
      id: 'robot_path',
      title: 'Autonomous Robot Path Planning',
      category: 'Robotics',
      icon: Icons.smart_toy_rounded,
      problemDescription: 'Guide mobile robots or drones through dynamic environments with obstacles to reach a target.',
      traditionalChallenge: 'Complex 3D continuous spaces with moving obstacles where grid-search A* becomes too slow.',
      gaSolution: 'Evolves waypoints along continuous bezier curves avoiding obstacle coordinates.',
      chromosomeRepresentation: 'Sequence of 2D/3D coordinate waypoints [(x1,y1), (x2,y2), ...].',
      fitnessFunction: '1 / (Path Length + Collision Penalty + Smoothness Penalty).',
      selectionStrategy: 'Rank-based selection.',
      crossoverStrategy: 'Multipoint waypoint crossover.',
      mutationStrategy: 'Random coordinate perturbation.',
      expectedOutput: 'Smooth, collision-free trajectory for mobile robot execution.',
      realWorldExample: 'Warehouse autonomous robots (AMRs) and drone navigation systems.',
    ),
    RealWorldApp(
      id: 'neural_arch',
      title: 'Neural Architecture Search (NAS)',
      category: 'AI & Machine Learning',
      icon: Icons.account_tree_rounded,
      problemDescription: 'Automatically design deep neural network layer topologies, filter counts, and activation functions.',
      traditionalChallenge: 'Manual trial-and-error by AI researchers takes weeks of design work.',
      gaSolution: 'Evolves neural network structural blueprints (Neuroevolution) for high accuracy on target hardware.',
      chromosomeRepresentation: 'Layer configuration objects defining layer types, filter numbers, and connection topology.',
      fitnessFunction: 'Validation Accuracy / (Inference Time × Model Size).',
      selectionStrategy: 'Tournament selection with age-based replacement.',
      crossoverStrategy: 'Sub-network topology swapping.',
      mutationStrategy: 'Adding/deleting layers or mutating layer hyper-parameters.',
      expectedOutput: 'State-of-the-art compact deep learning model structure.',
      realWorldExample: 'Google AutoML and edge AI model compression.',
    ),
    RealWorldApp(
      id: 'traffic_light',
      title: 'Smart Traffic Light Signal Control',
      category: 'Transportation',
      icon: Icons.traffic_rounded,
      problemDescription: 'Dynamically set traffic light green-phase durations across city intersections to eliminate bottlenecks.',
      traditionalChallenge: 'Fixed-timer traffic lights cannot adapt to real-time traffic spikes and congestion.',
      gaSolution: 'Evolves timing patterns dynamically based on real-time vehicle camera counts across multi-intersection grids.',
      chromosomeRepresentation: 'Integer array of green signal durations (seconds) for each phase.',
      fitnessFunction: '1 / Total Cumulative Vehicle Waiting Time at Intersections.',
      selectionStrategy: 'Elitist tournament selection.',
      crossoverStrategy: 'Single-point timing crossover.',
      mutationStrategy: 'Random timing adjustment (±5 seconds).',
      expectedOutput: 'Synchronized green-wave signal timings minimizing urban traffic delay.',
      realWorldExample: 'Smart city traffic management in Singapore and London.',
    ),
    RealWorldApp(
      id: 'antenna_design',
      title: 'Engineering & Antenna Design',
      category: 'Engineering',
      icon: Icons.cell_tower_rounded,
      problemDescription: 'Design complex 3D antenna shapes for spacecraft or satellite communications with high directional gain.',
      traditionalChallenge: 'Electromagnetic wave propagation equations are non-linear with unexpected boundary interactions.',
      gaSolution: 'Evolves unusual non-symmetrical 3D wire configurations that outperform human-designed antennas.',
      chromosomeRepresentation: '3D wire geometry coordinates and connection nodes.',
      fitnessFunction: 'Directional Radiation Gain - Sidelobe Power Interference.',
      selectionStrategy: 'Roulette Wheel selection.',
      crossoverStrategy: 'Spatially-grouped segment crossover.',
      mutationStrategy: 'Node displacement mutation.',
      expectedOutput: 'Evolved antenna geometry with optimal electromagnetic radiation pattern.',
      realWorldExample: 'NASA ST5 spacecraft evolved antenna deployed in orbit.',
    ),
  ];
}
