import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../problems/scheduling_problem.dart';

class SchedulingTimetableView extends StatelessWidget {
  final List<int> slotAssignments;

  const SchedulingTimetableView({
    super.key,
    required this.slotAssignments,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.table_chart_rounded, color: AppColors.blue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'GENERATED TIMETABLE MATRIX',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              const Text(
                '4 Slots × 5 Courses',
                style: TextStyle(fontSize: 10, color: AppColors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Column(
            children: List.generate(SchedulingProblem.timeSlots.length, (slotIdx) {
              final slotName = SchedulingProblem.timeSlots[slotIdx];
              List<int> assignedCourseIndices = [];
              for (int c = 0; c < slotAssignments.length; c++) {
                if (slotAssignments[c] == slotIdx) {
                  assignedCourseIndices.add(c);
                }
              }

              bool hasConflict = false;
              if (assignedCourseIndices.length > 1) {
                // Check if any 2 assigned courses share instructor or room
                for (int i = 0; i < assignedCourseIndices.length; i++) {
                  for (int j = i + 1; j < assignedCourseIndices.length; j++) {
                    final c1 = SchedulingProblem.courses[assignedCourseIndices[i]];
                    final c2 = SchedulingProblem.courses[assignedCourseIndices[j]];
                    if (c1.instructor == c2.instructor || c1.room == c2.room) {
                      hasConflict = true;
                    }
                  }
                }
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasConflict
                      ? AppColors.accentRed.withOpacity(0.12)
                      : (isDark ? AppColors.darkBackground : AppColors.lightBackground),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: hasConflict
                        ? AppColors.accentRed
                        : (isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder),
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 70,
                      child: Text(
                        slotName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: hasConflict ? AppColors.accentRed : AppColors.blue,
                        ),
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: assignedCourseIndices.isEmpty
                          ? const Text(
                              'Free Slot',
                              style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                            )
                          : Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: assignedCourseIndices.map((cIdx) {
                                final course = SchedulingProblem.courses[cIdx];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkSurface : Colors.white,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.blue.withOpacity(0.4)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${course.code}: ${course.name}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDark ? Colors.white : AppColors.navy,
                                        ),
                                      ),
                                      Text(
                                        '${course.instructor} • ${course.room}',
                                        style: const TextStyle(fontSize: 8, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
