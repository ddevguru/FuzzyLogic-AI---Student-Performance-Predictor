import 'package:flutter/material.dart';
import '../models/neural_network.dart';
import '../models/training_sample.dart';
import '../core/constants/app_colors.dart';

class DecisionBoundaryVisualizer extends StatelessWidget {
  final NeuralNetwork network;
  final List<TrainingSample> samples;

  const DecisionBoundaryVisualizer({
    super.key,
    required this.network,
    required this.samples,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueGrey.withOpacity(0.3)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CustomPaint(
          painter: _DecisionBoundaryPainter(
            network: network,
            samples: samples,
          ),
        ),
      ),
    );
  }
}

class _DecisionBoundaryPainter extends CustomPainter {
  final NeuralNetwork network;
  final List<TrainingSample> samples;

  _DecisionBoundaryPainter({
    required this.network,
    required this.samples,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const resolution = 30; // Grid resolution for heatmap
    final cellWidth = size.width / resolution;
    final cellHeight = size.height / resolution;

    // 1. Draw Decision Heatmap Grid
    for (int ix = 0; ix < resolution; ix++) {
      final xVal = -1.0 + (ix / resolution) * 2.0;
      for (int iy = 0; iy < resolution; iy++) {
        // Map Y canvas down to Cartesian [-1, 1]
        final yVal = 1.0 - (iy / resolution) * 2.0;

        List<double> input = [xVal, yVal];
        // Ensure input dimensions match network
        if (input.length > network.numInputs) {
          input = input.sublist(0, network.numInputs);
        } else if (input.length < network.numInputs) {
          input = List.generate(network.numInputs, (i) => i < 2 ? input[i] : 0.0);
        }

        final out = network.forward(input);
        final prob = out[0].clamp(0.0, 1.0);

        // Interpolate color between Class 0 (Blue) and Class 1 (Green/Gold)
        final cellColor = Color.lerp(
          AppColors.electricBlue.withOpacity(0.4),
          AppColors.accentGreen.withOpacity(0.4),
          prob,
        )!;

        final rect = Rect.fromLTWH(
          ix * cellWidth,
          iy * cellHeight,
          cellWidth + 0.5,
          cellHeight + 0.5,
        );
        canvas.drawRect(rect, Paint()..color = cellColor);
      }
    }

    // 2. Draw Data Points Overlaid
    for (var sample in samples) {
      if (sample.inputs.length < 2) continue;
      final x1 = sample.inputs[0];
      final x2 = sample.inputs[1];

      // Convert Cartesian [-1, 1] to Canvas Coordinates
      final cx = ((x1 + 1.0) / 2.0) * size.width;
      final cy = ((1.0 - x2) / 2.0) * size.height;

      final isClass1 = sample.targets[0] >= 0.5;
      final pointColor = isClass1 ? AppColors.gold : Colors.white;

      // Draw shadow glow
      canvas.drawCircle(
        Offset(cx, cy),
        7.0,
        Paint()..color = Colors.black.withOpacity(0.5),
      );

      // Draw point
      canvas.drawCircle(
        Offset(cx, cy),
        5.0,
        Paint()..color = pointColor,
      );

      canvas.drawCircle(
        Offset(cx, cy),
        5.0,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DecisionBoundaryPainter oldDelegate) => true;
}
