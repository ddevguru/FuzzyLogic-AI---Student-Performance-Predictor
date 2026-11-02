import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simulation_service.dart';
import '../services/training_service.dart';
import '../datasets/xor_dataset.dart';
import '../core/constants/app_colors.dart';

class DemoScreen extends StatefulWidget {
  const DemoScreen({super.key});

  @override
  State<DemoScreen> createState() => _DemoScreenState();
}

class _DemoScreenState extends State<DemoScreen> {
  int _demoStep = 0;

  final List<String> _stepTitles = [
    'Step 1: Network Initialization',
    'Step 2: Load Benchmark Dataset (XOR)',
    'Step 3: Forward Pass Signal Propagation',
    'Step 4: Compute Initial Error & Loss',
    'Step 5: Backpropagation Gradient Calculation',
    'Step 6: Update Weights & Biases (SGD)',
    'Step 7: Train Across Epoch Iterations',
    'Step 8: Model Evaluation & Predictions',
  ];

  final List<String> _stepDescriptions = [
    'Creating dense layers with 2 Input Neurons, 4 Hidden Neurons, and 1 Output Neuron with random Xavier weight initialization.',
    'Loading XOR Logic dataset. XOR is non-linearly separable, demonstrating why hidden layers are required.',
    'Passing input vector [1.0, 0.0] forward through neurons computing z = ∑(wx) + b and a = Sigmoid(z).',
    'Comparing prediction ŷ against target target y = 1.0 using Mean Squared Error (MSE).',
    'Propagating loss gradient ∂L/∂a backwards to derive layer deltas δ = ∂L/∂z.',
    'Executing SGD parameter update: w_new = w_old - η · dW and b_new = b_old - η · dB.',
    'Looping backpropagation across 300 epochs to minimize total dataset loss.',
    'Validating final predictions on unseen inputs with 100% decision accuracy.',
  ];

  void _executeDemoStep(int step) {
    final simService = context.read<SimulationService>();
    final trainService = context.read<TrainingService>();

    if (step == 1) {
      simService.setDataset(XorDataset());
    } else if (step == 2) {
      simService.updateInputValues([1.0, 0.0]);
      simService.triggerPropagationAnimation();
    } else if (step == 6) {
      trainService.startTraining(simService.network);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simService = context.watch<SimulationService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Guided Interactive Tour'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tour Progress Indicator
            LinearProgressIndicator(
              value: (_demoStep + 1) / _stepTitles.length,
              backgroundColor: Colors.grey.shade800,
              color: AppColors.gold,
              minHeight: 8,
            ),
            const SizedBox(height: 20),

            // Step Content Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.electricBlue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _stepTitles[_demoStep],
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _stepDescriptions[_demoStep],
                    style: const TextStyle(
                      color: AppColors.textMainDark,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Interactive Action Center
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.memory_rounded, size: 60, color: AppColors.electricBlue),
                    const SizedBox(height: 16),
                    Text(
                      'Current Architecture: ${simService.network.architectureSummary}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Input: ${simService.currentInputs} → Output: ${simService.currentOutputs.map((o) => o.toStringAsFixed(4)).toList()}',
                      style: const TextStyle(fontFamily: 'monospace', color: AppColors.gold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Navigation Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('BACK'),
                  onPressed: _demoStep > 0
                      ? () {
                          setState(() {
                            _demoStep--;
                            _executeDemoStep(_demoStep);
                          });
                        }
                      : null,
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('NEXT STEP'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricBlue),
                  onPressed: _demoStep < _stepTitles.length - 1
                      ? () {
                          setState(() {
                            _demoStep++;
                            _executeDemoStep(_demoStep);
                          });
                        }
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
