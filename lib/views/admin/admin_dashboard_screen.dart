import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Admin ana panel ekranı.
/// Üye listesi, istatistikler ve hızlı aksiyonlar.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yönetici Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Çıkış Yap',
            onPressed: () => _confirmLogout(context, authVM),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          // Stream tabanlı olduğu için otomatik güncellenir
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          children: [
            // ── Hoşgeldin Mesajı ──
            Text(
              'Hoş geldin, ${authVM.currentUser?.fullName ?? 'Admin'} 👋',
              style: AppTextStyles.h2,
            ),
            const SizedBox(height: 8),
            Text(
              'İşte spor salonunun genel durumu.',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),

            // ── İstatistik Kartları ──
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Toplam Üye',
                    value: '${adminVM.totalMembers}',
                    icon: Icons.people_alt_rounded,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Aktif Üye',
                    value: '${adminVM.activeMembers}',
                    icon: Icons.check_circle_outline,
                    color: AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Pasif Üye',
                    value: '${adminVM.totalMembers - adminVM.activeMembers}',
                    icon: Icons.cancel_outlined,
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Paketler',
                    value: '${adminVM.packages.length}',
                    icon: Icons.inventory_2_outlined,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Üye Listesi ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Üyeler', style: AppTextStyles.h3),
                TextButton.icon(
                  onPressed: () => context.go('/admin/add-member'),
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Yeni Üye'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (adminVM.members.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingXLarge),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius:
                      BorderRadius.circular(AppConstants.borderRadius),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(Icons.people_outline,
                        color: AppColors.textHint, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'Henüz kayıtlı üye yok.',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'İlk üyeyi eklemek için "Yeni Üye" butonuna tıklayın.',
                      style: AppTextStyles.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...adminVM.members.map((member) => _MemberListTile(
                    member: member,
                    onTap: () => context.go('/admin/member/${member.uid}'),
                  )),
          ],
        ),
      ),
      // ── FAB: Yeni Üye ──
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/admin/add-member'),
        icon: const Icon(Icons.person_add),
        label: const Text('Yeni Üye'),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Çıkış Yap', style: AppTextStyles.h3),
        content: Text(
          'Oturumunuzu kapatmak istediğinize emin misiniz?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              authVM.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}

/// İstatistik kartı bileşeni.
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.h2.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

/// Üye listesi öğesi bileşeni.
class _MemberListTile extends StatelessWidget {
  final dynamic member;
  final VoidCallback onTap;

  const _MemberListTile({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = member.isMembershipActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                backgroundColor: isActive
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.error.withValues(alpha: 0.2),
                child: Text(
                  member.fullName.isNotEmpty
                      ? member.fullName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: isActive ? AppColors.primary : AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // İsim & Paket
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.fullName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      member.packageName ?? 'Paket yok',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              // Durum & Kalan gün
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.success.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      isActive ? 'Aktif' : 'Pasif',
                      style: TextStyle(
                        color: isActive ? AppColors.success : AppColors.error,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isActive) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${member.remainingDays} gün',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right,
                  color: AppColors.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
