import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../problems/tsp_problem.dart';

class TSPCanvasVisualizer extends StatelessWidget {
  final List<int> cityOrder;

  const TSPCanvasVisualizer({
    super.key,
    required this.cityOrder,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 240,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _TSPPainter(
            cityOrder: cityOrder,
            cities: TSPProblem.cities,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _TSPPainter extends CustomPainter {
  final List<int> cityOrder;
  final List<City> cities;
  final bool isDark;

  _TSPPainter({
    required this.cityOrder,
    required this.cities,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double pad = 30.0;
    final double drawW = size.width - (pad * 2);
    final double drawH = size.height - (pad * 2);

    Offset getCityOffset(City c) {
      double px = pad + (c.x / 100.0) * drawW;
      double py = pad + (c.y / 100.0) * drawH;
      return Offset(px, py);
    }

    // Grid lines background
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white10 : Colors.black.withOpacity(0.04))
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw route lines
    if (cityOrder.isNotEmpty) {
      final routePaint = Paint()
        ..color = AppColors.gold
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final glowPaint = Paint()
        ..color = AppColors.gold.withOpacity(0.3)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      Path path = Path();
      Offset start = getCityOffset(cities[cityOrder.first]);
      path.moveTo(start.dx, start.dy);

      for (int i = 1; i < cityOrder.length; i++) {
        Offset pt = getCityOffset(cities[cityOrder[i]]);
        path.lineTo(pt.dx, pt.dy);
      }
      path.close();

      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, routePaint);
    }

    // Draw City Nodes
    for (int i = 0; i < cities.length; i++) {
      final city = cities[i];
      final pos = getCityOffset(city);

      bool isStartCity = cityOrder.isNotEmpty && cityOrder.first == city.id;

      canvas.drawCircle(
        pos,
        10,
        Paint()..color = (isStartCity ? AppColors.gold : AppColors.blue).withOpacity(0.3),
      );

      canvas.drawCircle(
        pos,
        6,
        Paint()..color = isStartCity ? AppColors.gold : AppColors.blue,
      );

      canvas.drawCircle(
        pos,
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      final textSpan = TextSpan(
        text: city.name,
        style: TextStyle(
          color: isDark ? Colors.white : AppColors.navy,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(pos.dx - (textPainter.width / 2), pos.dy + 8),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TSPPainter oldDelegate) {
    return oldDelegate.cityOrder != cityOrder || oldDelegate.isDark != isDark;
  }
}
