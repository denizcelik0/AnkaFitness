import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/user_repository.dart';
import 'viewmodels/admin_viewmodel.dart';
import 'viewmodels/auth_viewmodel.dart';

import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';

/// Uygulama giriş noktası.
/// Firebase başlatma ve Provider ağacı konfigürasyonu.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('tr_TR', null);

  // Dikey yönlendirme kilitle
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Durum çubuğu stili
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Firebase başlat
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Repository'ler (singleton)
  final authRepo = AuthRepository();
  final userRepo = UserRepository();

  runApp(
    MultiProvider(
      providers: [
        // Repository'leri alt widget'lara sağla
        Provider<AuthRepository>.value(value: authRepo),
        Provider<UserRepository>.value(value: userRepo),

        // Auth ViewModel (tüm uygulama boyunca yaşar)
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(
            authRepo: authRepo,
            userRepo: userRepo,
          ),
        ),

        // Admin ViewModel
        ChangeNotifierProvider<AdminViewModel>(
          create: (_) => AdminViewModel(
            userRepo: userRepo,
            authRepo: authRepo,
          ),
        ),
      ],
      child: const QrPrototypeApp(),
    ),
  );
}
