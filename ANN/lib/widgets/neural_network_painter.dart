import 'package:flutter/material.dart';
import '../models/neural_network.dart';
import '../core/constants/app_colors.dart';

class NeuralNetworkPainter extends CustomPainter {
  final NeuralNetwork network;
  final List<double> inputs;
  final int? selectedLayerIndex;
  final int? selectedNeuronIndex;
  final double animationProgress; // 0.0 to 1.0 for propagation pulse
  final bool isDarkMode;

  NeuralNetworkPainter({
    required this.network,
    required this.inputs,
    this.selectedLayerIndex,
    this.selectedNeuronIndex,
    this.animationProgress = 0.0,
    this.isDarkMode = true,
  });

  // Calculate layer node positions map for hit testing and drawing
  static Map<String, Offset> calculateNodePositions(NeuralNetwork net, Size size) {
    final positions = <String, Offset>{};
    final totalLayers = net.layers.length + 1; // +1 for Input Layer
    final layerSpacing = size.width / (totalLayers + 1);

    // 1. Input Layer Nodes (Layer 0)
    final inputCount = net.numInputs;
    final inputSpacing = size.height / (inputCount + 1);
    for (int i = 0; i < inputCount; i++) {
      final x = layerSpacing;
      final y = inputSpacing * (i + 1);
      positions['0_$i'] = Offset(x, y);
    }

    // 2. Hidden & Output Layers (Layers 1..N)
    for (int l = 0; l < net.layers.length; l++) {
      final layer = net.layers[l];
      final nodeCount = layer.numNeurons;
      final nodeSpacing = size.height / (nodeCount + 1);
      final x = layerSpacing * (l + 2);

      for (int n = 0; n < nodeCount; n++) {
        final y = nodeSpacing * (n + 1);
        positions['${l + 1}_$n'] = Offset(x, y);
      }
    }
    return positions;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final nodePositions = calculateNodePositions(network, size);

    // 1. Draw Weight Connections
    for (int l = 0; l < network.layers.length; l++) {
      final layer = network.layers[l];
      final prevLayerIdx = l;
      final currLayerIdx = l + 1;

      for (int n = 0; n < layer.neurons.length; n++) {
        final neuron = layer.neurons[n];
        final destPos = nodePositions['${currLayerIdx}_$n'];
        if (destPos == null) continue;

        for (int w = 0; w < neuron.weights.length; w++) {
          final srcPos = nodePositions['${prevLayerIdx}_$w'];
          if (srcPos == null) continue;

          final weightVal = neuron.weights[w];
          final absWeight = weightVal.abs();

          // Connection thickness proportional to weight magnitude
          final strokeWidth = (absWeight * 2.5).clamp(1.0, 6.0);
          final color = weightVal >= 0
              ? AppColors.weightPositive.withOpacity((absWeight * 0.7 + 0.3).clamp(0.2, 0.9))
              : AppColors.weightNegative.withOpacity((absWeight * 0.7 + 0.3).clamp(0.2, 0.9));

          final edgePaint = Paint()
            ..color = color
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke;

          canvas.drawLine(srcPos, destPos, edgePaint);

          // Animated Forward Signal Propagation Pulse
          if (animationProgress > 0.0 && animationProgress < 1.0) {
            final pulsePos = Offset.lerp(srcPos, destPos, animationProgress);
            if (pulsePos != null) {
              final pulsePaint = Paint()
                ..color = AppColors.activePulse
                ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4.0);
              canvas.drawCircle(pulsePos, 4.0, pulsePaint);
            }
          }
        }
      }
    }

    // 2. Draw Layer Labels
    final labelStyle = TextStyle(
      color: isDarkMode ? AppColors.textSubtleDark : AppColors.textSubtleLight,
      fontSize: 12,
      fontWeight: FontWeight.bold,
    );

    final totalLayers = network.layers.length + 1;
    final layerSpacing = size.width / (totalLayers + 1);

    // Input label
    _drawText(canvas, "INPUT", Offset(layerSpacing, 15), labelStyle);

    // Hidden & Output labels
    for (int l = 0; l < network.layers.length; l++) {
      final isOutput = l == network.layers.length - 1;
      final labelText = isOutput ? "OUTPUT" : "HIDDEN ${l + 1}";
      final x = layerSpacing * (l + 2);
      _drawText(canvas, labelText, Offset(x, 15), labelStyle);
    }

    // 3. Draw Neurons (Nodes)
    nodePositions.forEach((key, pos) {
      final parts = key.split('_');
      final layerIdx = int.parse(parts[0]);
      final neuronIdx = int.parse(parts[1]);

      final isSelected = selectedLayerIndex == layerIdx && selectedNeuronIndex == neuronIdx;

      Color baseColor;
      double activation = 0.0;

      if (layerIdx == 0) {
        baseColor = AppColors.inputNeuron;
        activation = neuronIdx < inputs.length ? inputs[neuronIdx] : 0.0;
      } else if (layerIdx == network.layers.length) {
        baseColor = AppColors.outputNeuron;
        activation = network.layers.last.neurons[neuronIdx].output;
      } else {
        baseColor = AppColors.hiddenNeuron;
        activation = network.layers[layerIdx - 1].neurons[neuronIdx].output;
      }

      // Neuron Glow & Fill
      final glowPaint = Paint()
        ..color = isSelected
            ? AppColors.gold
            : baseColor.withOpacity((activation.abs().clamp(0.2, 1.0)))
        ..style = PaintingStyle.fill;

      final radius = isSelected ? 22.0 : 18.0;

      // Draw subtle drop shadow / halo
      if (activation > 0.3 || isSelected) {
        canvas.drawCircle(
          pos,
          radius + 4,
          Paint()
            ..color = baseColor.withOpacity(0.4)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0),
        );
      }

      // Draw node body
      canvas.drawCircle(pos, radius, glowPaint);

      // Node border
      final borderPaint = Paint()
        ..color = isSelected ? AppColors.gold : Colors.white
        ..strokeWidth = isSelected ? 3.0 : 2.0
        ..style = PaintingStyle.stroke;

      canvas.drawCircle(pos, radius, borderPaint);

      // Draw activation value inside node
      final valStr = activation.toStringAsFixed(2);
      final textStyle = TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
      );
      _drawText(canvas, valStr, pos, textStyle);
    });
  }

  void _drawText(Canvas canvas, String text, Offset centerPos, TextStyle style) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        centerPos.dx - textPainter.width / 2,
        centerPos.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant NeuralNetworkPainter oldDelegate) {
    return true;
  }
}
