import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/benchmark_function.dart';
import '../../models/particle_state.dart';

class PsoLandscapeCanvas extends StatelessWidget {
  final BenchmarkType benchmark;
  final List<ParticleState> particles;
  final List<double> globalBestPosition;
  final double globalBestFitness;
  final double minBound;
  final double maxBound;

  const PsoLandscapeCanvas({
    super.key,
    required this.benchmark,
    required this.particles,
    required this.globalBestPosition,
    required this.globalBestFitness,
    required this.minBound,
    required this.maxBound,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A1220) : const Color(0xFFF1F5F9),
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
          painter: _PsoLandscapePainter(
            benchmark: benchmark,
            particles: particles,
            globalBestPosition: globalBestPosition,
            globalBestFitness: globalBestFitness,
            minBound: minBound,
            maxBound: maxBound,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _PsoLandscapePainter extends CustomPainter {
  final BenchmarkType benchmark;
  final List<ParticleState> particles;
  final List<double> globalBestPosition;
  final double globalBestFitness;
  final double minBound;
  final double maxBound;
  final bool isDark;

  _PsoLandscapePainter({
    required this.benchmark,
    required this.particles,
    required this.globalBestPosition,
    required this.globalBestFitness,
    required this.minBound,
    required this.maxBound,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const margin = 28.0;
    final w = size.width - margin * 2;
    final h = size.height - margin * 2;

    Offset mapPoint(double px, double py) {
      final normX = (px - minBound) / (maxBound - minBound);
      final normY = (py - minBound) / (maxBound - minBound);
      // Invert Y so positive Y is up
      return Offset(
        margin + normX.clamp(0.0, 1.0) * w,
        margin + (1.0 - normY.clamp(0.0, 1.0)) * h,
      );
    }

    // 1. Draw Function Contour Grid / Contour Rings
    final contourPaint = Paint()
      ..color = (isDark ? AppColors.blue : AppColors.primaryNavy).withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw coordinate axes through (0, 0)
    final zeroPos = mapPoint(0.0, 0.0);
    final axisPaint = Paint()
      ..color = (isDark ? Colors.white24 : Colors.black12)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(margin, zeroPos.dy), Offset(size.width - margin, zeroPos.dy), axisPaint);
    canvas.drawLine(Offset(zeroPos.dx, margin), Offset(zeroPos.dx, size.height - margin), axisPaint);

    // Draw concentric contour rings for Sphere / Rastrigin landscape visualization
    if (benchmark == BenchmarkType.sphere) {
      for (double r = 1.0; r <= 5.0; r += 1.0) {
        final radiusScreen = (r / (maxBound - minBound)) * w;
        canvas.drawCircle(zeroPos, radiusScreen, contourPaint);
      }
    } else if (benchmark == BenchmarkType.rastrigin) {
      for (double r = 0.5; r <= 5.0; r += 0.8) {
        final radiusScreen = (r / (maxBound - minBound)) * w;
        canvas.drawCircle(zeroPos, radiusScreen, contourPaint);
      }
    } else {
      // Rosenbrock banana contour curve
      final bananaPath = Path();
      bool isFirst = true;
      for (double xVal = minBound; xVal <= maxBound; xVal += 0.2) {
        final yVal = xVal * xVal; // parabola bottom of the valley
        if (yVal <= maxBound) {
          final pt = mapPoint(xVal, yVal);
          if (isFirst) {
            bananaPath.moveTo(pt.dx, pt.dy);
            isFirst = false;
          } else {
            bananaPath.lineTo(pt.dx, pt.dy);
          }
        }
      }
      canvas.drawPath(
        bananaPath,
        Paint()
          ..color = AppColors.gold.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0,
      );
    }

    // 2. Draw Theoretical Optimum Marker (Small target star)
    final optimumPos = mapPoint(benchmark.globalOptimumPos[0], benchmark.globalOptimumPos[1]);
    canvas.drawCircle(
      optimumPos,
      7,
      Paint()
        ..color = AppColors.green.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      optimumPos,
      3,
      Paint()..color = AppColors.green,
    );

    // 3. Draw Personal Best Positions (faint small dots)
    final pbestPaint = Paint()
      ..color = (isDark ? Colors.tealAccent : Colors.teal).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    for (final p in particles) {
      final pb = mapPoint(p.personalBestPosition[0], p.personalBestPosition[1]);
      canvas.drawCircle(pb, 2.0, pbestPaint);
    }

    // 4. Draw Particles and Velocity Vectors
    final particlePaint = Paint()
      ..color = isDark ? AppColors.accentCyan : AppColors.blue
      ..style = PaintingStyle.fill;

    final velocityPaint = Paint()
      ..color = (isDark ? Colors.cyanAccent : Colors.blueAccent).withValues(alpha: 0.5)
      ..strokeWidth = 1.2;

    for (final p in particles) {
      final pos = mapPoint(p.position[0], p.position[1]);

      // Velocity line
      final vx = p.velocity[0];
      final vy = p.velocity[1];
      final vScale = 2.0; // visual multiplier
      final destNormX = ((p.position[0] + vx * vScale) - minBound) / (maxBound - minBound);
      final destNormY = ((p.position[1] + vy * vScale) - minBound) / (maxBound - minBound);
      final vEnd = Offset(
        margin + destNormX * w,
        margin + (1.0 - destNormY) * h,
      );
      canvas.drawLine(pos, vEnd, velocityPaint);

      // Particle body
      canvas.drawCircle(pos, 4.0, particlePaint);
      canvas.drawCircle(pos, 1.5, Paint()..color = Colors.white);
    }

    // 5. Draw Global Best Position (Pulsing Target Ring in Gold)
    final gbestPos = mapPoint(globalBestPosition[0], globalBestPosition[1]);

    // Outer glow ring
    canvas.drawCircle(
      gbestPos,
      12.0,
      Paint()
        ..color = AppColors.gold.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0,
    );

    // Target crosshair
    final crossPaint = Paint()
      ..color = AppColors.gold
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(gbestPos.dx - 8, gbestPos.dy), Offset(gbestPos.dx + 8, gbestPos.dy), crossPaint);
    canvas.drawLine(Offset(gbestPos.dx, gbestPos.dy - 8), Offset(gbestPos.dx, gbestPos.dy + 8), crossPaint);
    canvas.drawCircle(gbestPos, 4.0, Paint()..color = AppColors.gold);

    // Label showing coordinates
    final coordText = 'gbest: (${globalBestPosition[0].toStringAsFixed(3)}, ${globalBestPosition[1].toStringAsFixed(3)})';
    final span = TextSpan(
      text: coordText,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.gold : AppColors.primaryNavy,
        backgroundColor: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.8),
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, Offset(gbestPos.dx - tp.width / 2, gbestPos.dy + 15));
  }

  @override
  bool shouldRepaint(covariant _PsoLandscapePainter oldDelegate) => true;
}
