import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppNavRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onSettingsTap;
  final VoidCallback onPresentationTap;

  const AppNavRail({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    required this.onSettingsTap,
    required this.onPresentationTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkSurfaceBorder : AppColors.lightSurfaceBorder,
          ),
        ),
      ),
      child: NavigationRail(
        selectedIndex: currentIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: NavigationRailLabelType.all,
        backgroundColor: Colors.transparent,
        selectedIconTheme: IconThemeData(color: isDark ? AppColors.gold : AppColors.blue),
        selectedLabelTextStyle: TextStyle(
          color: isDark ? AppColors.gold : AppColors.blue,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        unselectedIconTheme: IconThemeData(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
        leading: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.gold, size: 26),
            ),
            const SizedBox(height: 16),
          ],
        ),
        trailing: Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Viva / Presentation Mode',
                icon: const Icon(Icons.present_to_all_rounded, color: AppColors.gold),
                onPressed: onPresentationTap,
              ),
              IconButton(
                tooltip: 'Settings',
                icon: const Icon(Icons.settings_rounded),
                onPressed: onSettingsTap,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.dashboard_rounded),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.memory_rounded),
            label: Text('Simulator'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.apps_rounded),
            label: Text('Applications'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.school_rounded),
            label: Text('Learn GA'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.analytics_rounded),
            label: Text('Analytics'),
          ),
        ],
      ),
    );
  }
}
