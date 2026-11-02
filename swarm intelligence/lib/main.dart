import 'package:flutter/material.dart';
import 'core/constants/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'screens/advantages_limitations_screen.dart';
import 'screens/algorithms_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/applications_screen.dart';
import 'screens/experiment_screen.dart';
import 'screens/home_screen.dart';
import 'screens/how_it_works_screen.dart';
import 'screens/learn_screen.dart';
import 'screens/presentation_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/simulator_screen.dart';
import 'services/settings_service.dart';
import 'services/simulation_controller.dart';
import 'widgets/common/responsive_scaffold.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SwarmIntelligenceLabApp());
}

class SwarmIntelligenceLabApp extends StatefulWidget {
  const SwarmIntelligenceLabApp({super.key});

  @override
  State<SwarmIntelligenceLabApp> createState() => _SwarmIntelligenceLabAppState();
}

class _SwarmIntelligenceLabAppState extends State<SwarmIntelligenceLabApp> {
  final SettingsService _settingsService = SettingsService();
  final SimulationController _simulationController = SimulationController();

  @override
  void dispose() {
    _settingsService.dispose();
    _simulationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settingsService,
      builder: (context, _) {
        return MaterialApp(
          title: 'Swarm Intelligence Lab',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _settingsService.themeMode,
          home: MainNavigationShell(
            controller: _simulationController,
            settings: _settingsService,
          ),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  final SimulationController controller;
  final SettingsService settings;

  const MainNavigationShell({
    super.key,
    required this.controller,
    required this.settings,
  });

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _openPresentationMode() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PresentationScreen()),
    );
  }

  void _openExperimentMode() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ExperimentScreen()),
    );
  }

  void _openHowItWorks() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const HowItWorksScreen()),
    );
  }

  void _openAdvantagesLimitations() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AdvantagesLimitationsScreen()),
    );
  }

  void _showAboutProjectDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
          title: const Row(
            children: [
              Icon(Icons.school_rounded, color: AppColors.gold, size: 28),
              SizedBox(width: 10),
              Text('Academic Viva Reference', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Swarm Intelligence Lab',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.gold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tagline: "Explore Collective Intelligence. Simulate Swarms. Optimize Solutions."',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
                const Divider(height: 20),
                const Text(
                  'Engineering Project Highlights:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 6),
                const Text('• 100% Offline client-side execution; zero external network dependencies.', style: TextStyle(fontSize: 12)),
                const Text('• Complete implementation of Ant Colony (ACO), Particle Swarm (PSO), and Artificial Bee Colony (ABC) in pure Dart.', style: TextStyle(fontSize: 12)),
                const Text('• Interactive custom CustomPainters for 2D objective functions, pheromone decay heatmaps, and ant circuits.', style: TextStyle(fontSize: 12)),
                const Text('• Real-time convergence curves with touch scrubber tooltips.', style: TextStyle(fontSize: 12)),
                const Text('• 21 theoretical topics covering emergence, decentralization, stigmergy, and comparisons to GAs and ANNs.', style: TextStyle(fontSize: 12)),
                const Text('• 12 comprehensive real-world industrial application case studies.', style: TextStyle(fontSize: 12)),
                const Text('• Dedicated Presentation & Experiment modes designed for viva demonstration.', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Swarm Intelligence Lab';
      case 1:
        return 'Interactive Swarm Simulator';
      case 2:
        return 'Algorithm Specifications & Benchmarks';
      case 3:
        return 'Learn Swarm Intelligence';
      case 4:
        return 'Real-World Applications Explorer';
      case 5:
        return 'Simulation Telemetry & Analytics';
      case 6:
        return 'Laboratory Settings';
      default:
        return 'Swarm Intelligence Lab';
    }
  }

  Widget _getBodyForIndex(int index) {
    switch (index) {
      case 0:
        return HomeScreen(
          controller: widget.controller,
          onNavigateToTab: (tabIndex) => _onDestinationSelected(tabIndex),
          onOpenPresentationMode: _openPresentationMode,
          onOpenExperimentMode: _openExperimentMode,
          onOpenHowItWorks: _openHowItWorks,
        );
      case 1:
        return SimulatorScreen(controller: widget.controller);
      case 2:
        return AlgorithmsScreen(
          onSelectAlgorithmForSimulator: (algo) {
            widget.controller.setAlgorithm(algo);
            _onDestinationSelected(1);
          },
        );
      case 3:
        return const LearnScreen();
      case 4:
        return const ApplicationsScreen();
      case 5:
        return AnalyticsScreen(controller: widget.controller);
      case 6:
        return SettingsScreen(
          settings: widget.settings,
          onOpenAboutProject: _showAboutProjectDialog,
        );
      default:
        return HomeScreen(
          controller: widget.controller,
          onNavigateToTab: (tabIndex) => _onDestinationSelected(tabIndex),
          onOpenPresentationMode: _openPresentationMode,
          onOpenExperimentMode: _openExperimentMode,
          onOpenHowItWorks: _openHowItWorks,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onDestinationSelected,
      title: _getTitleForIndex(_selectedIndex),
      actions: [
        // Quick Action: Advantages & Limitations
        IconButton(
          tooltip: 'Advantages & Limitations',
          icon: const Icon(Icons.balance_rounded),
          onPressed: _openAdvantagesLimitations,
        ),
        // Quick Action: Presentation Mode
        IconButton(
          tooltip: 'Presentation Mode (Viva Demo)',
          icon: const Icon(Icons.co_present_rounded),
          onPressed: _openPresentationMode,
        ),
        // Quick Action: Experiment Mode
        IconButton(
          tooltip: 'Experiment Laboratory',
          icon: const Icon(Icons.science_rounded),
          onPressed: _openExperimentMode,
        ),
        // Theme Quick Toggle
        IconButton(
          tooltip: widget.settings.isDarkMode ? 'Switch to Light Theme' : 'Switch to Dark Theme',
          icon: Icon(widget.settings.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          onPressed: () => widget.settings.toggleTheme(!widget.settings.isDarkMode),
        ),
      ],
      body: _getBodyForIndex(_selectedIndex),
    );
  }
}
