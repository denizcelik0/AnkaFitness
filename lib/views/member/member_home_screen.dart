import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

/// Üye ana ekranı.
/// Üyelik bilgisi, dinamik QR kod ve alt gezinme.
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

  @override
  Widget build(BuildContext context) {
    if (_memberVM == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return ListenableBuilder(
      listenable: _memberVM!,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('AnkaFitness'),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout_rounded),
                tooltip: 'Çıkış',
                onPressed: () => _confirmLogout(context),
              ),
            ],
          ),
          body: _currentNavIndex == 0
              ? _buildHomePage()
              : _buildWorkoutPage(),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentNavIndex,
            onTap: (index) {
              if (index == 1) {
                // Antrenman sekmesine geçiş
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hoşgeldin ──
          Text(
            'Merhaba, ${user.fullName.split(' ').first} 👋',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 4),
          Text(
            'Bugün de antrenman zamanı!',
            style: AppTextStyles.bodyMedium,
          ),
          const SizedBox(height: 24),

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
        ],
      ),
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
