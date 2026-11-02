import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/individual.dart';
import '../../problems/function_optimization_problem.dart';

class FunctionPlotVisualizer extends StatelessWidget {
  final List<Individual<int>> population;

  const FunctionPlotVisualizer({
    super.key,
    required this.population,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
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
            children: const [
              Text(
                'FUNCTION LANDSCAPE: f(x) = x · sin(x) + 10',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Text(
                'Population Convergence',
                style: TextStyle(fontSize: 10, color: AppColors.blue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _FunctionPlotPainter(
                population: population,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FunctionPlotPainter extends CustomPainter {
  final List<Individual<int>> population;
  final bool isDark;

  _FunctionPlotPainter({required this.population, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final prob = FunctionOptimizationProblem();
    const double minX = 0.0;
    const double maxX = 31.875;
    const double minY = 0.0;
    const double maxY = 45.0; // Peak of x*sin(x)+10 in this range

    Offset toCanvasCoords(double x, double y) {
      double px = ((x - minX) / (maxX - minX)) * size.width;
      double py = size.height - (((y - minY) / (maxY - minY)) * size.height);
      return Offset(px, py);
    }

    // Grid lines
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white10 : Colors.black.withOpacity(0.05))
      ..strokeWidth = 1.0;

    for (double y = 0; y <= maxY; y += 10) {
      final pt = toCanvasCoords(minX, y);
      canvas.drawLine(Offset(0, pt.dy), Offset(size.width, pt.dy), gridPaint);
    }

    // Curve Path
    final curvePaint = Paint()
      ..color = AppColors.blue
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    bool first = true;
    for (double x = minX; x <= maxX; x += 0.2) {
      double y = prob.calculateFunctionValue(x);
      final pt = toCanvasCoords(x, y);
      if (first) {
        path.moveTo(pt.dx, pt.dy);
        first = false;
      } else {
        path.lineTo(pt.dx, pt.dy);
      }
    }
    canvas.drawPath(path, curvePaint);

    // Plot Population Candidate Dots
    for (int i = 0; i < population.length; i++) {
      final ind = population[i];
      double x = prob.decodeX(ind.chromosome);
      double y = prob.calculateFunctionValue(x);
      final pt = toCanvasCoords(x, y);

      bool isBest = ind.rankBadge == RankBadge.best;
      Color dotColor = isBest ? AppColors.gold : AppColors.green;

      canvas.drawCircle(
        pt,
        isBest ? 7.0 : 4.0,
        Paint()..color = dotColor.withOpacity(isBest ? 0.9 : 0.6),
      );

      if (isBest) {
        canvas.drawCircle(
          pt,
          10.0,
          Paint()
            ..color = AppColors.gold.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _FunctionPlotPainter oldDelegate) {
    return oldDelegate.population != population || oldDelegate.isDark != isDark;
  }
}
