import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/app_user.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';

/// Kimlik doğrulama ve oturum durumu yönetimi.
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepo;
  final UserRepository _userRepo;

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _userSubscription;

  AuthViewModel({
    required AuthRepository authRepo,
    required UserRepository userRepo,
  })  : _authRepo = authRepo,
        _userRepo = userRepo {
    _initAuthListener();
  }

  // ── Getter'lar ──
  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.role.value == 'admin';

  /// Firebase Auth oturum değişikliklerini dinler.
  void _initAuthListener() {
    _authRepo.authStateChanges.listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _listenToUserData(firebaseUser.uid);
      } else {
        _userSubscription?.cancel();
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  /// Firestore'daki kullanıcı verisini gerçek zamanlı dinler.
  void _listenToUserData(String uid) {
    _userSubscription?.cancel();
    _userSubscription = _userRepo.watchUser(uid).listen((appUser) {
      _currentUser = appUser;
      notifyListeners();
    });
  }

  /// Email ve şifre ile giriş yapar.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authRepo.signInWithEmail(email: email, password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = _mapFirebaseError(e.code);
      notifyListeners();
      return false;
    } catch (e) {
      _error = 'Beklenmeyen bir hata oluştu.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Oturumu kapatır.
  Future<void> signOut() async {
    _userSubscription?.cancel();
    await _authRepo.signOut();
    _currentUser = null;
    notifyListeners();
  }

  /// Hata mesajını temizler.
  void clearError() => _clearError();

  // ── Yardımcı Metotlar ──

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Firebase hata kodlarını Türkçe mesajlara çevirir.
  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Bu e-posta ile kayıtlı kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Şifre hatalı. Lütfen tekrar deneyin.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'too-many-requests':
        return 'Çok fazla deneme yapıldı. Lütfen bekleyin.';
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      default:
        return 'Giriş yapılamadı. Hata kodu: $code';
    }
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
