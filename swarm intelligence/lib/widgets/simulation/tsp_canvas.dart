import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/city.dart';
import '../../models/route_solution.dart';
import '../../algorithms/aco/pheromone_matrix.dart';

class TspCanvas extends StatelessWidget {
  final List<City> cities;
  final RouteSolution? globalBestRoute;
  final RouteSolution? iterationBestRoute;
  final List<RouteSolution> currentAntRoutes;
  final PheromoneMatrix? pheromoneMatrix;

  const TspCanvas({
    super.key,
    required this.cities,
    this.globalBestRoute,
    this.iterationBestRoute,
    this.currentAntRoutes = const [],
    this.pheromoneMatrix,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1A2D) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CustomPaint(
          size: Size.infinite,
          painter: _TspPainter(
            cities: cities,
            globalBestRoute: globalBestRoute,
            iterationBestRoute: iterationBestRoute,
            currentAntRoutes: currentAntRoutes,
            pheromoneMatrix: pheromoneMatrix,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _TspPainter extends CustomPainter {
  final List<City> cities;
  final RouteSolution? globalBestRoute;
  final RouteSolution? iterationBestRoute;
  final List<RouteSolution> currentAntRoutes;
  final PheromoneMatrix? pheromoneMatrix;
  final bool isDark;

  _TspPainter({
    required this.cities,
    required this.globalBestRoute,
    required this.iterationBestRoute,
    required this.currentAntRoutes,
    required this.pheromoneMatrix,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (cities.isEmpty) return;

    // Map city normalized coordinates (x, y) in [0, 1] to canvas with margins
    const margin = 36.0;
    final drawW = size.width - margin * 2;
    final drawH = size.height - margin * 2;

    Offset getCityPos(City c) {
      return Offset(margin + c.x * drawW, margin + c.y * drawH);
    }

    final cityOffsets = cities.map(getCityPos).toList();

    // 1. Draw Pheromone Trails between all pairs of cities
    if (pheromoneMatrix != null) {
      final maxPhero = max(1.0, pheromoneMatrix!.getMaxPheromone());
      for (int i = 0; i < cities.length; i++) {
        for (int j = i + 1; j < cities.length; j++) {
          final phero = pheromoneMatrix!.get(i, j);
          final norm = (phero / maxPhero).clamp(0.05, 1.0);

          final pheroPaint = Paint()
            ..color = (isDark ? AppColors.blue : AppColors.primaryNavy)
                .withValues(alpha: norm * 0.45)
            ..strokeWidth = 1.0 + norm * 3.5;

          canvas.drawLine(cityOffsets[i], cityOffsets[j], pheroPaint);
        }
      }
    }

    // 2. Draw Current Iteration Ant paths (faint lines)
    if (currentAntRoutes.isNotEmpty) {
      final antPaint = Paint()
        ..color = (isDark ? Colors.amber.withValues(alpha: 0.15) : Colors.deepOrange.withValues(alpha: 0.12))
        ..strokeWidth = 1.0;

      for (final ant in currentAntRoutes.take(10)) {
        final tour = ant.cityIndices;
        for (int i = 0; i < tour.length - 1; i++) {
          canvas.drawLine(cityOffsets[tour[i]], cityOffsets[tour[i + 1]], antPaint);
        }
        canvas.drawLine(cityOffsets[tour.last], cityOffsets[tour.first], antPaint);
      }
    }

    // 3. Draw Iteration Best Route (Cyan / Blue dashed or secondary)
    if (iterationBestRoute != null && iterationBestRoute != globalBestRoute) {
      final iterPaint = Paint()
        ..color = AppColors.accentCyan.withValues(alpha: 0.75)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      final tour = iterationBestRoute!.cityIndices;
      final path = Path()..moveTo(cityOffsets[tour.first].dx, cityOffsets[tour.first].dy);
      for (int i = 1; i < tour.length; i++) {
        path.lineTo(cityOffsets[tour[i]].dx, cityOffsets[tour[i]].dy);
      }
      path.close();
      canvas.drawPath(path, iterPaint);
    }

    // 4. Draw Global Best Route (Thick Glowing Gold line with pulse)
    if (globalBestRoute != null) {
      final glowPaint = Paint()
        ..color = AppColors.gold.withValues(alpha: 0.35)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final bestPaint = Paint()
        ..color = AppColors.gold
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final tour = globalBestRoute!.cityIndices;
      final path = Path()..moveTo(cityOffsets[tour.first].dx, cityOffsets[tour.first].dy);
      for (int i = 1; i < tour.length; i++) {
        path.lineTo(cityOffsets[tour[i]].dx, cityOffsets[tour[i]].dy);
      }
      path.close();

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, bestPaint);
    }

    // 5. Draw City Nodes & Labels
    for (int i = 0; i < cities.length; i++) {
      final pos = cityOffsets[i];
      final city = cities[i];

      // Outer glow
      canvas.drawCircle(
        pos,
        14,
        Paint()..color = (isDark ? AppColors.blue : AppColors.primaryNavy).withValues(alpha: 0.2),
      );

      // Node circle
      canvas.drawCircle(
        pos,
        8,
        Paint()..color = isDark ? const Color(0xFF1E3A60) : Colors.white,
      );
      canvas.drawCircle(
        pos,
        6,
        Paint()..color = isDark ? AppColors.gold : AppColors.primaryNavy,
      );

      // City Name Badge
      final span = TextSpan(
        text: city.name,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.mainText,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          backgroundColor: isDark ? Colors.black.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.8),
        ),
      );
      final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
      tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy + 12));
    }
  }

  @override
  bool shouldRepaint(covariant _TspPainter oldDelegate) => true;
}
