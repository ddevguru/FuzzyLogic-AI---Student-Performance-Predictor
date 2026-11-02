import 'package:flutter/material.dart';

class AppColors {
  // Brand Palette
  static const Color primaryNavy = Color(0xFF002350);
  static const Color gold = Color(0xFFD2AE39);
  static const Color electricBlue = Color(0xFF1769AA);
  static const Color accentGreen = Color(0xFF2E8B57);
  
  // Background & Surfaces (Light)
  static const Color backgroundLight = Color(0xFFF5F7FA);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color textMainLight = Color(0xFF172033);
  static const Color textSubtleLight = Color(0xFF5A6A85);
  
  // Background & Surfaces (Dark - Premium AI Lab theme)
  static const Color backgroundDark = Color(0xFF0B1220);
  static const Color surfaceDark = Color(0xFF121C2E);
  static const Color cardDark = Color(0xFF1A263D);
  static const Color textMainDark = Color(0xFFE6EEF8);
  static const Color textSubtleDark = Color(0xFF94A3B8);

  // Connection Weight Colors
  static const Color weightPositive = Color(0xFF2E8B57); // Green for positive weights
  static const Color weightNegative = Color(0xFFE53935); // Red for negative weights
  static const Color weightZero = Color(0xFF9E9E9E);     // Grey for zero

  // Neuron States
  static const Color inputNeuron = Color(0xFF1769AA);   // Electric Blue
  static const Color hiddenNeuron = Color(0xFFD2AE39);  // Gold
  static const Color outputNeuron = Color(0xFF2E8B57);  // Accent Green
  static const Color activePulse = Color(0xFF00F2FE);   // Cyan Glow

  // Gradients
  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF002350), Color(0xFF0A3A75)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x1F1769AA), Color(0x05D2AE39)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
