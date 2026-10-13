import 'package:flutter/material.dart';

/// Warm desert palette (sand, cream and dark brown).
class AppColors {
  // Backgrounds
  static const Color sand = Color(0xFFE8D6C3);
  static const Color sandLight = Color(0xFFF3E8DC);
  static const Color cream = Color(0xFFFAF5EF);
  static const Color chip = Color(0xFFE2D0BD);
  static const Color white = Color(0xFFFFFFFF);

  // Brand
  static const Color brown = Color(0xFF3B2A1F);
  static const Color brownMedium = Color(0xFF6B4E3A);
  static const Color accent = Color(0xFFC9773A);
  static const Color star = Color(0xFFF0A93B);
  static const Color plantGreen = Color(0xFF5E7A4A);

  // Text
  static const Color textPrimary = Color(0xFF2E1F16);
  static const Color textSecondary = Color(0xFF8C7462);
  static const Color divider = Color(0xFFE6D8CA);

  // Status
  static const Color error = Color(0xFFC0392B);
  static const Color location = Color(0xFF2F80ED);

  /// Background gradient used behind most screens.
  static const LinearGradient background = LinearGradient(
    colors: [sand, sandLight],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
