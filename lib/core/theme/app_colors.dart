import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);
  
  // Secondary Colors
  static const Color secondaryColor = Color(0xFF10B981);
  static const Color secondaryLight = Color(0xFF34D399);
  static const Color secondaryDark = Color(0xFF059669);
  
  // Neutral Colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);
  
  // Semantic Colors
  static const Color successColor = Color(0xFF10B981);
  static const Color warningColor = Color(0xFFF59E0B);
  static const Color errorColor = Color(0xFFEF4444);
  static const Color infoColor = Color(0xFF3B82F6);
  
  // Trading Colors
  static const Color bullColor = Color(0xFF10B981); // Green for positive/buy
  static const Color bearColor = Color(0xFFEF4444); // Red for negative/sell
  static const Color neutralColor = Color(0xFF6B7280); // Grey for neutral/hold
  
  // Background Colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceLight = Color(0xFFF8FAFC);
  static const Color surfaceDark = Color(0xFF1E293B);
  
  // Light Color Scheme
  static const ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: primaryColor,
    onPrimary: white,
    primaryContainer: Color(0xFFE0E7FF),
    onPrimaryContainer: Color(0xFF1E3A8A),
    secondary: secondaryColor,
    onSecondary: white,
    secondaryContainer: Color(0xFFD1FAE5),
    onSecondaryContainer: Color(0xFF064E3B),
    tertiary: warningColor,
    onTertiary: white,
    tertiaryContainer: Color(0xFFFEF3C7),
    onTertiaryContainer: Color(0xFF92400E),
    error: errorColor,
    onError: white,
    errorContainer: Color(0xFFFEE2E2),
    onErrorContainer: Color(0xFF991B1B),
    surface: white,
    onSurface: grey900,
    surfaceContainer: grey50,
    onSurfaceVariant: grey600,
    outline: grey300,
    outlineVariant: grey200,
    shadow: black,
    scrim: black,
    inverseSurface: grey900,
    onInverseSurface: grey50,
    inversePrimary: Color(0xFF93C5FD),
  );
  
  // Dark Color Scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFF3B82F6),
    onPrimary: Color(0xFF1E3A8A),
    primaryContainer: Color(0xFF1D4ED8),
    onPrimaryContainer: Color(0xFFDBEAFE),
    secondary: Color(0xFF34D399),
    onSecondary: Color(0xFF064E3B),
    secondaryContainer: Color(0xFF059669),
    onSecondaryContainer: Color(0xFFD1FAE5),
    tertiary: Color(0xFFFBBF24),
    onTertiary: Color(0xFF92400E),
    tertiaryContainer: Color(0xFFD97706),
    onTertiaryContainer: Color(0xFFFEF3C7),
    error: Color(0xFFF87171),
    onError: Color(0xFF991B1B),
    errorContainer: Color(0xFFDC2626),
    onErrorContainer: Color(0xFFFEE2E2),
    surface: Color(0xFF0F172A),
    onSurface: grey100,
    surfaceContainer: Color(0xFF1E293B),
    onSurfaceVariant: grey400,
    outline: grey600,
    outlineVariant: grey700,
    shadow: black,
    scrim: black,
    inverseSurface: grey100,
    onInverseSurface: grey900,
    inversePrimary: primaryColor,
  );
  
  // Chart Colors
  static const List<Color> chartColors = [
    primaryColor,
    secondaryColor,
    warningColor,
    Color(0xFFEC4899),
    Color(0xFF8B5CF6),
    Color(0xFFF97316),
    Color(0xFF06B6D4),
    Color(0xFF84CC16),
  ];
  
  // Gradient Colors
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryColor, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient successGradient = LinearGradient(
    colors: [successColor, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient warningGradient = LinearGradient(
    colors: [warningColor, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const Gradient errorGradient = LinearGradient(
    colors: [errorColor, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}