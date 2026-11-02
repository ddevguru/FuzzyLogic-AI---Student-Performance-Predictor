import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../problems/grid_environment.dart';
import '../../algorithms/aco/aco_grid_solver.dart';

class GridCanvas extends StatelessWidget {
  final GridEnvironment environment;
  final AcoGridSolver? solver;
  final Function(int x, int y)? onCellTapped;

  const GridCanvas({
    super.key,
    required this.environment,
    this.solver,
    this.onCellTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellSize = (constraints.maxWidth / environment.width).clamp(16.0, 40.0);
        final totalW = cellSize * environment.width;
        final totalH = cellSize * environment.height;

        return Center(
          child: GestureDetector(
            onTapUp: (details) {
              if (onCellTapped != null) {
                final x = (details.localPosition.dx / cellSize).floor();
                final y = (details.localPosition.dy / cellSize).floor();
                if (x >= 0 && x < environment.width && y >= 0 && y < environment.height) {
                  onCellTapped!(x, y);
                }
              }
            },
            child: Container(
              width: totalW,
              height: totalH,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0D1626) : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  width: 1.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(
                  size: Size(totalW, totalH),
                  painter: _GridPainter(
                    environment: environment,
                    solver: solver,
                    isDark: isDark,
                    cellSize: cellSize,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  final GridEnvironment environment;
  final AcoGridSolver? solver;
  final bool isDark;
  final double cellSize;

  _GridPainter({
    required this.environment,
    required this.solver,
    required this.isDark,
    required this.cellSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridLinePaint = Paint()
      ..color = isDark ? const Color(0xFF1E2E47) : const Color(0xFFE2E8F0)
      ..strokeWidth = 0.8;

    final obstaclePaint = Paint()
      ..color = isDark ? const Color(0xFF334155) : const Color(0xFF64748B);

    final startPaint = Paint()..color = AppColors.green;
    final goalPaint = Paint()..color = AppColors.gold;

    // 1. Draw Cells & Obstacles & Pheromones
    for (int y = 0; y < environment.height; y++) {
      for (int x = 0; x < environment.width; x++) {
        final rect = Rect.fromLTWH(x * cellSize, y * cellSize, cellSize, cellSize);
        final cellType = environment.grid[y][x];

        if (cellType == CellType.obstacle) {
          canvas.drawRect(rect, obstaclePaint);
        } else {
          // Check pheromone level
          if (solver != null && solver!.cellPheromone.isNotEmpty) {
            final phero = solver!.cellPheromone[y][x];
            if (phero > 1.05) {
              final norm = ((phero - 1.0) / 10.0).clamp(0.05, 0.7);
              final pheroColor = (isDark ? AppColors.blue : AppColors.accentCyan).withValues(alpha: norm);
              canvas.drawRect(rect, Paint()..color = pheroColor);
            }
          }

          if (cellType == CellType.start) {
            canvas.drawRect(rect, startPaint);
          } else if (cellType == CellType.goal) {
            canvas.drawRect(rect, goalPaint);
          }
        }

        // Grid outline
        canvas.drawRect(rect, gridLinePaint..style = PaintingStyle.stroke);
      }
    }

    // 2. Draw recent ant paths (faint lines)
    if (solver != null && solver!.currentAntPaths.isNotEmpty) {
      final pathPaint = Paint()
        ..color = (isDark ? Colors.amber.withValues(alpha: 0.25) : Colors.orange.withValues(alpha: 0.25))
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      for (final sol in solver!.currentAntPaths.take(12)) {
        if (sol.path.length < 2) continue;
        final p = Path();
        p.moveTo(sol.path.first.x * cellSize + cellSize / 2, sol.path.first.y * cellSize + cellSize / 2);
        for (int i = 1; i < sol.path.length; i++) {
          p.lineTo(sol.path[i].x * cellSize + cellSize / 2, sol.path[i].y * cellSize + cellSize / 2);
        }
        canvas.drawPath(p, pathPaint);
      }
    }

    // 3. Draw Global Best Path (Vibrant Green / Gold continuous path)
    if (solver != null && solver!.globalBestPath != null && solver!.globalBestPath!.reachedGoal) {
      final best = solver!.globalBestPath!;
      if (best.path.length >= 2) {
        final glowPaint = Paint()
          ..color = AppColors.green.withValues(alpha: 0.4)
          ..strokeWidth = 5.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final strokePaint = Paint()
          ..color = AppColors.green
          ..strokeWidth = 3.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;

        final p = Path();
        p.moveTo(best.path.first.x * cellSize + cellSize / 2, best.path.first.y * cellSize + cellSize / 2);
        for (int i = 1; i < best.path.length; i++) {
          p.lineTo(best.path[i].x * cellSize + cellSize / 2, best.path[i].y * cellSize + cellSize / 2);
        }

        canvas.drawPath(p, glowPaint);
        canvas.drawPath(p, strokePaint);
      }
    }

    // 4. Draw Start and Goal Icons/Labels
    final iconStyle = TextStyle(
      fontSize: cellSize * 0.5,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    );

    final startTp = TextPainter(text: TextSpan(text: 'S', style: iconStyle), textDirection: TextDirection.ltr)..layout();
    startTp.paint(
      canvas,
      Offset(
        environment.start.x * cellSize + (cellSize - startTp.width) / 2,
        environment.start.y * cellSize + (cellSize - startTp.height) / 2,
      ),
    );

    final goalTp = TextPainter(text: TextSpan(text: 'G', style: iconStyle), textDirection: TextDirection.ltr)..layout();
    goalTp.paint(
      canvas,
      Offset(
        environment.goal.x * cellSize + (cellSize - goalTp.width) / 2,
        environment.goal.y * cellSize + (cellSize - goalTp.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => true;
}
