import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'screens/about/about_screen.dart';
import 'screens/analytics/analytics_screen.dart';
import 'screens/applications/applications_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/learn/learn_screen.dart';
import 'screens/modes/demo_mode_screen.dart';
import 'screens/modes/presentation_mode_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/simulator/simulator_screen.dart';
import 'services/settings_service.dart';
import 'services/simulation_service.dart';
import 'widgets/common/app_header.dart';
import 'widgets/navigation/app_nav_bar.dart';
import 'widgets/navigation/app_nav_rail.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsService()),
        ChangeNotifierProvider(create: (_) => SimulationService()),
      ],
      child: const GeneticLabApp(),
    ),
  );
}

class GeneticLabApp extends StatelessWidget {
  const GeneticLabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        return MaterialApp(
          title: 'Genetic Optimization Lab',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const MainShellScreen(),
        );
      },
    );
  }
}

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktop = mediaQuery.size.width >= 720;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Widget> screens = [
      HomeScreen(
        onNavigate: (index) => setState(() => _currentIndex = index),
        onLaunchDemo: () => DemoModeScreen.show(context),
        onLaunchPresentation: () => PresentationModeScreen.show(context),
      ),
      const SimulatorScreen(),
      const ApplicationsScreen(),
      const LearnScreen(),
      const AnalyticsScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppHeader(
        title: _getScreenTitle(_currentIndex),
        subtitle: _getScreenSubtitle(_currentIndex),
        actions: [
          IconButton(
            tooltip: 'Viva / Presentation Mode',
            icon: const Icon(Icons.present_to_all_rounded, color: AppColors.gold),
            onPressed: () => PresentationModeScreen.show(context),
          ),
          IconButton(
            tooltip: 'Demo Mode',
            icon: const Icon(Icons.play_circle_outline_rounded, color: AppColors.gold),
            onPressed: () => DemoModeScreen.show(context),
          ),
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              Provider.of<SettingsService>(context, listen: false).toggleTheme();
            },
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () => setState(() => _currentIndex = 5),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Row(
        children: [
          if (isDesktop)
            AppNavRail(
              currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
              onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
              onSettingsTap: () => setState(() => _currentIndex = 5),
              onPresentationTap: () => PresentationModeScreen.show(context),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey<int>(_currentIndex),
                child: screens[_currentIndex],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop
          ? AppNavBar(
              currentIndex: _currentIndex > 4 ? 0 : _currentIndex,
              onTap: (idx) => setState(() => _currentIndex = idx),
            )
          : null,
    );
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'Genetic Optimization Lab';
      case 1:
        return 'GA Simulator';
      case 2:
        return 'Real-World Applications';
      case 3:
        return 'Learn Genetic Algorithm';
      case 4:
        return 'Analytics & Benchmarks';
      case 5:
        return 'Settings';
      default:
        return 'Genetic Optimization Lab';
    }
  }

  String _getScreenSubtitle(int index) {
    switch (index) {
      case 0:
        return 'Interactive Evolutionary Intelligence Platform';
      case 1:
        return 'Real-time local parameter evolution';
      case 2:
        return 'NP-Hard problem solving across industries';
      case 3:
        return 'Core concepts, terminology & biological analogies';
      case 4:
        return 'Session metrics, charts & convergence statistics';
      case 5:
        return 'Appearance, default parameters & about details';
      default:
        return 'Interactive GA Laboratory';
    }
  }
}
