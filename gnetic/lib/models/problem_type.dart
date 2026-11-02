import 'package:flutter/material.dart';

enum ProblemType {
  functionOptimization,
  knapsack,
  tsp,
  scheduling,
}

extension ProblemTypeExtension on ProblemType {
  String get displayName {
    switch (this) {
      case ProblemType.functionOptimization:
        return 'Function Optimization';
      case ProblemType.knapsack:
        return 'Knapsack Optimization';
      case ProblemType.tsp:
        return 'Traveling Salesman (TSP)';
      case ProblemType.scheduling:
        return 'Timetable Scheduling';
    }
  }

  String get shortName {
    switch (this) {
      case ProblemType.functionOptimization:
        return 'Function Opt';
      case ProblemType.knapsack:
        return 'Knapsack';
      case ProblemType.tsp:
        return 'TSP Route';
      case ProblemType.scheduling:
        return 'Scheduling';
    }
  }

  String get description {
    switch (this) {
      case ProblemType.functionOptimization:
        return 'Maximize f(x) = x · sin(x) + 10 over binary encoded values to locate global peak.';
      case ProblemType.knapsack:
        return 'Select items with maximum total value without exceeding knapsack weight capacity.';
      case ProblemType.tsp:
        return 'Find the shortest round-trip distance connecting 8 cities without visiting any city twice.';
      case ProblemType.scheduling:
        return 'Assign classes to slots & rooms avoiding teacher, room, and time collisions.';
    }
  }

  IconData get icon {
    switch (this) {
      case ProblemType.functionOptimization:
        return Icons.show_chart_rounded;
      case ProblemType.knapsack:
        return Icons.shopping_bag_outlined;
      case ProblemType.tsp:
        return Icons.alt_route_rounded;
      case ProblemType.scheduling:
        return Icons.calendar_month_rounded;
    }
  }
}
