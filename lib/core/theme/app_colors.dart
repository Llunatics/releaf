import 'package:flutter/material.dart';

class AppColors {
  // Primary Blue Palette - Modern & Fresh
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryBlueDark = Color(0xFF1D4ED8);
  static const Color primaryBlueLight = Color(0xFF60A5FA);
  static const Color primaryBlueAccent = Color(0xFF93C5FD);
  
  // Secondary Colors
  static const Color secondaryTeal = Color(0xFF0D9488);
  static const Color secondaryIndigo = Color(0xFF6366F1);
  
  // Background Colors - Light Mode
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // Background Colors - Dark Mode (GitHub-inspired)
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color cardDark = Color(0xFF21262D);
  
  // Text Colors - Light Mode
  static const Color textPrimaryLight = Color(0xFF1E293B);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textTertiaryLight = Color(0xFF94A3B8);
  
  // Text Colors - Dark Mode
  static const Color textPrimaryDark = Color(0xFFF0F6FC);
  static const Color textSecondaryDark = Color(0xFF8B949E);
  static const Color textTertiaryDark = Color(0xFF6E7681);
  
  // Border Colors
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF30363D);
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9);
  static const Color infoLight = Color(0xFFE0F2FE);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
  );
  
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF60A5FA), Color(0xFF6366F1)],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
  );
  
  // Glass Effect Colors
  static Color glassWhite = Colors.white.withValues(alpha: 0.15);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
  static Color glassOverlay = Colors.white.withValues(alpha: 0.1);
  
  // Shadow Colors
  static Color shadowLight = const Color(0xFF3B82F6).withValues(alpha: 0.08);
  static Color shadowMedium = const Color(0xFF3B82F6).withValues(alpha: 0.15);
  
  // Category Colors
  static const List<Color> categoryColors = [
    Color(0xFF3B82F6), // Fiction
    Color(0xFF7C3AED), // Non-Fiction
    Color(0xFF0D9488), // Education
    Color(0xFFF59E0B), // Children
    Color(0xFFEC4899), // Romance
    Color(0xFF10B981), // Science
    Color(0xFF6366F1), // History
    Color(0xFFEF4444), // Mystery
  ];
}
