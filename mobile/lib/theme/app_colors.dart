import 'package:flutter/material.dart';

/// Palet warna terpusat, mendukung mode Dark (gaming neon, default) dan Light.
/// AppColors.isDarkNotifier dipakai untuk toggle tema di runtime (lihat
/// EditProfileScreen -> "Mode Gelap").
class AppColors {
  AppColors._();

  static final ValueNotifier<bool> isDarkNotifier = ValueNotifier<bool>(true);
  static bool get isDark => isDarkNotifier.value;

  // ---------- Palet DARK (gaming neon) ----------
  static const Color _darkBackground = Color(0xFF0A0E1F);
  static const Color _darkSurface = Color(0xFF141A33);
  static const Color _darkSurfaceAlt = Color(0xFF1D2547);
  static const Color _darkBorder = Color(0xFF262E52);
  static const Color _darkTextPrimary = Color(0xFFF2F3FA);
  static const Color _darkTextMuted = Color(0xFF9099BF);
  static const Color _darkAccentLight = Color(0xFF2A2352);

  // ---------- Palet LIGHT ----------
  static const Color _lightBackground = Color(0xFFF5F6FA);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightSurfaceAlt = Color(0xFFF0F1F6);
  static const Color _lightBorder = Color(0xFFE2E4EE);
  static const Color _lightTextPrimary = Color(0xFF1A1D2E);
  static const Color _lightTextMuted = Color(0xFF6B7089);
  static const Color _lightAccentLight = Color(0xFFF1ECFE);

  // ---------- Getter publik (dipakai di seluruh app) ----------
  static Color get background => isDark ? _darkBackground : _lightBackground;
  static Color get surface => isDark ? _darkSurface : _lightSurface;
  static Color get surfaceAlt => isDark ? _darkSurfaceAlt : _lightSurfaceAlt;
  static Color get border => isDark ? _darkBorder : _lightBorder;
  static Color get textPrimary => isDark ? _darkTextPrimary : _lightTextPrimary;
  static Color get textMuted => isDark ? _darkTextMuted : _lightTextMuted;
  static Color get accentLight => isDark ? _darkAccentLight : _lightAccentLight;

  // Alias lama (dipakai di beberapa layar) - ikut berubah sesuai tema
  static Color get navy => surface;
  static Color get navyLight => surfaceAlt;

  // ---------- Warna brand: TETAP SAMA di kedua tema (identitas Stray) ----------
  static const Color neonPurple = Color(0xFF8B5CF6);
  static const Color neonPink = Color(0xFFEC4899);
  static const Color neonCyan = Color(0xFF22D3EE);
  static const Color accent = neonPurple;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonPurple, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get bgGlowGradient => LinearGradient(
        colors: [isDark ? const Color(0xFF171F42) : _lightSurfaceAlt, background],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      );
}
