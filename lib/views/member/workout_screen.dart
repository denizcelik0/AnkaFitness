import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../widgets/bottom_nav_bar.dart';

/// Antrenman ekranı — placeholder.
/// Projenin ilk fazında geliştirilmeyecek.
class WorkoutScreen extends StatelessWidget {
  const WorkoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Antrenman'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingXLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Animasyonlu İkon ──
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.0),
                duration: const Duration(seconds: 2),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.fitness_center_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Başlık ──
              Text(
                'Çok Yakında...',
                style: AppTextStyles.h1.copyWith(
                  foreground: Paint()
                    ..shader = AppColors.primaryGradient
                        .createShader(const Rect.fromLTWH(0, 0, 250, 50)),
                ),
              ),
              const SizedBox(height: 16),

              // ── Açıklama ──
              Text(
                'Kişiselleştirilmiş antrenman programları,\negzersiz takibi ve ilerleme analizleri\nyakında bu bölümde sizlerle olacak.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 32),

              // ── Özellik Listesi ──
              _FeaturePreview(
                icon: Icons.list_alt_rounded,
                text: 'Özel Antrenman Programları',
              ),
              const SizedBox(height: 12),
              _FeaturePreview(
                icon: Icons.show_chart_rounded,
                text: 'İlerleme Takibi & Grafikler',
              ),
              const SizedBox(height: 12),
              _FeaturePreview(
                icon: Icons.timer_rounded,
                text: 'Set & Tekrar Sayaçları',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            context.go('/member');
          }
        },
      ),
    );
  }
}

/// Özellik önizleme satırı.
class _FeaturePreview extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeaturePreview({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 14),
          Text(
            text,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
