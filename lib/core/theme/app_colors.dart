import 'package:flutter/material.dart';

class AppColors {
  const AppColors({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.textPrimary,
    required this.textSecondary,
    required this.border,
    required this.error,
    required this.success,
  });

  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color textPrimary;
  final Color textSecondary;
  final Color border;
  final Color error;
  final Color success;

  static const AppColors defaultPalette = AppColors(
    primary: Color(0xFF5B5CF6),
    secondary: Color(0xFF7B7CFF),
    background: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF101010),
    textSecondary: Color(0xFFB3B3B8),
    border: Color(0xFFE9E9EF),
    error: Color(0xFFC44F4F),
    success: Color(0xFF2E7D5B),
  );
}
