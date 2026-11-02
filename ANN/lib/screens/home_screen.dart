import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/simulation_service.dart';
import '../services/training_service.dart';
import '../services/settings_service.dart';
import '../widgets/neural_network_painter.dart';
import '../widgets/metric_card.dart';
import '../widgets/quick_action_card.dart';
import '../core/constants/app_colors.dart';
import 'how_ann_works_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsService>();
    final simService = context.watch<SimulationService>();
    final trainService = context.watch<TrainingService>();
    final isDark = settings.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Hero Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryNavy.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.gold),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.science_rounded, color: AppColors.gold, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'RESEARCH LABORATORY',
                            style: TextStyle(
                              color: AppColors.gold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'ANN Intelligence Lab',
                  style: theme.textTheme.displayLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Understand Neurons. Train Networks. Explore Intelligence.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // Animated Neural Network Diagram Preview in Hero
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                  ),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return CustomPaint(
                        size: Size.infinite,
                        painter: NeuralNetworkPainter(
                          network: simService.network,
                          inputs: simService.currentInputs,
                          animationProgress: _pulseController.value,
                          isDarkMode: true,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.play_arrow_rounded),
                      label: const Text('Start Simulation'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        simService.triggerPropagationAnimation();
                      },
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.school_rounded, color: Colors.white),
                      label: const Text('Learn ANN', style: TextStyle(color: Colors.white)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white70),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      ),
                      onPressed: () {
                        // Switch tab or learn screen
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Dashboard Statistics Section
          Text(
            'Laboratory Activity Metrics',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              MetricCard(
                title: 'Networks Trained',
                value: '${trainService.networksTrainedCount}',
                subtitle: trainService.networksTrainedCount == 0 ? 'No runs yet' : 'Total local sessions',
                icon: Icons.hub_rounded,
                iconColor: AppColors.electricBlue,
              ),
              MetricCard(
                title: 'Training Epochs',
                value: '${trainService.totalEpochsTrained}',
                subtitle: trainService.totalEpochsTrained == 0 ? '0 iterations' : 'Epoch iterations',
                icon: Icons.repeat_rounded,
                iconColor: AppColors.gold,
              ),
              MetricCard(
                title: 'Latest Accuracy',
                value: trainService.latestModelAccuracy > 0
                    ? '${trainService.latestModelAccuracy.toStringAsFixed(1)}%'
                    : '--',
                subtitle: trainService.latestModelAccuracy > 0 ? 'Validated score' : 'Train a model to calculate',
                icon: Icons.verified_rounded,
                iconColor: AppColors.accentGreen,
              ),
              MetricCard(
                title: 'Current Architecture',
                value: simService.network.architectureSummary,
                subtitle: '${simService.network.totalParameters} params',
                icon: Icons.account_tree_rounded,
                iconColor: Colors.purpleAccent,
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 3. Quick Actions
          Text(
            'Quick Actions',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              QuickActionCard(
                title: 'Build Neural Net',
                subtitle: 'Customize layers, neurons & activation functions',
                icon: Icons.memory_rounded,
                accentColor: AppColors.electricBlue,
                onTap: () {},
              ),
              QuickActionCard(
                title: 'Train a Model',
                subtitle: 'Execute local backpropagation on dataset',
                icon: Icons.model_training_rounded,
                accentColor: AppColors.gold,
                onTap: () {},
              ),
              QuickActionCard(
                title: 'Run Prediction',
                subtitle: 'Input values & observe forward pass outputs',
                icon: Icons.psychology_rounded,
                accentColor: AppColors.accentGreen,
                onTap: () {},
              ),
              QuickActionCard(
                title: 'Applications',
                subtitle: 'Explore 12 real-world AI industry domains',
                icon: Icons.apps_rounded,
                accentColor: Colors.purpleAccent,
                onTap: () {},
              ),
              QuickActionCard(
                title: 'Learn ANN',
                subtitle: 'Comprehensive 26-topic educational guide',
                icon: Icons.school_rounded,
                accentColor: Colors.orangeAccent,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 28),

          // 4. "How ANN Works Inside This App" Info Banner
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF2A3B5C) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.gold),
                    const SizedBox(width: 10),
                    Text(
                      'How ANN Works Inside This App',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'This application features a fully offline, native Dart Artificial Neural Network engine. Every vector product, weighted sum z = Σ(wᵢxᵢ) + b, activation f(z), loss computation, and backpropagation weight update is calculated locally in real-time without external APIs or hardcoded predictions.',
                  style: TextStyle(
                    height: 1.5,
                    color: isDark ? AppColors.textSubtleDark : AppColors.textSubtleLight,
                  ),
                ),
                const SizedBox(height: 12),
                TextButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  label: const Text('Read Full Technical Architecture'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HowAnnWorksScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
