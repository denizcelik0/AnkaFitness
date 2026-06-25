import 'dart:async';
import 'package:flutter/material.dart';
import '../data/models/app_user.dart';
import '../data/models/membership_package.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../core/enums/user_role.dart';

/// Admin paneli iş mantığı.
/// Üye ekleme, düzenleme, paket yönetimi.
class AdminViewModel extends ChangeNotifier {
  final UserRepository _userRepo;
  final AuthRepository _authRepo;

  List<AppUser> _members = [];
  List<MembershipPackage> _packages = [];
  bool _isLoading = false;
  String? _error;
  String? _successMessage;
  StreamSubscription? _membersSubscription;
  StreamSubscription? _packagesSubscription;

  AdminViewModel({
    required UserRepository userRepo,
    required AuthRepository authRepo,
  })  : _userRepo = userRepo,
        _authRepo = authRepo {
    _initStreams();
  }

  // ── Getter'lar ──
  List<AppUser> get members => _members;
  List<MembershipPackage> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get successMessage => _successMessage;
  int get totalMembers => _members.length;
  int get activeMembers =>
      _members.where((m) => m.isMembershipActive).length;

  /// Üye ve paket stream'lerini başlatır.
  void _initStreams() {
    _membersSubscription = _userRepo.watchAllMembers().listen(
      (members) {
        _members = members;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Üyeler yüklenirken hata oluştu.';
        notifyListeners();
      },
    );

    _packagesSubscription = _userRepo.watchAllPackages().listen(
      (packages) {
        _packages = packages;
        notifyListeners();
      },
      onError: (e) {
        _error = 'Paketler yüklenirken hata oluştu.';
        notifyListeners();
      },
    );
  }

  /// Yeni üye kaydeder (Firebase Auth + Firestore).
  Future<bool> addMember({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String packageName,
    required DateTime membershipEnd,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      // Firebase Auth'da kullanıcı oluştur
      final credential = await _authRepo.createUserWithEmail(
        email: email,
        password: password,
      );

      // Firestore'da kullanıcı dokümanı oluştur
      final newUser = AppUser(
        uid: credential.user!.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        role: UserRole.member,
        packageName: packageName,
        membershipStart: DateTime.now(),
        membershipEnd: membershipEnd,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _userRepo.createUser(newUser);
      _successMessage = '$fullName başarıyla kaydedildi.';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Üye kaydı sırasında hata: ${e.toString()}';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Üyelik süresini uzatır.
  Future<bool> extendMembership({
    required String uid,
    required DateTime newEndDate,
    String? packageName,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      await _userRepo.extendMembership(
        uid: uid,
        newEndDate: newEndDate,
        packageName: packageName,
      );
      _successMessage = 'Üyelik süresi başarıyla güncellendi.';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Üyelik güncellenirken hata oluştu.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Yeni paket tanımlar.
  Future<bool> addPackage({
    required String name,
    required int durationDays,
    required double price,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      final package = MembershipPackage(
        id: '',
        name: name,
        durationDays: durationDays,
        price: price,
      );
      await _userRepo.createPackage(package);
      _successMessage = '"$name" paketi başarıyla oluşturuldu.';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Paket oluşturulurken hata oluştu.';
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Paket siler.
  Future<bool> deletePackage(String packageId) async {
    try {
      await _userRepo.deletePackage(packageId);
      _successMessage = 'Paket silindi.';
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Paket silinirken hata oluştu.';
      notifyListeners();
      return false;
    }
  }

  /// Mesajları temizler.
  void clearMessages() => _clearMessages();

  // ── Yardımcı Metotlar ──

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearMessages() {
    _error = null;
    _successMessage = null;
  }

  @override
  void dispose() {
    _membersSubscription?.cancel();
    _packagesSubscription?.cancel();
    super.dispose();
  }
}
