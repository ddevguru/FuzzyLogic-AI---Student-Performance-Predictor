import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'main_navigation_screen.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    _checkNavigationFlow();
  }

  Future<void> _checkNavigationFlow() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final isOnboarded = prefs.getBool('is_onboarded') ?? false;

    if (!isOnboarded) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
      return;
    }

    if (authProvider.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.navy,
      body: Stack(
        children: [
          // Background Fuzzy Network Nodes
          CustomPaint(
            size: Size.infinite,
            painter: _FuzzyNetworkPainter(),
          ),
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.accentGold.withOpacity(0.5), width: 2),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 64,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '🎓 FuzzyLogic AI',
                      style: GoogleFonts.outfit(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Student Performance Predictor System',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 48),
                    const SizedBox(
                      width: 32,
                      height: 32,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentGold),
                        strokeWidth: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FuzzyNetworkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..strokeWidth = 1.5;

    final nodePaint = Paint()
      ..color = AppTheme.accentGold.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final points = [
      Offset(size.width * 0.2, size.height * 0.2),
      Offset(size.width * 0.8, size.height * 0.25),
      Offset(size.width * 0.5, size.height * 0.4),
      Offset(size.width * 0.15, size.height * 0.7),
      Offset(size.width * 0.85, size.height * 0.75),
    ];

    for (int i = 0; i < points.length; i++) {
      for (int j = i + 1; j < points.length; j++) {
        canvas.drawLine(points[i], points[j], paint);
      }
      canvas.drawCircle(points[i], 12, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
