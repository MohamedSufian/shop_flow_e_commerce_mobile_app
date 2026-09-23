import 'package:flutter/material.dart';

/// ShopFlow color palette.
/// Primary: deep violet — trust & premium feel.
/// Accent: warm coral — prices, sales, calls to action.
class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF5B4BF5);
  static const Color primaryDark = Color(0xFF4335D9);
  static const Color primaryLight = Color(0xFF8B7FFF);
  static const Color accent = Color(0xFFFF7A59);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color star = Color(0xFFFFB800);

  // Light
  static const Color lightBackground = Color(0xFFF6F6FB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFEFEEF8);
  static const Color lightText = Color(0xFF14142B);
  static const Color lightTextMuted = Color(0xFF8A8AA3);
  static const Color lightBorder = Color(0xFFE7E7F0);

  // Dark
  static const Color darkBackground = Color(0xFF0D0D14);
  static const Color darkSurface = Color(0xFF171722);
  static const Color darkCard = Color(0xFF1B1B27);
  static const Color darkSurfaceAlt = Color(0xFF242434);
  static const Color darkText = Color(0xFFF4F4FA);
  static const Color darkTextMuted = Color(0xFF9494AE);
  static const Color darkBorder = Color(0xFF2C2C3E);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7B5CFF), Color(0xFF5B4BF5), Color(0xFF3F37C9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF9A6C), Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
