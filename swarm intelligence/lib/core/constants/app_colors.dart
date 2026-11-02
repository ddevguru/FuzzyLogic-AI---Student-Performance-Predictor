import 'package:flutter/material.dart';

class AppColors {
  // Required Brand Colors
  static const Color primaryNavy = Color(0xFF002350);
  static const Color gold = Color(0xFFD2AE39);
  static const Color blue = Color(0xFF1769AA);
  static const Color green = Color(0xFF2E8B57);
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color mainText = Color(0xFF172033);
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkSurface = Color(0xFF111C2E);

  // Modern UI Secondary & Supporting Tones
  static const Color darkCard = Color(0xFF152238);
  static const Color darkBorder = Color(0xFF1F3252);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color mutedTextLight = Color(0xFF64748B);
  static const Color mutedTextDark = Color(0xFF94A3B8);

  static const Color accentCyan = Color(0xFF00B4D8);
  static const Color accentPurple = Color(0xFF7C3AED);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color success = Color(0xFF10B981);

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF002350), Color(0xFF0A3A75), Color(0xFF1769AA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD2AE39), Color(0xFFF3D269)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF131F33), Color(0xFF0E1726)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
