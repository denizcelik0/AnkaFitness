import 'package:flutter/material.dart';

/// QR Prototype uygulama renk paleti.
/// Koyu gri/antrasit tonlarında modern dark theme.
class AppColors {
  AppColors._();

  // ── Arka Plan Tonları ──
  static const Color background = Color(0xFF0A0E21);
  static const Color surface = Color(0xFF111633);
  static const Color surfaceLight = Color(0xFF1A2040);
  static const Color card = Color(0xFF1C2244);

  // ── Vurgu Renkleri ──
  static const Color primary = Color(0xFF00D9FF);
  static const Color primaryDark = Color(0xFF00A8CC);
  static const Color secondary = Color(0xFF7C4DFF);
  static const Color accent = Color(0xFF00E676);

  // ── Metin Renkleri ──
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0BEC5);
  static const Color textHint = Color(0xFF78909C);

  // ── Durum Renkleri ──
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD740);
  static const Color error = Color(0xFFFF5252);
  static const Color info = Color(0xFF448AFF);

  // ── Kenarlık & Ayırıcı ──
  static const Color divider = Color(0xFF2A3A5C);
  static const Color border = Color(0xFF2E3A59);

  // ── Shimmer & Glow ──
  static const Color shimmer = Color(0xFF2A4065);
  static const Color glow = Color(0xFF00D9FF);

  // ── Gradient'ler ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A2545), Color(0xFF121835)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF),
      Color(0x0DFFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient shimmerGradient = LinearGradient(
    colors: [
      Color(0x00FFFFFF),
      Color(0x1AFFFFFF),
      Color(0x00FFFFFF),
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [
      Color(0xFF0A0E21),
      Color(0xFF0F1535),
      Color(0xFF0A0E21),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
