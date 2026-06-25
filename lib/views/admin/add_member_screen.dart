import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/utils/date_utils.dart';
import '../../viewmodels/admin_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Yeni üye ekleme ekranı.
class AddMemberScreen extends StatefulWidget {
  const AddMemberScreen({super.key});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _endDateController = TextEditingController();

  String? _selectedPackage;
  DateTime? _membershipEnd;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminVM = context.watch<AdminViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni Üye Ekle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.go('/admin'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Bilgi Başlığı ──
              Text('Üye Bilgileri', style: AppTextStyles.h3),
              const SizedBox(height: 4),
              Text(
                'Yeni üyenin bilgilerini doldurun.',
                style: AppTextStyles.bodySmall,
              ),
              const SizedBox(height: 24),

              // ── Ad Soyad ──
              CustomTextField(
                controller: _nameController,
                label: 'Ad Soyad',
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ad soyad gerekli' : null,
              ),
              const SizedBox(height: 16),

              // ── E-posta ──
              CustomTextField(
                controller: _emailController,
                label: 'E-posta',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'E-posta gerekli';
                  if (!v.contains('@')) return 'Geçerli e-posta girin';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // ── Telefon ──
              CustomTextField(
                controller: _phoneController,
                label: 'Telefon',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // ── Şifre ──
              CustomTextField(
                controller: _passwordController,
                label: 'Şifre (İlk giriş için)',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Şifre gerekli';
                  if (v.length < 6) return 'En az 6 karakter';
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // ── Üyelik Bilgileri ──
              const Divider(color: AppColors.divider),
              const SizedBox(height: 16),
              Text('Üyelik Bilgileri', style: AppTextStyles.h3),
              const SizedBox(height: 16),

              // ── Paket Seçimi ──
              DropdownButtonFormField<String>(
                initialValue: _selectedPackage,
                decoration: InputDecoration(
                  labelText: 'Üyelik Paketi',
                  prefixIcon: const Icon(Icons.inventory_2_outlined,
                      color: AppColors.textHint, size: 22),
                  filled: true,
                  fillColor: AppColors.surfaceLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
                dropdownColor: AppColors.card,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 15),
                items: adminVM.packages
                    .map((pkg) => DropdownMenuItem(
                          value: pkg.name,
                          child: Text(
                              '${pkg.name} (${pkg.durationLabel})'),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedPackage = val;
                    // Otomatik bitiş tarihi hesapla
                    final pkg =
                        adminVM.packages.where((p) => p.name == val).first;
                    _membershipEnd =
                        DateTime.now().add(Duration(days: pkg.durationDays));
                    _endDateController.text =
                        AppDateUtils.formatShort(_membershipEnd!);
                  });
                },
                validator: (v) => v == null ? 'Paket seçin' : null,
              ),
              const SizedBox(height: 16),

              // ── Bitiş Tarihi ──
              CustomTextField(
                controller: _endDateController,
                label: 'Üyelik Bitiş Tarihi',
                prefixIcon: Icons.calendar_today_outlined,
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (v) => v == null || v.isEmpty
                    ? 'Bitiş tarihi gerekli'
                    : null,
              ),
              const SizedBox(height: 32),

              // ── Hata / Başarı Mesajları ──
              if (adminVM.error != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.3)),
                  ),
                  child: Text(adminVM.error!,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.error)),
                ),
                const SizedBox(height: 16),
              ],

              // ── Kaydet Butonu ──
              PrimaryButton(
                text: 'Üyeyi Kaydet',
                icon: Icons.save,
                isLoading: adminVM.isLoading,
                onPressed: () => _handleSave(adminVM),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _membershipEnd ?? DateTime.now().add(const Duration(days: 30)),
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
      setState(() {
        _membershipEnd = picked;
        _endDateController.text = AppDateUtils.formatShort(picked);
      });
    }
  }

  Future<void> _handleSave(AdminViewModel adminVM) async {
    if (!_formKey.currentState!.validate()) return;
    if (_membershipEnd == null) return;

    adminVM.clearMessages();
    final success = await adminVM.addMember(
      email: _emailController.text,
      password: _passwordController.text,
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      packageName: _selectedPackage!,
      membershipEnd: _membershipEnd!,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_nameController.text} başarıyla kaydedildi!'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go('/admin');
    }
  }
}
