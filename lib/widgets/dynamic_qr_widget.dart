import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import 'animated_gradient_border.dart';

/// Premium dinamik QR kod bileşeni.
/// Her 30 saniyede bir yenilenen güvenli QR kod gösterir.
/// Dönen gradient halka, glassmorphism ve canlı geri sayım animasyonları.
class DynamicQrWidget extends StatelessWidget {
  final String qrData;
  final int secondsRemaining;
  final bool isMembershipActive;

  const DynamicQrWidget({
    super.key,
    required this.qrData,
    required this.secondsRemaining,
    required this.isMembershipActive,
  });

  @override
  Widget build(BuildContext context) {
    if (!isMembershipActive) {
      return _buildExpiredView();
    }
    return _buildQrView();
  }

  /// Aktif üyelik: QR kod ve geri sayım gösterir.
  Widget _buildQrView() {
    // Geri sayım renk geçişi (son 10 saniye kırmızıya döner)
    final timerColor = secondsRemaining <= 10
        ? Color.lerp(AppColors.warning, AppColors.error,
            (10 - secondsRemaining) / 10)!
        : AppColors.primary;

    return AnimatedGradientBorder(
      borderRadius: AppConstants.borderRadiusLarge,
      borderWidth: 1.5,
      duration: const Duration(seconds: 4),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              gradient: AppColors.glassGradient,
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusLarge),
            ),
            child: Column(
              children: [
                // ── Başlık ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: const Icon(Icons.qr_code_scanner,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 8),
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        'GİRİŞ QR KODU',
                        style: AppTextStyles.label.copyWith(
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ── QR Kod — Glow efekti ──
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: QrImageView(
                      data: qrData,
                      version: QrVersions.auto,
                      size: 200,
                      backgroundColor: Colors.white,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0A0E21),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0A0E21),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Geri Sayım ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.timer_rounded, color: timerColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Yenilenme: ',
                      style: AppTextStyles.bodyMedium,
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 1.2, end: 1.0),
                      duration: const Duration(milliseconds: 300),
                      key: ValueKey(secondsRemaining),
                      curve: Curves.easeOut,
                      builder: (context, scale, child) {
                        return Transform.scale(
                          scale: scale,
                          child: Text(
                            '${secondsRemaining}s',
                            style: AppTextStyles.h3.copyWith(
                              color: timerColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── İlerleme Çubuğu ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: (secondsRemaining + 1) /
                          AppConstants.qrRefreshIntervalSeconds,
                      end: secondsRemaining /
                          AppConstants.qrRefreshIntervalSeconds,
                    ),
                    duration: const Duration(seconds: 1),
                    curve: Curves.linear,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        backgroundColor:
                            AppColors.surfaceLight.withValues(alpha: 0.5),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(timerColor),
                        minHeight: 4,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Süresi dolmuş üyelik: Yenileme uyarısı gösterir.
  Widget _buildExpiredView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingXLarge),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_outline,
              color: AppColors.error,
              size: 48,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Üyeliğinizi Yenileyin',
            style: AppTextStyles.h2.copyWith(color: AppColors.error),
          ),
          const SizedBox(height: 12),
          Text(
            'QR kod oluşturabilmek için aktif bir\nüyelik paketiniz olmalıdır.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Lütfen resepsiyon ile iletişime geçin.',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
