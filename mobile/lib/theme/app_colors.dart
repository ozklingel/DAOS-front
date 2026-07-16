import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color accent = Color(0xFF60A5FA);

  // Dark theme (new design)
  static const Color darkBackground = Color(0xFF0B1220);
  static const Color darkBackgroundMid = Color(0xFF111827);
  static const Color darkSurface = Color(0xFF1A2332);
  static const Color darkGlass = Color(0xCC1E293B);
  static const Color darkGlassBorder = Color(0x33FFFFFF);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextTertiary = Color(0xFF64748B);

  // Light theme (legacy screens)
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFF4F4F5);

  static const Color textPrimary = Color(0xFF18181B);
  static const Color textSecondary = Color(0xFF71717A);
  static const Color textTertiary = Color(0xFFA1A1AA);

  static const Color border = Color(0xFFE4E4E7);
  static const Color divider = Color(0xFFF4F4F5);

  static const Color critical = Color(0xFFEF4444);
  static const Color criticalBg = Color(0x33EF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningBg = Color(0x33F59E0B);
  static const Color success = Color(0xFF22C55E);
  static const Color successBg = Color(0x3322C55E);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoBg = Color(0x333B82F6);

  static const Color priorityHigh = Color(0xFFEF4444);
  static const Color priorityMedium = Color(0xFFF59E0B);
  static const Color priorityLow = Color(0xFF22C55E);
  static const Color priorityNone = Color(0xFF71717A);

  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F172A), Color(0xFF0B1220), Color(0xFF020617)],
  );

  static const LinearGradient quickActionGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF334155), Color(0xFF1E293B)],
  );

  static const LinearGradient quickActionPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
  );
}
