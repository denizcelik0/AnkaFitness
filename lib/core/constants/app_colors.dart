import 'package:flutter/material.dart';

/// AnkaFitness uygulama renk paleti.
/// Koyu gri/antrasit tonlarında modern dark theme.
class AppColors {
  AppColors._();

  // ── Arka Plan Tonları ──
  static const Color background = Color(0xFF1A1A2E);
  static const Color surface = Color(0xFF16213E);
  static const Color surfaceLight = Color(0xFF1F2B47);
  static const Color card = Color(0xFF222B45);

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

  // ── Gradient'ler ──
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1F2B47), Color(0xFF162240)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFF00C853)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
