import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/date_utils.dart';
import '../data/models/app_user.dart';

/// Üyelik bilgi kartı.
/// Paket adı, kalan süre ve durum gösterir.
class MembershipCard extends StatelessWidget {
  final AppUser user;

  const MembershipCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isActive = user.isMembershipActive;
    final remaining = user.remainingDays;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: isActive ? AppColors.cardGradient : null,
        color: isActive ? null : AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
        border: Border.all(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.error.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Durum Etiketi ──
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.error.withValues(alpha: 0.15),
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isActive ? Icons.check_circle : Icons.cancel,
                      color: isActive ? AppColors.success : AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isActive ? 'AKTİF' : 'SÜRESİ DOLMUŞ',
                      style: AppTextStyles.label.copyWith(
                        color:
                            isActive ? AppColors.success : AppColors.error,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Icon(
                Icons.fitness_center,
                color: AppColors.primary.withValues(alpha: 0.5),
                size: 28,
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
                Text(
                  '$remaining',
                  style: AppTextStyles.membershipDays,
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
    );
  }
}
