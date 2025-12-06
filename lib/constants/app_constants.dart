import 'package:flutter/material.dart';

class AppColors {
  // Deep Space Theme
  static const Color primary = Color(
    0xFF39FF14,
  ); // Neon Green (Kept for contrast)
  static const Color secondary = Color(0xFF00FFEF); // Cyan/Aqua
  static const Color background = Color(0xFF1A1A2E); // Deep Blue
  static const Color surface = Color(0xFF16213E); // Lighter Deep Blue
  static const Color error = Color(0xFFFF0033); // Neon Red

  static const Color onPrimary = Colors.black;
  static const Color onSecondary = Colors.black;
  static const Color onBackground = Colors.white;
  static const Color onSurface = Colors.white;

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.white70;
  static const Color textHint = Colors.white38;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF39FF14), Color(0xFF00FFEF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF16213E), Color(0xFF1A1A2E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class AppConstants {
  static const String appName = 'Turnament';
  static const String currencySymbol = '₹';
}
