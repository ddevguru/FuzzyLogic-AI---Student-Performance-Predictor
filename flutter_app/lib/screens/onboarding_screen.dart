import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingPageData> _pages = const [
    _OnboardingPageData(
      title: 'Mamdani Fuzzy Logic Engine',
      description:
          'Experience genuine AI inference using triangular and trapezoidal membership functions rather than basic linear weighted averages.',
      icon: Icons.auto_awesome,
      accentColor: AppTheme.accentGold,
    ),
    _OnboardingPageData(
      title: 'Academic Risk Assessment',
      description:
          'Instantly calculate performance scores, performance levels, and academic risk levels to take early corrective action.',
      icon: Icons.analytics_outlined,
      accentColor: AppTheme.blue,
    ),
    _OnboardingPageData(
      title: 'Personalized Recommendations',
      description:
          'Receive dynamic, prioritized advice tailored to your weak academic indicators like attendance, test scores, or study routine.',
      icon: Icons.lightbulb_outline,
      accentColor: AppTheme.green,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarded', true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.darkBg : AppTheme.navy,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Skip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.school, color: AppTheme.accentGold, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'FuzzyLogic AI',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _completeOnboarding,
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (page) => setState(() => _currentPage = page),
                itemBuilder: (context, index) {
                  final data = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            color: data.accentColor.withOpacity(0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: data.accentColor.withOpacity(0.4),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            data.icon,
                            size: 80,
                            color: data.accentColor,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          data.title,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          data.description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            height: 1.5,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicators & Navigation Controls
            Padding(
              padding: const EdgeInsets.all(28.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (idx) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        height: 8,
                        width: _currentPage == idx ? 24 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == idx ? AppTheme.accentGold : Colors.white24,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Next / Get Started Button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _pages.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _completeOnboarding();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentGold,
                      foregroundColor: AppTheme.navy,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'GET STARTED' : 'NEXT',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;

  const _OnboardingPageData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
  });
}
