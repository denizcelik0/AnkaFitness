import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/date_utils.dart';
import '../data/models/app_user.dart';
import 'animated_gradient_border.dart';

/// Premium üyelik bilgi kartı.
/// Glassmorphism efekti, animated gradient border ve zengin gösterim.
class MembershipCard extends StatelessWidget {
  final AppUser user;

  const MembershipCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isActive = user.isMembershipActive;
    final remaining = user.remainingDays;

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          decoration: BoxDecoration(
            gradient: isActive ? AppColors.glassGradient : null,
            color: isActive ? null : AppColors.card,
            borderRadius:
                BorderRadius.circular(AppConstants.borderRadiusLarge),
            border: Border.all(
              color: isActive
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.error.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Durum Etiketi ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(
                          AppConstants.borderRadiusSmall),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive ? Icons.check_circle : Icons.cancel,
                          color:
                              isActive ? AppColors.success : AppColors.error,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isActive ? 'AKTİF' : 'SÜRESİ DOLMUŞ',
                          style: AppTextStyles.label.copyWith(
                            color: isActive
                                ? AppColors.success
                                : AppColors.error,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.primaryGradient.createShader(bounds),
                    child: const Icon(
                      Icons.fitness_center,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ── Paket Adı ──
              Text(
                user.packageName ?? 'Paket Atanmamış',
                style: AppTextStyles.h2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),

              // ── Bitiş Tarihi ──
              if (user.membershipEnd != null) ...[
                Text(
                  'Bitiş: ${AppDateUtils.formatLong(user.membershipEnd!)}',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 20),
              ],

              // ── Kalan Gün ──
              if (isActive)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TweenAnimationBuilder<int>(
                      tween: IntTween(begin: 0, end: remaining),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return Text(
                          '$value',
                          style: AppTextStyles.membershipDays,
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'gün kaldı',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );

    // Aktif üyelikler için animated gradient border
    if (isActive) {
      return AnimatedGradientBorder(
        borderRadius: AppConstants.borderRadiusLarge,
        borderWidth: 1.5,
        colors: [
          AppColors.primary.withValues(alpha: 0.6),
          AppColors.secondary.withValues(alpha: 0.4),
          AppColors.accent.withValues(alpha: 0.3),
          AppColors.primary.withValues(alpha: 0.6),
        ],
        child: card,
      );
    }

    return card;
  }
}
