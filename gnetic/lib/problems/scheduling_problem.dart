import 'dart:math';
import '../models/chromosome.dart';
import '../models/gene.dart';
import '../models/problem_type.dart';
import 'base_problem.dart';

class Course {
  final String code;
  final String name;
  final String instructor;
  final String room;

  const Course({
    required this.code,
    required this.name,
    required this.instructor,
    required this.room,
  });
}

class SchedulingProblem extends BaseProblem<int> {
  final Random _random = Random();

  static const List<Course> courses = [
    Course(code: 'CS201', name: 'Data Structures', instructor: 'Dr. Sharma', room: 'Room 101'),
    Course(code: 'CS302', name: 'Artificial Intell.', instructor: 'Dr. Patel', room: 'Lab A'),
    Course(code: 'CS204', name: 'DBMS', instructor: 'Prof. Gupta', room: 'Room 102'),
    Course(code: 'CS305', name: 'Computer Networks', instructor: 'Dr. Sharma', room: 'Room 101'), // Same instructor & room as CS201!
    Course(code: 'CS208', name: 'Operating Systems', instructor: 'Dr. Patel', room: 'Lab A'),   // Same instructor & room as CS302!
  ];

  static const List<String> timeSlots = ['9:00 AM', '10:00 AM', '11:00 AM', '12:00 PM'];

  @override
  ProblemType get problemType => ProblemType.scheduling;

  @override
  String get name => 'Timetable Scheduling';

  @override
  String get description => 'Assign 5 core engineering courses to 4 time slots while avoiding instructor and room collisions.';

  @override
  int get chromosomeLength => courses.length;

  @override
  Chromosome<int> generateRandomChromosome() {
    List<Gene<int>> genes = List.generate(
      courses.length,
      (_) => Gene<int>(value: _random.nextInt(timeSlots.length)),
    );
    return Chromosome<int>(genes: genes);
  }

  int countConflicts(Chromosome<int> chromosome) {
    int conflicts = 0;
    List<int> slots = chromosome.rawValues;

    for (int i = 0; i < courses.length; i++) {
      for (int j = i + 1; j < courses.length; j++) {
        if (slots[i] == slots[j]) {
          // Time slot collision!
          // Check if instructor is same
          if (courses[i].instructor == courses[j].instructor) {
            conflicts += 2; // High penalty for teacher double-booking
          }
          // Check if room is same
          if (courses[i].room == courses[j].room) {
            conflicts += 2; // High penalty for room collision
          }
        }
      }
    }
    return conflicts;
  }

  @override
  double evaluateFitness(Chromosome<int> chromosome) {
    int conflicts = countConflicts(chromosome);
    // Perfect schedule = 100 fitness points
    double score = 100.0 / (1.0 + conflicts * 2.0);
    return score;
  }

  @override
  String decodeSolution(Chromosome<int> chromosome) {
    int conflicts = countConflicts(chromosome);
    String status = conflicts == 0 ? '✓ ZERO CONFLICTS' : '✗ $conflicts CONFLICT(S)';
    return 'Score: ${evaluateFitness(chromosome).toStringAsFixed(1)}% | Status: $status';
  }
}
