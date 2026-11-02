import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'simulator_screen.dart';
import 'training_screen.dart';
import 'prediction_screen.dart';
import 'applications_screen.dart';
import 'learn_screen.dart';
import 'analytics_screen.dart';
import 'settings_screen.dart';
import 'presentation_screen.dart';
import 'demo_screen.dart';
import 'how_ann_works_screen.dart';
import '../services/settings_service.dart';
import '../core/constants/app_colors.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SimulatorScreen(),
    TrainingScreen(),
    PredictionScreen(),
    ApplicationsScreen(),
    LearnScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = const [
    'ANN Intelligence Lab',
    'ANN Simulator',
    'Train a Network',
    'Prediction Playground',
    'ANN Applications',
    'Learn ANN',
    'Analytics & Experiments',
    'Settings & About',
  ];

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width >= 900;
    final settings = context.watch<SettingsService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Presentation Mode (Viva)',
            icon: const Icon(Icons.slideshow_rounded, color: AppColors.gold),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PresentationScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Guided Demo Tour',
            icon: const Icon(Icons.explore_rounded, color: AppColors.electricBlue),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DemoScreen()),
              );
            },
          ),
          IconButton(
            tooltip: 'Toggle Theme',
            icon: Icon(
              settings.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => settings.toggleTheme(),
          ),
        ],
      ),
      body: isDesktop
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _navigateTo,
                  labelType: NavigationRailLabelType.selected,
                  backgroundColor: settings.isDarkMode ? AppColors.surfaceDark : Colors.white,
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.dashboard_rounded), label: Text('Home')),
                    NavigationRailDestination(icon: Icon(Icons.memory_rounded), label: Text('Simulator')),
                    NavigationRailDestination(icon: Icon(Icons.model_training_rounded), label: Text('Train')),
                    NavigationRailDestination(icon: Icon(Icons.psychology_rounded), label: Text('Predict')),
                    NavigationRailDestination(icon: Icon(Icons.apps_rounded), label: Text('Apps')),
                    NavigationRailDestination(icon: Icon(Icons.school_rounded), label: Text('Learn')),
                    NavigationRailDestination(icon: Icon(Icons.bar_chart_rounded), label: Text('Analytics')),
                    NavigationRailDestination(icon: Icon(Icons.settings_rounded), label: Text('Settings')),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _screens[_currentIndex]),
              ],
            )
          : _screens[_currentIndex],
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _currentIndex > 4 ? 4 : _currentIndex,
              onDestinationSelected: (index) {
                if (index == 4) {
                  // Show bottom sheet for extra screens (Learn, Analytics, Settings)
                  _showMoreMenu(context);
                } else {
                  _navigateTo(index);
                }
              },
              destinations: const [
                NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
                NavigationDestination(icon: Icon(Icons.memory_rounded), label: 'Simulator'),
                NavigationDestination(icon: Icon(Icons.model_training_rounded), label: 'Train'),
                NavigationDestination(icon: Icon(Icons.psychology_rounded), label: 'Predict'),
                NavigationDestination(icon: Icon(Icons.more_horiz_rounded), label: 'More'),
              ],
            ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.apps_rounded, color: AppColors.electricBlue),
                title: const Text('ANN Applications'),
                onTap: () {
                  Navigator.pop(ctx);
                  _navigateTo(4);
                },
              ),
              ListTile(
                leading: const Icon(Icons.school_rounded, color: AppColors.gold),
                title: const Text('Learn ANN Educational Module'),
                onTap: () {
                  Navigator.pop(ctx);
                  _navigateTo(5);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bar_chart_rounded, color: AppColors.accentGreen),
                title: const Text('Analytics & Experiments'),
                onTap: () {
                  Navigator.pop(ctx);
                  _navigateTo(6);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline_rounded, color: Colors.cyan),
                title: const Text('How ANN Works Inside This App'),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const HowAnnWorksScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings_rounded, color: Colors.grey),
                title: const Text('Settings & About'),
                onTap: () {
                  Navigator.pop(ctx);
                  _navigateTo(7);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
