import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class ResponsiveScaffold extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Widget body;
  final String title;
  final List<Widget>? actions;

  const ResponsiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.body,
    required this.title,
    this.actions,
  });

  static const List<NavigationDestinationData> destinations = [
    NavigationDestinationData(
      label: 'Home',
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard_rounded,
    ),
    NavigationDestinationData(
      label: 'Simulator',
      icon: Icons.play_circle_outline_rounded,
      selectedIcon: Icons.play_circle_filled_rounded,
    ),
    NavigationDestinationData(
      label: 'Algorithms',
      icon: Icons.account_tree_outlined,
      selectedIcon: Icons.account_tree_rounded,
    ),
    NavigationDestinationData(
      label: 'Learn',
      icon: Icons.school_outlined,
      selectedIcon: Icons.school_rounded,
    ),
    NavigationDestinationData(
      label: 'Applications',
      icon: Icons.hub_outlined,
      selectedIcon: Icons.hub_rounded,
    ),
    NavigationDestinationData(
      label: 'Analytics',
      icon: Icons.analytics_outlined,
      selectedIcon: Icons.analytics_rounded,
    ),
    NavigationDestinationData(
      label: 'Settings',
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 950;
    final isTablet = screenWidth >= 650 && screenWidth < 950;

    if (isDesktop) {
      // Sidebar on Desktop
      return Scaffold(
        body: Row(
          children: [
            Container(
              width: 240,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.white,
                border: Border(
                  right: BorderSide(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
              ),
              child: Column(
                children: [
                  // Logo & Brand Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.heroGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.grain_rounded, color: AppColors.gold, size: 24),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Swarm Lab',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Intelligence Suite',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedTextLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // Sidebar navigation items
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                      itemCount: destinations.length,
                      itemBuilder: (context, i) {
                        final dest = destinations[i];
                        final isSelected = selectedIndex == i;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Material(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            child: ListTile(
                              dense: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              tileColor: isSelected
                                  ? (isDark ? AppColors.blue.withValues(alpha: 0.2) : AppColors.primaryNavy.withValues(alpha: 0.08))
                                  : Colors.transparent,
                              leading: Icon(
                                isSelected ? dest.selectedIcon : dest.icon,
                                color: isSelected
                                    ? (isDark ? AppColors.accentCyan : AppColors.primaryNavy)
                                    : (isDark ? AppColors.mutedTextDark : AppColors.mutedTextLight),
                              ),
                              title: Text(
                                dest.label,
                                style: TextStyle(
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected
                                      ? (isDark ? Colors.white : AppColors.primaryNavy)
                                      : (isDark ? AppColors.mutedTextDark : AppColors.mainText),
                                ),
                              ),
                              onTap: () => onDestinationSelected(i),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Offline Status Badge
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF142238) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Offline Engine Active',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Main Content Area
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(title),
                  actions: actions,
                ),
                body: body,
              ),
            ),
          ],
        ),
      );
    } else if (isTablet) {
      // Navigation Rail on Tablet
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              labelType: NavigationRailLabelType.selected,
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.grain_rounded, color: AppColors.gold, size: 22),
                ),
              ),
              destinations: destinations
                  .map(
                    (d) => NavigationRailDestination(
                      icon: Icon(d.icon),
                      selectedIcon: Icon(d.selectedIcon),
                      label: Text(d.label),
                    ),
                  )
                  .toList(),
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: Scaffold(
                appBar: AppBar(
                  title: Text(title),
                  actions: actions,
                ),
                body: body,
              ),
            ),
          ],
        ),
      );
    } else {
      // Bottom Navigation on Mobile
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
        ),
        body: body,
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: onDestinationSelected,
          destinations: destinations
              .map(
                (d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ),
              )
              .toList(),
        ),
      );
    }
  }
}

class NavigationDestinationData {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const NavigationDestinationData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
