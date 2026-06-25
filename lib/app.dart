import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'viewmodels/auth_viewmodel.dart';

/// Uygulamanın kök widget'ı.
/// Tema ve navigasyon yapılandırmasını içerir.
class AnkaFitnessApp extends StatelessWidget {
  const AnkaFitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final router = AppRouter.router(authViewModel);

    return MaterialApp.router(
      title: 'AnkaFitness',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      routerConfig: router,
    );
  }
}
