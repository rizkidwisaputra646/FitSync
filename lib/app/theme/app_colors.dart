import 'package:flutter/material.dart';

/// FitSync Design System Colors
/// Palette: Charcoal/Dark Slate Green base with Athletic High-Contrast Lime accents.
/// Designed for a premium, focused, sporty aesthetic without generic clutter.
class AppColors {
  AppColors._();

  // Backgrounds
  static const Color background = Color(0xFF0C1210);      // Deep charcoal with slight dark-green undertone
  static const Color surface = Color(0xFF141C19);         // Dark slate green container
  static const Color surfaceElevated = Color(0xFF1B2521); // Card/dialog background
  static const Color surfaceHighlight = Color(0xFF22302A); // Active/Hover/Border card state

  // Accents (Lime)
  static const Color primary = Color(0xFFCCFF00);         // Electric Athletic Lime
  static const Color primaryContainer = Color(0xFF2E3D12); // Subtle lime background for badges
  static const Color secondary = Color(0xFF9EF01A);       // Mid-tone vivid lime
  static const Color accentMuted = Color(0xFF6B990D);      // Muted lime for inactive/subtle borders

  // Text & Content
  static const Color textPrimary = Color(0xFFF4F6F5);     // Crisp off-white
  static const Color textSecondary = Color(0xFF9EABA4);   // Readable slate grey
  static const Color textMuted = Color(0xFF5F6E67);       // Dim caption grey
  static const Color textOnPrimary = Color(0xFF0C1210);   // Dark text on bright lime buttons

  // Feedback & Status
  static const Color success = Color(0xFF22C55E);         // Crisp emerald green
  static const Color error = Color(0xFFEF4444);           // Vibrant red that's easy on dark mode
  static const Color warning = Color(0xFFF59E0B);         // Amber
  static const Color info = Color(0xFF38BDF8);            // Soft cyan

  // Borders & Dividers
  static const Color divider = Color(0xFF202C26);
  static const Color border = Color(0xFF283830);
  static const Color borderFocused = Color(0xFFCCFF00);
}
