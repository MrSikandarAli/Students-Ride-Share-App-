import 'package:flutter/material.dart';

/// Centralized color palette for the app so every screen and widget
/// pulls from the same source of truth.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3A5AFE);
  static const Color primaryDark = Color(0xFF2A3EB1);
  static const Color secondary = Color(0xFF00C9A7);
  static const Color accent = Color(0xFFFFB020);

  static const Color background = Color(0xFFF7F8FC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFEFF1F8);

  static const Color textPrimary = Color(0xFF1B1D28);
  static const Color textSecondary = Color(0xFF6B6F80);
  static const Color textHint = Color(0xFFA0A3B1);

  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE74C3C);
  static const Color warning = Color(0xFFF39C12);

  static const Color divider = Color(0xFFE3E5EE);
  static const Color driverBadge = Color(0xFF3A5AFE);
  static const Color passengerBadge = Color(0xFF00C9A7);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
