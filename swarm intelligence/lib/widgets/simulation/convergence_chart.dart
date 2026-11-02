import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/simulation_metric_point.dart';

class ConvergenceChart extends StatefulWidget {
  final List<SimulationMetricPoint> history;
  final String title;
  final String yAxisLabel;
  final Color primaryLineColor;
  final Color secondaryLineColor;
  final bool showAverage;

  const ConvergenceChart({
    super.key,
    required this.history,
    this.title = 'Convergence Curve (Fitness vs Iteration)',
    this.yAxisLabel = 'Objective Value (Lower is Better)',
    this.primaryLineColor = AppColors.gold,
    this.secondaryLineColor = AppColors.blue,
    this.showAverage = true,
  });

  @override
  State<ConvergenceChart> createState() => _ConvergenceChartState();
}

class _ConvergenceChartState extends State<ConvergenceChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.history.isEmpty) {
      return Container(
        height: 220,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.show_chart_rounded, size: 40, color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight),
            const SizedBox(height: 8),
            Text(
              'No convergence data yet. Start simulation to observe curve.',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 240,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              Row(
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: widget.primaryLineColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  const Text('Best', style: TextStyle(fontSize: 11)),
                  if (widget.showAverage) ...[
                    const SizedBox(width: 12),
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: widget.secondaryLineColor, shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    const Text('Average', style: TextStyle(fontSize: 11)),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: GestureDetector(
              onPanUpdate: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localX = details.localPosition.dx;
                final ratio = (localX / box.size.width).clamp(0.0, 1.0);
                final index = (ratio * (widget.history.length - 1)).round();
                setState(() {
                  touchedIndex = index.clamp(0, widget.history.length - 1);
                });
              },
              onPanEnd: (_) => setState(() => touchedIndex = null),
              onTapDown: (details) {
                final RenderBox box = context.findRenderObject() as RenderBox;
                final localX = details.localPosition.dx;
                final ratio = (localX / box.size.width).clamp(0.0, 1.0);
                final index = (ratio * (widget.history.length - 1)).round();
                setState(() {
                  touchedIndex = index.clamp(0, widget.history.length - 1);
                });
              },
              child: CustomPaint(
                size: Size.infinite,
                painter: _ChartPainter(
                  history: widget.history,
                  isDark: isDark,
                  primaryColor: widget.primaryLineColor,
                  secondaryColor: widget.secondaryLineColor,
                  showAverage: widget.showAverage,
                  touchedIndex: touchedIndex,
                ),
              ),
            ),
          ),
          if (touchedIndex != null && touchedIndex! < widget.history.length)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Iter ${widget.history[touchedIndex!].iteration}: Best = ${Formatters.formatFitness(widget.history[touchedIndex!].bestObjective)}, Avg = ${Formatters.formatFitness(widget.history[touchedIndex!].averageObjective)}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.primaryLineColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<SimulationMetricPoint> history;
  final bool isDark;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showAverage;
  final int? touchedIndex;

  _ChartPainter({
    required this.history,
    required this.isDark,
    required this.primaryColor,
    required this.secondaryColor,
    required this.showAverage,
    this.touchedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (history.isEmpty) return;

    const leftPadding = 40.0;
    const bottomPadding = 20.0;
    final chartWidth = size.width - leftPadding;
    final chartHeight = size.height - bottomPadding;

    // Determine min and max
    double minVal = double.infinity;
    double maxVal = double.negativeInfinity;

    for (final p in history) {
      if (!p.bestObjective.isNaN && !p.bestObjective.isInfinite) {
        minVal = min(minVal, p.bestObjective);
        maxVal = max(maxVal, p.bestObjective);
      }
      if (showAverage && !p.averageObjective.isNaN && !p.averageObjective.isInfinite) {
        minVal = min(minVal, p.averageObjective);
        maxVal = max(maxVal, p.averageObjective);
      }
    }

    if (minVal.isInfinite || maxVal == double.negativeInfinity) {
      minVal = 0.0;
      maxVal = 1.0;
    }
    if ((maxVal - minVal).abs() < 0.0001) {
      maxVal = minVal + 1.0;
    }

    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF1F3252) : const Color(0xFFE2E8F0)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight,
      fontSize: 9,
    );

    // Draw horizontal grid lines (3 levels)
    for (int i = 0; i <= 3; i++) {
      final y = chartHeight - (i / 3.0) * chartHeight;
      canvas.drawLine(Offset(leftPadding, y), Offset(size.width, y), gridPaint);
      final val = minVal + (i / 3.0) * (maxVal - minVal);
      final textSpan = TextSpan(text: Formatters.formatFitness(val, decimals: 2), style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(2, y - 6));
    }

    // Coordinates mapping
    double getX(int index) {
      if (history.length <= 1) return leftPadding;
      return leftPadding + (index / (history.length - 1)) * chartWidth;
    }

    double getY(double val) {
      final ratio = (val - minVal) / (maxVal - minVal);
      return chartHeight - (ratio.clamp(0.0, 1.0) * chartHeight);
    }

    // 1. Draw Average Line (dashed or thinner)
    if (showAverage) {
      final avgPaint = Paint()
        ..color = secondaryColor.withValues(alpha: 0.6)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;

      final avgPath = Path();
      for (int i = 0; i < history.length; i++) {
        final x = getX(i);
        final y = getY(history[i].averageObjective);
        if (i == 0) {
          avgPath.moveTo(x, y);
        } else {
          avgPath.lineTo(x, y);
        }
      }
      canvas.drawPath(avgPath, avgPaint);
    }

    // 2. Draw Best Line (thick glowing curve)
    final bestPaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final bestPath = Path();
    for (int i = 0; i < history.length; i++) {
      final x = getX(i);
      final y = getY(history[i].bestObjective);
      if (i == 0) {
        bestPath.moveTo(x, y);
      } else {
        bestPath.lineTo(x, y);
      }
    }
    canvas.drawPath(bestPath, bestPaint);

    // 3. Touched cursor line
    if (touchedIndex != null && touchedIndex! < history.length) {
      final tx = getX(touchedIndex!);
      final cursorPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.4)
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(tx, 0), Offset(tx, chartHeight), cursorPaint);

      final ty = getY(history[touchedIndex!].bestObjective);
      canvas.drawCircle(Offset(tx, ty), 4, Paint()..color = primaryColor);
      canvas.drawCircle(Offset(tx, ty), 2, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _ChartPainter oldDelegate) => true;
}
