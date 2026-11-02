import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette
  static const Color navy = Color(0xFF002350);
  static const Color navyLight = Color(0xFF0A376B);
  static const Color gold = Color(0xFFD2AE39);
  static const Color goldLight = Color(0xFFF4D465);
  static const Color blue = Color(0xFF1769AA);
  static const Color blueLight = Color(0xFF4791DB);
  static const Color green = Color(0xFF2E8B57);
  static const Color greenLight = Color(0xFF4CAF50);
  
  // Status Colors
  static const Color accentRed = Color(0xFFE53935);
  static const Color accentOrange = Color(0xFFFB8C00);
  static const Color accentPurple = Color(0xFF8E24AA);
  static const Color accentCyan = Color(0xFF00ACC1);

  // Light Mode Surfaces
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceBorder = Color(0xFFE2E8F0);
  static const Color lightTextPrimary = Color(0xFF172033);
  static const Color lightTextSecondary = Color(0xFF64748B);

  // Dark Mode Surfaces
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111C2E);
  static const Color darkSurfaceBorder = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // Rank Colors
  static const Color rankBest = Color(0xFFD2AE39); // Gold
  static const Color rankGood = Color(0xFF2E8B57); // Green
  static const Color rankAverage = Color(0xFF1769AA); // Blue
  static const Color rankWeak = Color(0xFF94A3B8); // Slate

  // Gradient definitions
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF002350), Color(0xFF0A376B), Color(0xFF1769AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD2AE39), Color(0xFFF4D465)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF),
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
