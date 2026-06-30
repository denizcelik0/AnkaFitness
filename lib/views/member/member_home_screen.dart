import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/member_viewmodel.dart';
import '../../data/repositories/user_repository.dart';
import '../../widgets/membership_card.dart';
import '../../widgets/dynamic_qr_widget.dart';
import '../../widgets/bottom_nav_bar.dart';

/// Premium üye ana ekranı.
/// Dinamik hoşgeldin mesajı, glassmorphism kartlar ve QR kod.
class MemberHomeScreen extends StatefulWidget {
  const MemberHomeScreen({super.key});

  @override
  State<MemberHomeScreen> createState() => _MemberHomeScreenState();
}

class _MemberHomeScreenState extends State<MemberHomeScreen> {
  int _currentNavIndex = 0;
  MemberViewModel? _memberVM;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_memberVM == null) {
      final authVM = context.read<AuthViewModel>();
      final userRepo = context.read<UserRepository>();
      if (authVM.currentUser != null) {
        _memberVM = MemberViewModel(
          userRepo: userRepo,
          uid: authVM.currentUser!.uid,
        );
      }
    }
  }

  @override
  void dispose() {
    _memberVM?.dispose();
    super.dispose();
  }

  /// Saate göre dinamik karşılama mesajı.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'İyi geceler';
    if (hour < 12) return 'Günaydın';
    if (hour < 17) return 'İyi günler';
    if (hour < 21) return 'İyi akşamlar';
    return 'İyi geceler';
  }

  /// Saate göre motivasyon mesajı.
  String _getMotivation() {
    final hour = DateTime.now().hour;
    if (hour < 6) return 'Erken kuş kalkar! 🌟';
    if (hour < 12) return 'Enerjin doruklarda! 💪';
    if (hour < 17) return 'Öğle antrenmanı zamanı! 🔥';
    if (hour < 21) return 'Akşam antrenmanına hazır mısın? 🏋️';
    return 'Gece kuşu antrenmanı! 🌙';
  }

  @override
  Widget build(BuildContext context) {
    if (_memberVM == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _memberVM!,
      builder: (context, _) {
        return Scaffold(
          extendBody: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.backgroundGradient,
            ),
            child: SafeArea(
              bottom: false,
              child: _currentNavIndex == 0
                  ? _buildHomePage()
                  : _buildWorkoutPage(),
            ),
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentNavIndex,
            onTap: (index) {
              if (index == 1) {
                context.go('/workout');
                return;
              }
              setState(() => _currentNavIndex = index);
            },
          ),
        );
      },
    );
  }

  Widget _buildHomePage() {
    final user = _memberVM!.user;
    if (user == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return CustomScrollView(
      slivers: [
        // ── Custom App Bar ──
        SliverAppBar(
          expandedHeight: 120,
          floating: true,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.paddingLarge,
                AppConstants.paddingMedium,
                AppConstants.paddingLarge,
                0,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: AppTextStyles.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        ShaderMask(
                          shaderCallback: (bounds) =>
                              AppColors.primaryGradient
                                  .createShader(bounds),
                          child: Text(
                            user.fullName.split(' ').first,
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getMotivation(),
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Çıkış butonu
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
                    onPressed: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── İçerik ──
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.paddingMedium,
            0,
            AppConstants.paddingMedium,
            100, // BottomNavBar için alan
          ),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 8),

              // ── Üyelik Kartı ──
              MembershipCard(user: user),
              const SizedBox(height: 24),

              // ── QR Kod Alanı ──
              DynamicQrWidget(
                qrData: _memberVM!.qrData,
                secondsRemaining: _memberVM!.qrSecondsRemaining,
                isMembershipActive: _memberVM!.isMembershipActive,
              ),
              const SizedBox(height: 24),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkoutPage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center_rounded,
            size: 80,
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 20),
          Text('Çok Yakında...', style: AppTextStyles.h2),
          const SizedBox(height: 8),
          Text(
            'Antrenman programları ve takibi\nyakında burada olacak.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium,
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    final authVM = context.read<AuthViewModel>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
