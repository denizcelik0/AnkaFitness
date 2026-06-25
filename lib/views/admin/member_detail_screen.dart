import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../data/models/app_user.dart';
import '../../data/repositories/user_repository.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../widgets/membership_card.dart';

/// Üye detay ve süre uzatma ekranı.
class MemberDetailScreen extends StatefulWidget {
  final String memberUid;

  const MemberDetailScreen({super.key, required this.memberUid});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  DateTime? _newEndDate;

  @override
  Widget build(BuildContext context) {
    final userRepo = context.read<UserRepository>();
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Üye Detayı'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: StreamBuilder<AppUser?>(
        stream: userRepo.watchUser(widget.memberUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final member = snapshot.data;
          if (member == null) {
            return Center(
              child: Text('Üye bulunamadı.', style: AppTextStyles.bodyMedium),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Üye Profil Başlığı ──
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor:
                            AppColors.primary.withValues(alpha: 0.2),
                        child: Text(
                          member.fullName.isNotEmpty
                              ? member.fullName[0].toUpperCase()
                              : '?',
                          style: AppTextStyles.h1.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(member.fullName, style: AppTextStyles.h2),
                      const SizedBox(height: 4),
                      Text(member.email, style: AppTextStyles.bodyMedium),
                      if (member.phone.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(member.phone, style: AppTextStyles.bodySmall),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Üyelik Kartı ──
                MembershipCard(user: member),
                const SizedBox(height: 24),

                // ── Bilgi Kartları ──
                _InfoRow(
                  icon: Icons.calendar_today,
                  label: 'Kayıt Tarihi',
                  value: AppDateUtils.formatLong(member.createdAt),
                ),
                const SizedBox(height: 8),
                if (member.membershipStart != null)
                  _InfoRow(
                    icon: Icons.play_arrow_rounded,
                    label: 'Üyelik Başlangıcı',
                    value:
                        AppDateUtils.formatLong(member.membershipStart!),
                  ),
                const SizedBox(height: 8),
                if (member.membershipEnd != null)
                  _InfoRow(
                    icon: Icons.flag_rounded,
                    label: 'Üyelik Bitişi',
                    value: AppDateUtils.formatLong(member.membershipEnd!),
                  ),

                const SizedBox(height: 32),
                const Divider(color: AppColors.divider),
                const SizedBox(height: 16),

                // ── Süre Uzatma ──
                Text('Üyelik Süresini Uzat', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                  'Yeni bitiş tarihi seçerek üyeliği uzatabilirsiniz.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 16),

                // Hızlı Uzatma Butonları
                Row(
                  children: [
                    _QuickExtendChip(
                      label: '+1 Ay',
                      onTap: () => _setExtendDate(30, member),
                    ),
                    const SizedBox(width: 8),
                    _QuickExtendChip(
                      label: '+3 Ay',
                      onTap: () => _setExtendDate(90, member),
                    ),
                    const SizedBox(width: 8),
                    _QuickExtendChip(
                      label: '+6 Ay',
                      onTap: () => _setExtendDate(180, member),
                    ),
                    const SizedBox(width: 8),
                    _QuickExtendChip(
                      label: '+1 Yıl',
                      onTap: () => _setExtendDate(365, member),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Tarih Seçici
                InkWell(
                  onTap: () => _pickDate(context, member),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.paddingMedium),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month,
                            color: AppColors.primary, size: 22),
                        const SizedBox(width: 12),
                        Text(
                          _newEndDate != null
                              ? AppDateUtils.formatLong(_newEndDate!)
                              : 'Manuel tarih seçin...',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: _newEndDate != null
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Uzat Butonu
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _newEndDate != null
                        ? () => _handleExtend(adminVM)
                        : null,
                    icon: const Icon(Icons.update),
                    label: const Text('Süreyi Güncelle'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _setExtendDate(int days, AppUser member) {
    final baseDate = member.isMembershipActive
        ? member.membershipEnd!
        : DateTime.now();
    setState(() {
      _newEndDate = baseDate.add(Duration(days: days));
    });
  }

  Future<void> _pickDate(BuildContext context, AppUser member) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _newEndDate ??
          (member.membershipEnd ?? DateTime.now())
              .add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.card,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _newEndDate = picked);
    }
  }

  Future<void> _handleExtend(AdminViewModel adminVM) async {
    if (_newEndDate == null) return;
    final success = await adminVM.extendMembership(
      uid: widget.memberUid,
      newEndDate: _newEndDate!,
    );
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Üyelik süresi güncellendi!'),
          backgroundColor: AppColors.success,
        ),
      );
      setState(() => _newEndDate = null);
    }
  }
}

/// Bilgi satırı bileşeni.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.bodySmall),
          const Spacer(),
          Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

/// Hızlı süre uzatma chip'i.
class _QuickExtendChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickExtendChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTextStyles.buttonSmall.copyWith(
                color: AppColors.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
