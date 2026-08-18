import 'package:flutter/material.dart';

/// App color palette designed for a modern, cinematic dark theme.
class AppColors {
  AppColors._();

  // Background colors
  static const Color background = Color(0xFF0F1016);
  static const Color surface = Color(0xFF181A24);
  static const Color surfaceElevated = Color(0xFF222533);
  static const Color surfaceLight = Color(0xFF2C3042);

  // Accent & Brand colors
  static const Color primary = Color(0xFFE50914); // Cinematic red
  static const Color primaryLight = Color(0xFFFF3D47);
  static const Color secondary = Color(0xFFFFB800); // Star/rating gold
  static const Color accent = Color(0xFF00D2D3);

  // Text colors
  static const Color textPrimary = Color(0xFFF3F4F6);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // Border & Divider
  static const Color border = Color(0xFF2D3245);
  static const Color divider = Color(0xFF232738);

  // Shimmer / Placeholder
  static const Color shimmerBase = Color(0xFF1E212D);
  static const Color shimmerHighlight = Color(0xFF2D3245);
}
