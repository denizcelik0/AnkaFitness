import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../viewmodels/admin_viewmodel.dart';

/// Giriş kayıtları (yoklama) ekranı.
/// Bugünkü tüm giriş kayıtlarını gerçek zamanlı listeler.
class AttendanceLogScreen extends StatelessWidget {
  const AttendanceLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();
    final records = adminVM.todayAttendance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Giriş Kayıtları'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: Column(
        children: [
          // ── Bugünkü Özet ──
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(AppConstants.paddingMedium),
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius:
                  BorderRadius.circular(AppConstants.borderRadiusLarge),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.directions_walk_rounded,
                    color: AppColors.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bugünkü Girişler',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${records.length}',
                        style: AppTextStyles.h1.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  AppDateUtils.formatShort(DateTime.now()),
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
          ),

          // ── Kayıt Listesi ──
          Expanded(
            child: records.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy_rounded,
                          size: 64,
                          color: AppColors.textHint.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz giriş kaydı yok',
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Üyeler QR kod okutarak giriş yaptığında\nburada görünecek.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingMedium,
                    ),
                    itemCount: records.length,
                    itemBuilder: (context, index) {
                      final record = records[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding:
                            const EdgeInsets.all(AppConstants.paddingMedium),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            // Avatar
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  AppColors.success.withValues(alpha: 0.15),
                              child: Text(
                                record.fullName.isNotEmpty
                                    ? record.fullName[0].toUpperCase()
                                    : '?',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // İsim
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    record.fullName,
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Giriş: ${AppDateUtils.formatDateTime(record.checkInTime).split(' ').last}',
                                    style: AppTextStyles.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            // Doğrulandı ikonu
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    color: AppColors.success,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Onaylı',
                                    style: AppTextStyles.caption.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
