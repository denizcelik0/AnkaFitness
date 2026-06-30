import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/primary_button.dart';

/// Premium giriş ekranı.
/// Glassmorphism form kartı, animasyonlu gradient arka plan ve
/// pulse glow logo ile modern tasarım.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVM = context.watch<AuthViewModel>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.paddingLarge),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // ── Animasyonlu Logo ──
                      AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                      alpha: 0.3 * _pulseAnimation.value),
                                  blurRadius: 30 * _pulseAnimation.value,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: AppColors.secondary.withValues(
                                      alpha: 0.15 * _pulseAnimation.value),
                                  blurRadius: 50 * _pulseAnimation.value,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(
                            Icons.fitness_center,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // ── Başlık ──
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppColors.primaryGradient.createShader(bounds),
                        child: Text(
                          'QR Prototype',
                          style: GoogleFonts.inter(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hesabınıza giriş yapın',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 40),

                      // ── Glassmorphism Form Kartı ──
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                            AppConstants.borderRadiusLarge),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(
                                AppConstants.paddingLarge),
                            decoration: BoxDecoration(
                              gradient: AppColors.glassGradient,
                              borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadiusLarge),
                              border: Border.all(
                                color:
                                    Colors.white.withValues(alpha: 0.08),
                                width: 1,
                              ),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  // ── Hata Mesajı ──
                                  if (authVM.error != null) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: AppColors.error
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.error
                                              .withValues(alpha: 0.3),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.error_outline,
                                              color: AppColors.error,
                                              size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              authVM.error!,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppColors.error,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                  ],

                                  // ── Email ──
                                  CustomTextField(
                                    controller: _emailController,
                                    label: 'E-posta',
                                    hint: 'ornek@email.com',
                                    prefixIcon: Icons.email_outlined,
                                    keyboardType:
                                        TextInputType.emailAddress,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'E-posta adresi gerekli';
                                      }
                                      if (!value.contains('@')) {
                                        return 'Geçerli bir e-posta girin';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // ── Şifre ──
                                  CustomTextField(
                                    controller: _passwordController,
                                    label: 'Şifre',
                                    prefixIcon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons
                                                .visibility_off_outlined
                                            : Icons
                                                .visibility_outlined,
                                        color: AppColors.textHint,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword =
                                              !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value == null ||
                                          value.isEmpty) {
                                        return 'Şifre gerekli';
                                      }
                                      if (value.length < 6) {
                                        return 'Şifre en az 6 karakter olmalı';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 32),

                                  // ── Giriş Butonu ──
                                  PrimaryButton(
                                    text: 'Giriş Yap',
                                    icon: Icons.login,
                                    isLoading: authVM.isLoading,
                                    onPressed: () =>
                                        _handleLogin(authVM),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthViewModel authVM) async {
    if (!_formKey.currentState!.validate()) return;
    authVM.clearError();
    await authVM.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  }
}
