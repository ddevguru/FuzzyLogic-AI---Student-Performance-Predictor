import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/benchmark_function.dart';
import '../../models/food_source_state.dart';

class AbcLandscapeCanvas extends StatelessWidget {
  final BenchmarkType benchmark;
  final List<FoodSourceState> foodSources;
  final FoodSourceState? bestFoodSource;
  final int abandonmentLimit;
  final int recentScoutReplacements;
  final double minBound;
  final double maxBound;

  const AbcLandscapeCanvas({
    super.key,
    required this.benchmark,
    required this.foodSources,
    required this.bestFoodSource,
    required this.abandonmentLimit,
    required this.recentScoutReplacements,
    required this.minBound,
    required this.maxBound,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1628) : const Color(0xFFF1F5F9),
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
          painter: _AbcLandscapePainter(
            benchmark: benchmark,
            foodSources: foodSources,
            bestFoodSource: bestFoodSource,
            abandonmentLimit: abandonmentLimit,
            recentScoutReplacements: recentScoutReplacements,
            minBound: minBound,
            maxBound: maxBound,
            isDark: isDark,
          ),
        ),
      ),
    );
  }
}

class _AbcLandscapePainter extends CustomPainter {
  final BenchmarkType benchmark;
  final List<FoodSourceState> foodSources;
  final FoodSourceState? bestFoodSource;
  final int abandonmentLimit;
  final int recentScoutReplacements;
  final double minBound;
  final double maxBound;
  final bool isDark;

  _AbcLandscapePainter({
    required this.benchmark,
    required this.foodSources,
    required this.bestFoodSource,
    required this.abandonmentLimit,
    required this.recentScoutReplacements,
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
      return Offset(
        margin + normX.clamp(0.0, 1.0) * w,
        margin + (1.0 - normY.clamp(0.0, 1.0)) * h,
      );
    }

    // 1. Draw Axis & Landscape Grid
    final zeroPos = mapPoint(0.0, 0.0);
    final axisPaint = Paint()
      ..color = (isDark ? Colors.white24 : Colors.black12)
      ..strokeWidth = 1.2;
    canvas.drawLine(Offset(margin, zeroPos.dy), Offset(size.width - margin, zeroPos.dy), axisPaint);
    canvas.drawLine(Offset(zeroPos.dx, margin), Offset(zeroPos.dx, size.height - margin), axisPaint);

    // 2. Draw Theoretical Optimum
    final optPos = mapPoint(benchmark.globalOptimumPos[0], benchmark.globalOptimumPos[1]);
    canvas.drawCircle(optPos, 6, Paint()..color = AppColors.green.withValues(alpha: 0.3));
    canvas.drawCircle(optPos, 3, Paint()..color = AppColors.green);

    // 3. Draw Food Sources (Honeycombs / Circles sized by fitness)
    double maxFit = 0.0001;
    for (final s in foodSources) {
      if (s.fitness > maxFit) maxFit = s.fitness;
    }

    for (final s in foodSources) {
      final pos = mapPoint(s.position[0], s.position[1]);
      final fitRatio = (s.fitness / maxFit).clamp(0.2, 1.0);
      final radius = 4.0 + fitRatio * 5.0;

      // Abandonment risk color indicator (if trials high, turn orange/red)
      final trialRatio = (s.trial / abandonmentLimit).clamp(0.0, 1.0);
      final Color sourceColor = Color.lerp(AppColors.green, Colors.orangeAccent, trialRatio)!;

      // Draw Honeycomb / hexagonal ring
      canvas.drawCircle(
        pos,
        radius,
        Paint()
          ..color = sourceColor.withValues(alpha: 0.8)
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        pos,
        radius,
        Paint()
          ..color = Colors.white70
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0,
      );

      // Label trial count if high
      if (s.trial > 2) {
        final tp = TextPainter(
          text: TextSpan(
            text: '${s.trial}/$abandonmentLimit',
            style: const TextStyle(fontSize: 8, color: Colors.orangeAccent, fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - radius - 10));
      }
    }

    // 4. Highlight Best Food Source in Gold
    if (bestFoodSource != null) {
      final bPos = mapPoint(bestFoodSource!.position[0], bestFoodSource!.position[1]);

      canvas.drawCircle(
        bPos,
        14.0,
        Paint()
          ..color = AppColors.gold.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0,
      );

      canvas.drawCircle(bPos, 5.0, Paint()..color = AppColors.gold);

      final label = 'Best Source: f = ${bestFoodSource!.objectiveValue.toStringAsFixed(4)}';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.gold : AppColors.primaryNavy,
            backgroundColor: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.8),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(bPos.dx - tp.width / 2, bPos.dy + 16));
    }

    // 5. Scout Bee Pulse Indicator if any replacements occurred
    if (recentScoutReplacements > 0) {
      final scoutText = '⚡ Scout Bees Replaced: $recentScoutReplacements';
      final tp = TextPainter(
        text: TextSpan(
          text: scoutText,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.amberAccent,
            backgroundColor: Colors.black54,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, const Offset(margin, margin));
    }
  }

  @override
  bool shouldRepaint(covariant _AbcLandscapePainter oldDelegate) => true;
}
