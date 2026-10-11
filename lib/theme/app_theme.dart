import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0C0E17);
  static const Color surface = Color(0xFF141726);
  static const Color surfaceLight = Color(0xFF1E2238);
  static const Color card = Color(0xFF171B2D);
  static const Color cardBorder = Color(0xFF262C44);

  // Primary & Accents
  static const Color primary = Color(0xFF8B5CF6); // Electric Purple
  static const Color primaryGlow = Color(0x668B5CF6);
  static const Color primaryDark = Color(0xFF6D28D9);

  // Status & Metrics (matches reference UI diagrams)
  static const Color fluency = Color(0xFF38BDF8); // Electric Sky Blue
  static const Color grammar = Color(0xFFEF4444); // Crimson Red
  static const Color pronunciation = Color(0xFF10B981); // Emerald Green
  static const Color vocabulary = Color(0xFFA855F7); // Purple
  static const Color overall = Color(0xFFF59E0B); // Amber / Gold
  static const Color streakOrange = Color(0xFFFF7A00);

  // Text
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Feedback Badges
  static const Color badgeGreen = Color(0xFF059669);
  static const Color badgePurple = Color(0xFF7C3AED);
  static const Color badgeRed = Color(0xFFDC2626);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.cardBorder, width: 1),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }
}
