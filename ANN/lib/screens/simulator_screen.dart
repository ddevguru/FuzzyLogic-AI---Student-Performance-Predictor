import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simulation_service.dart';
import '../services/settings_service.dart';
import '../widgets/neural_network_painter.dart';
import '../widgets/neuron_details_card.dart';
import '../widgets/parameter_controls.dart';
import '../core/constants/app_colors.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _triggerPulse() {
    _pulseController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final simService = context.watch<SimulationService>();
    final settings = context.watch<SettingsService>();
    final isDark = settings.isDarkMode;

    final selectedNeuron = simService.selectedNeuron;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Interactive ANN Simulator',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap any neuron to inspect weights, bias & equation',
                    style: TextStyle(
                      color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.bolt_rounded),
                label: const Text('PROPAGATE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricBlue,
                ),
                onPressed: () {
                  _triggerPulse();
                  simService.runForwardPropagation();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Interactive CustomPainter Visualizer Box
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: GestureDetector(
              onTapUp: (details) {
                _handleNodeTap(details.localPosition, context);
              },
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size.infinite,
                    painter: NeuralNetworkPainter(
                      network: simService.network,
                      inputs: simService.currentInputs,
                      selectedLayerIndex: simService.selectedLayerIndex,
                      selectedNeuronIndex: simService.selectedNeuronIndex,
                      animationProgress: _pulseController.value,
                      isDarkMode: isDark,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Selected Neuron Detail Panel Overlay
          if (selectedNeuron != null) ...[
            NeuronDetailsCard(
              layerIndex: simService.selectedLayerIndex!,
              neuronIndex: simService.selectedNeuronIndex!,
              neuron: selectedNeuron,
              activationType: simService.selectedLayerIndex == simService.network.layers.length
                  ? simService.outputActivation
                  : simService.hiddenActivation,
              onClose: () => simService.selectNeuron(null, null),
            ),
            const SizedBox(height: 16),
          ],

          // Interactive Input Controllers
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Input Signals (xᵢ)',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...List.generate(simService.currentInputs.length, (idx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Text(
                          'Input x${idx + 1}:',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        Expanded(
                          child: Slider(
                            value: simService.currentInputs[idx],
                            min: -2.0,
                            max: 2.0,
                            divisions: 40,
                            activeColor: AppColors.electricBlue,
                            onChanged: (val) {
                              simService.setSingleInput(idx, val);
                              _triggerPulse();
                            },
                          ),
                        ),
                        Text(
                          simService.currentInputs[idx].toStringAsFixed(2),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Parameter Controls Form
          ParameterControls(
            learningRate: settings.defaultLearningRate,
            epochs: settings.defaultEpochs,
            hiddenLayers: simService.numHiddenLayers,
            neuronsPerHidden: simService.numNeuronsPerHidden,
            activationType: simService.hiddenActivation,
            selectedDataset: simService.selectedDataset,
            onHiddenLayersChanged: (v) => simService.updateArchitecture(hiddenLayers: v),
            onNeuronsChanged: (v) => simService.updateArchitecture(neuronsPerHidden: v),
            onActivationChanged: (v) => simService.updateArchitecture(hiddenActivation: v),
            onDatasetChanged: (ds) => simService.setDataset(ds),
          ),
        ],
      ),
    );
  }

  void _handleNodeTap(Offset tapPos, BuildContext context) {
    final simService = context.read<SimulationService>();
    final size = Size(MediaQuery.of(context).size.width - 40, 320);
    final positions = NeuralNetworkPainter.calculateNodePositions(simService.network, size);

    String? matchedKey;
    double minDistance = 30.0; // Hit test radius

    positions.forEach((key, pos) {
      final dist = (pos - tapPos).distance;
      if (dist < minDistance) {
        minDistance = dist;
        matchedKey = key;
      }
    });

    if (matchedKey != null) {
      final parts = matchedKey!.split('_');
      final lIdx = int.parse(parts[0]);
      final nIdx = int.parse(parts[1]);
      simService.selectNeuron(lIdx, nIdx);
    } else {
      simService.selectNeuron(null, null);
    }
  }
}
