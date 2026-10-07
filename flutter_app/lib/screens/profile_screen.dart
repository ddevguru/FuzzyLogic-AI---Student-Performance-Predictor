import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppTheme.navy,
                    child: Text(
                      user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : 'S',
                      style: GoogleFonts.outfit(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.name ?? 'Student Name',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.blue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'ROLE: ${user?.role.toUpperCase() ?? 'STUDENT'}',
                      style: const TextStyle(
                        color: AppTheme.blue,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _ProfileDetailRow(
                      icon: Icons.badge_outlined,
                      label: 'Roll Number',
                      value: user?.profile?.rollNumber ?? 'N/A',
                    ),
                    const Divider(),
                    _ProfileDetailRow(
                      icon: Icons.school_outlined,
                      label: 'Course',
                      value: user?.profile?.course ?? 'B.Tech CS',
                    ),
                    const Divider(),
                    _ProfileDetailRow(
                      icon: Icons.business_outlined,
                      label: 'Department',
                      value: user?.profile?.department ?? 'School of Computing',
                    ),
                    const Divider(),
                    _ProfileDetailRow(
                      icon: Icons.numbers_outlined,
                      label: 'Current Semester',
                      value: 'Semester ${user?.profile?.semester ?? 6}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Preferences Card
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_outlined),
                    title: const Text('Dark Mode Theme'),
                    subtitle: const Text('Toggle light and dark color schemes'),
                    value: themeProvider.isDarkMode,
                    activeColor: AppTheme.accentGold,
                    onChanged: (val) => themeProvider.toggleTheme(val),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.hub_outlined),
                    title: const Text('Fuzzy Engine Model'),
                    subtitle: const Text('Mamdani Inference System v1.0'),
                    trailing: const Icon(Icons.check_circle, color: AppTheme.green, size: 20),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: AppTheme.poorColor),
                label: const Text(
                  'LOGOUT ACCOUNT',
                  style: TextStyle(
                    color: AppTheme.poorColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.poorColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.navy, size: 22),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
