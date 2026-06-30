import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../viewmodels/auth_viewmodel.dart';

/// Premium admin ana panel ekranı.
/// Glassmorphism istatistik kartları, QR tarama aksiyonu ve üye listesi.
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              slivers: [
                // ── Custom App Bar ──
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.paddingLarge,
                      AppConstants.paddingMedium,
                      AppConstants.paddingLarge,
                      0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yönetici Paneli',
                                style: AppTextStyles.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    AppColors.primaryGradient
                                        .createShader(bounds),
                                child: Text(
                                  'Hoş geldin, ${authVM.currentUser?.fullName.split(' ').first ?? 'Admin'}',
                                  style: GoogleFonts.inter(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight
                                  .withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.06),
                              ),
                            ),
                            child: const Icon(
                              Icons.logout_rounded,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          onPressed: () =>
                              _confirmLogout(context, authVM),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── İçerik ──
                SliverPadding(
                  padding:
                      const EdgeInsets.all(AppConstants.paddingMedium),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),

                      // ── Giriş Kayıtları ──
                      _ActionCard(
                        icon: Icons.list_alt_rounded,
                        label: 'Giriş Kayıtları',
                        color: AppColors.accent,
                        badge: adminVM.todayAttendanceCount > 0
                            ? '${adminVM.todayAttendanceCount}'
                            : null,
                        onTap: () =>
                            context.go('/admin/attendance'),
                      ),
                      const SizedBox(height: 20),

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
                              value:
                                  '${adminVM.totalMembers - adminVM.activeMembers}',
                              icon: Icons.cancel_outlined,
                              color: AppColors.error,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _StatCard(
                              title: 'Bugün Giriş',
                              value:
                                  '${adminVM.todayAttendanceCount}',
                              icon: Icons.directions_walk_rounded,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      // ── Üye Listesi ──
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Üyeler', style: AppTextStyles.h3),
                          TextButton.icon(
                            onPressed: () =>
                                context.go('/admin/add-member'),
                            icon: const Icon(Icons.person_add,
                                size: 18),
                            label: const Text('Yeni Üye'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (adminVM.members.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(
                              AppConstants.paddingXLarge),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius),
                            border:
                                Border.all(color: AppColors.border),
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
                        ...adminVM.members
                            .map((member) => _MemberListTile(
                                  member: member,
                                  onTap: () => context.go(
                                      '/admin/member/${member.uid}'),
                                )),

                      const SizedBox(height: 80),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // ── FAB: Yeni Üye ──
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.go('/admin/add-member'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.person_add, color: Colors.white),
          label: const Text(
            'Yeni Üye',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context, AuthViewModel authVM) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
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

/// Aksiyon kartı bileşeni (QR Tara, Giriş Kayıtları).
class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(AppConstants.borderRadiusLarge),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              gradient: AppColors.glassGradient,
              borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusLarge),
              border: Border.all(
                color: color.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge!,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium istatistik kartı bileşeni.
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
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 14),
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, val, _) {
              return Text(
                '$val',
                style: AppTextStyles.h2.copyWith(color: color),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(title, style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

/// Premium üye listesi öğesi bileşeni.
class _MemberListTile extends StatelessWidget {
  final dynamic member;
  final VoidCallback onTap;

  const _MemberListTile({required this.member, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = member.isMembershipActive;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius:
              BorderRadius.circular(AppConstants.borderRadius),
          child: Container(
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
                // Avatar — gradient ring
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: isActive
                        ? LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondary,
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              AppColors.error
                                  .withValues(alpha: 0.5),
                              AppColors.error
                                  .withValues(alpha: 0.3),
                            ],
                          ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.card,
                    child: Text(
                      member.fullName.isNotEmpty
                          ? member.fullName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.error,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.success
                                .withValues(alpha: 0.15)
                            : AppColors.error
                                .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isActive ? 'Aktif' : 'Pasif',
                        style: TextStyle(
                          color: isActive
                              ? AppColors.success
                              : AppColors.error,
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
      ),
    );
  }
}
