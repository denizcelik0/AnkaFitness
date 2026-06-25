import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../data/models/app_user.dart';
import '../data/repositories/user_repository.dart';

/// Üye paneli iş mantığı.
/// Üyelik bilgisi görüntüleme ve dinamik QR kod üretimi.
class MemberViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  final String _uid;

  AppUser? _user;
  String _qrData = '';
  int _qrSecondsRemaining = AppConstants.qrRefreshIntervalSeconds;
  Timer? _qrTimer;
  StreamSubscription? _userSubscription;

  MemberViewModel({
    required UserRepository userRepo,
    required String uid,
  })  : _userRepo = userRepo,
        _uid = uid {
    _initUserStream();
    _startQrTimer();
  }

  // ── Getter'lar ──
  AppUser? get user => _user;
  String get qrData => _qrData;
  int get qrSecondsRemaining => _qrSecondsRemaining;
  bool get isMembershipActive => _user?.isMembershipActive ?? false;
  int get remainingDays => _user?.remainingDays ?? 0;

  /// Firestore'daki kullanıcı verisini gerçek zamanlı dinler.
  void _initUserStream() {
    _userSubscription = _userRepo.watchUser(_uid).listen((appUser) {
      _user = appUser;
      if (appUser != null && appUser.isMembershipActive) {
        _generateQrCode();
      }
      notifyListeners();
    });
  }

  /// Dinamik QR kod üretim timer'ını başlatır.
  void _startQrTimer() {
    _generateQrCode();
    _qrTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _qrSecondsRemaining--;

      if (_qrSecondsRemaining <= 0) {
        _qrSecondsRemaining = AppConstants.qrRefreshIntervalSeconds;
        _generateQrCode();
      }

      notifyListeners();
    });
  }

  /// Zamana bağlı dinamik QR kod verisi üretir.
  /// HMAC-SHA256 kullanarak güvenli bir hash oluşturur.
  void _generateQrCode() {
    // 30 saniyelik pencere hesaplama
    final timeWindow = DateTime.now().millisecondsSinceEpoch ~/
        (AppConstants.qrRefreshIntervalSeconds * 1000);

    // Hash verisi: uid + zaman penceresi
    final message = '$_uid|$timeWindow';
    final key = utf8.encode(AppConstants.qrSecretKey);
    final bytes = utf8.encode(message);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);

    // QR kod verisi: uid:hash (turnike tarafı doğrulama için)
    _qrData = '$_uid:${digest.toString()}';
  }

  @override
  void dispose() {
    _qrTimer?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }
}
