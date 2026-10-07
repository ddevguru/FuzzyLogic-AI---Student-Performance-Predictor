import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ScoreGauge extends StatefulWidget {
  final double score;
  final String level;
  final String risk;

  const ScoreGauge({
    super.key,
    required this.score,
    required this.level,
    required this.risk,
  });

  @override
  State<ScoreGauge> createState() => _ScoreGaugeState();
}

class _ScoreGaugeState extends State<ScoreGauge> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animation = Tween<double>(begin: 0, end: widget.score).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(ScoreGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.score != widget.score) {
      _animation = Tween<double>(begin: 0, end: widget.score).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final levelColor = AppTheme.getLevelColor(widget.level);
    final riskColor = AppTheme.getRiskColor(widget.risk);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentVal = _animation.value;
        return Column(
          children: [
            SizedBox(
              width: 220,
              height: 220,
              child: CustomPaint(
                painter: _GaugePainter(
                  value: currentVal,
                  color: levelColor,
                  backgroundColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white12
                      : Colors.black.withOpacity(0.08),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currentVal.toStringAsFixed(1),
                        style: GoogleFonts.outfit(
                          fontSize: 46,
                          fontWeight: FontWeight.bold,
                          color: levelColor,
                        ),
                      ),
                      const Text(
                        'PERFORMANCE SCORE',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: levelColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: levelColor, width: 1.5),
                        ),
                        child: Text(
                          widget.level.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: levelColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: riskColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: riskColor.withOpacity(0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_outlined, color: riskColor, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'ACADEMIC RISK: ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  Text(
                    widget.risk.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  final Color backgroundColor;

  _GaugePainter({
    required this.value,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 12;
    const strokeWidth = 16.0;

    const startAngle = 135 * (math.pi / 180);
    const sweepAngle = 270 * (math.pi / 180);

    // Background Arc
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      bgPaint,
    );

    // Foreground Value Arc
    final currentSweep = (value / 100) * sweepAngle;
    final fgPaint = Paint()
      ..shader = LinearGradient(
        colors: [color.withOpacity(0.7), color],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      currentSweep,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
