import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand Colors
  static const Color navy = Color(0xFF002350);
  static const Color blue = Color(0xFF1769AA);
  static const Color accentGold = Color(0xFFD2AE39);
  static const Color green = Color(0xFF2E8B57);
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color darkBg = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color textDark = Color(0xFF172033);

  // Status Colors
  static const Color poorColor = Color(0xFFEF4444);
  static const Color averageColor = Color(0xFFF59E0B);
  static const Color goodColor = Color(0xFF3B82F6);
  static const Color veryGoodColor = Color(0xFF10B981);
  static const Color excellentColor = Color(0xFF8B5CF6);

  static const Color highRisk = Color(0xFFDC2626);
  static const Color moderateRisk = Color(0xFFEA580C);
  static const Color lowRisk = Color(0xFF16A34A);
  static const Color veryLowRisk = Color(0xFF059669);

  static Color getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'poor':
        return poorColor;
      case 'average':
        return averageColor;
      case 'good':
        return goodColor;
      case 'very good':
        return veryGoodColor;
      case 'excellent':
        return excellentColor;
      default:
        return blue;
    }
  }

  static Color getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high risk':
        return highRisk;
      case 'moderate risk':
        return moderateRisk;
      case 'low risk':
        return lowRisk;
      case 'very low risk':
        return veryLowRisk;
      default:
        return blue;
    }
  }

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: navy,
    scaffoldBackgroundColor: lightBg,
    colorScheme: const ColorScheme.light(
      primary: navy,
      secondary: blue,
      tertiary: accentGold,
      surface: Colors.white,
      background: lightBg,
      onPrimary: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        color: textDark,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      titleLarge: GoogleFonts.outfit(
        color: textDark,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      titleMedium: GoogleFonts.inter(
        color: textDark,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: const Color(0xFF475569),
        fontSize: 14,
      ),
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: navy,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    primaryColor: blue,
    scaffoldBackgroundColor: darkBg,
    colorScheme: const ColorScheme.dark(
      primary: blue,
      secondary: accentGold,
      surface: darkSurface,
      background: darkBg,
      onPrimary: Colors.white,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.outfit(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 32,
      ),
      titleLarge: GoogleFonts.outfit(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 22,
      ),
      titleMedium: GoogleFonts.inter(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      bodyMedium: GoogleFonts.inter(
        color: const Color(0xFF94A3B8),
        fontSize: 14,
      ),
    ),
    cardTheme: CardThemeData(
      color: darkSurface,
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: GoogleFonts.outfit(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
