import 'package:flutter/material.dart';

/// Application color constants and color schemes
class AppColors {
  AppColors._(); // Private constructor to prevent instantiation

  // Primary Colors (Trading Signal Theme)
  static const Color primary = Color(0xFF00D4FF);      // Bright cyan
  static const Color secondary = Color(0xFF00FF88);     // Bright green
  static const Color accent = Color(0xFFFF00FF);        // Bright magenta
  
  // Signal Type Colors
  static const Color preMarket = Color(0xFFFFD93D);     // Golden yellow
  static const Color earnings = Color(0xFF95A5A6);      // Silver gray
  static const Color momentum = Color(0xFF00FF88);      // Bright green
  static const Color volume = Color(0xFF00D4FF);        // Bright cyan
  static const Color breakout = Color(0xFFFF6B6B);      // Coral red
  static const Color options = Color(0xFF9B59B6);       // Purple
  static const Color crypto = Color(0xFFF39C12);        // Orange
  
  // Status Colors
  static const Color success = Color(0xFF00FF88);       // Green
  static const Color error = Color(0xFFFF4757);         // Red
  static const Color warning = Color(0xFFFFD93D);       // Yellow
  static const Color info = Color(0xFF00D4FF);          // Blue
  
  // Premium/Subscription Colors
  static const Color premium = Color(0xFFFF6B6B);       // Premium coral
  static const Color free = Color(0xFF95A5A6);          // Free tier gray
  static const Color dynamic = Color(0xFF9B59B6);       // Dynamic purple
  
  // Background Colors
  static const Color backgroundDark = Color(0xFF000000);     // Pure black
  static const Color backgroundLight = Color(0xFFFFFFFF);    // Pure white
  static const Color surfaceDark = Color(0xFF1A1A1A);       // Dark gray
  static const Color surfaceLight = Color(0xFFF8F9FA);      // Light gray
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);       // White
  static const Color textSecondary = Color(0xFFCCCCCC);     // Light gray
  static const Color textTertiary = Color(0xFF888888);      // Medium gray
  static const Color textOnLight = Color(0xFF000000);       // Black for light backgrounds
  
  // Border Colors
  static const Color border = Color(0xFF333333);            // Dark border
  static const Color borderLight = Color(0xFFE0E0E0);       // Light border
  
  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF00FF88), // Green
    Color(0xFF00D4FF), // Blue  
    Color(0xFFFFD93D), // Yellow
    Color(0xFFFF6B6B), // Red
    Color(0xFF9B59B6), // Purple
    Color(0xFFF39C12), // Orange
  ];

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF00FF88),
      Color(0xFF00D4FF),
      Color(0xFFFF00FF),
    ],
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF000000),
      Color(0xFF1A1A1A),
    ],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A1A1A),
      Color(0xFF2A2A2A),
    ],
  );

  // Signal Confidence Colors
  static Color getConfidenceColor(double confidence) {
    if (confidence >= 80) return success;
    if (confidence >= 60) return warning;
    if (confidence >= 40) return info;
    return error;
  }

  // Signal Type Color Mapping
  static Color getSignalTypeColor(String signalType) {
    switch (signalType.toLowerCase()) {
      case 'premarket':
      case 'pre-market':
        return preMarket;
      case 'earnings':
        return earnings;
      case 'momentum':
        return momentum;
      case 'volume':
        return volume;
      case 'breakout':
        return breakout;
      case 'options':
        return options;
      case 'crypto':
        return crypto;
      default:
        return primary;
    }
  }

  // Market Status Colors
  static Color getMarketStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return success;
      case 'closed':
        return error;
      case 'premarket':
      case 'pre-market':
        return warning;
      case 'afterhours':
      case 'after-hours':
        return info;
      default:
        return textSecondary;
    }
  }

  // Price Change Colors
  static Color getPriceChangeColor(double change) {
    if (change > 0) return success;
    if (change < 0) return error;
    return textSecondary;
  }

  // Subscription Tier Colors
  static Color getSubscriptionTierColor(String tier) {
    switch (tier.toLowerCase()) {
      case 'free':
        return free;
      case 'premium':
        return premium;
      case 'dynamic':
        return dynamic;
      default:
        return textSecondary;
    }
  }

  // Color Utilities
  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color lighten(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  static Color darken(Color color, [double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  // Material Color Scheme Generators
  static ColorScheme get lightColorScheme => const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    secondary: secondary,
    onSecondary: Colors.black,
    tertiary: accent,
    onTertiary: Colors.white,
    error: error,
    onError: Colors.white,
    surface: backgroundLight,
    onSurface: textOnLight,
    surfaceContainerHighest: surfaceLight,
    outline: borderLight,
  );

  static ColorScheme get darkColorScheme => const ColorScheme(
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: Colors.black,
    secondary: secondary,
    onSecondary: Colors.black,
    tertiary: accent,
    onTertiary: Colors.black,
    error: error,
    onError: Colors.white,
    surface: backgroundDark,
    onSurface: textPrimary,
    surfaceContainerHighest: surfaceDark,
    outline: border,
  );
}