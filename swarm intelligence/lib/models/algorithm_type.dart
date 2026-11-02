import 'package:flutter/material.dart';

enum AlgorithmType {
  aco('Ant Colony Optimization', 'ACO', 'Stigmergy & Pheromone Trails'),
  pso('Particle Swarm Optimization', 'PSO', 'Velocity & Cognitive-Social Search'),
  abc('Artificial Bee Colony', 'ABC', 'Employed, Onlooker & Scout Bees');

  final String fullName;
  final String shortName;
  final String subtitle;

  const AlgorithmType(this.fullName, this.shortName, this.subtitle);

  IconData get icon {
    switch (this) {
      case AlgorithmType.aco:
        return Icons.alt_route_rounded;
      case AlgorithmType.pso:
        return Icons.grain_rounded;
      case AlgorithmType.abc:
        return Icons.hive_rounded;
    }
  }

  Color get accentColor {
    switch (this) {
      case AlgorithmType.aco:
        return const Color(0xFFD2AE39); // Gold
      case AlgorithmType.pso:
        return const Color(0xFF1769AA); // Blue
      case AlgorithmType.abc:
        return const Color(0xFF2E8B57); // Green
    }
  }
}

enum AcoProblemMode {
  tsp('Traveling Salesman Problem', 'Find the shortest tour visiting all cities exactly once.'),
  grid('Grid Pathfinding', 'Ants discover shortest obstacle-free trajectory to food.');

  final String title;
  final String description;
  const AcoProblemMode(this.title, this.description);
}
