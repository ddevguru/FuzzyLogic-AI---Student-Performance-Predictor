import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simulation_service.dart';
import '../services/training_service.dart';
import '../widgets/neural_network_painter.dart';
import '../core/constants/app_colors.dart';

class SlideContent {
  final String title;
  final String bulletPoints;
  final IconData icon;

  SlideContent({
    required this.title,
    required this.bulletPoints,
    required this.icon,
  });
}

class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  int _currentStep = 0;

  final List<SlideContent> _slides = [
    SlideContent(
      title: '1. Project Objective & Architecture',
      bulletPoints: '• Fully offline, client-side Dart ANN Engine\n• Teaches forward pass z = ∑(wx) + b & backpropagation\n• No external APIs, hardcoded predictions, or server dependencies',
      icon: Icons.science_rounded,
    ),
    SlideContent(
      title: '2. Neural Architecture & Weights',
      bulletPoints: '• Input Layer (2 nodes), Hidden Layer (4 nodes), Output Layer (1 node)\n• Weights dynamically update during live SGD optimization\n• Green edges indicate positive weights; Red edges indicate negative weights',
      icon: Icons.hub_rounded,
    ),
    SlideContent(
      title: '3. Non-Linear Separation (XOR Problem)',
      bulletPoints: '• Single perceptrons cannot solve non-linearly separable XOR gate\n• Hidden layers introduce non-linear activation boundaries f(z)\n• App proves convergence to 100% accuracy within ~200 epochs',
      icon: Icons.model_training_rounded,
    ),
    SlideContent(
      title: '4. Viva Defense & Mathematical Rigor',
      bulletPoints: '• Forward propagation: a = σ(Wx + b)\n• Loss derivative: ∂L/∂a = (a - y)\n• Gradient updates: w = w - η · (∂L/∂w)',
      icon: Icons.verified_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final simService = context.watch<SimulationService>();
    final trainService = context.watch<TrainingService>();
    final slide = _slides[_currentStep];

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: const Text('ANN Intelligence Lab — Project Presentation & Viva'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold),
            ),
            child: Text(
              'SLIDE ${_currentStep + 1} OF ${_slides.length}',
              style: const TextStyle(color: AppColors.gold, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Slide Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withOpacity(0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(slide.icon, color: AppColors.gold, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        slide.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    slide.bulletPoints,
                    style: const TextStyle(
                      color: AppColors.textSubtleDark,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Network Painter Area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF2A3B5C)),
                ),
                child: CustomPaint(
                  size: Size.infinite,
                  painter: NeuralNetworkPainter(
                    network: simService.network,
                    inputs: simService.currentInputs,
                    isDarkMode: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Live Stats Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildVivaStat('Epochs:', '${trainService.currentEpoch}'),
                  _buildVivaStat('Train Loss:', trainService.currentTrainLoss.toStringAsFixed(4)),
                  _buildVivaStat('Accuracy:', '${trainService.currentTrainAccuracy.toStringAsFixed(1)}%'),
                  _buildVivaStat('Architecture:', simService.network.architectureSummary),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Presentation Slide Controls Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('PREVIOUS STEP'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.surfaceDark),
                  onPressed: _currentStep > 0
                      ? () => setState(() => _currentStep--)
                      : null,
                ),
                OutlinedButton.icon(
                  icon: const Icon(Icons.restart_alt_rounded, color: AppColors.gold),
                  label: const Text('RESTART SLIDES', style: TextStyle(color: AppColors.gold)),
                  onPressed: () => setState(() => _currentStep = 0),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text('NEXT STEP'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricBlue),
                  onPressed: _currentStep < _slides.length - 1
                      ? () => setState(() => _currentStep++)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVivaStat(String label, String val) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'monospace', fontSize: 14)),
      ],
    );
  }
}
