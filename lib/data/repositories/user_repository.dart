import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import '../../core/constants/app_constants.dart';
import '../models/app_user.dart';
import '../models/attendance_record.dart';
import '../models/membership_package.dart';

/// Firestore kullanıcı ve paket işlemlerini yöneten repository.
class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  /// ─── Kullanıcı İşlemleri ───

  /// Yeni kullanıcı dokümanı oluşturur.
  Future<void> createUser(AppUser user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toFirestore());
  }

  /// Kullanıcı bilgilerini uid ile getirir.
  Future<AppUser?> getUserById(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Kullanıcı verilerini gerçek zamanlı dinler.
  Stream<AppUser?> watchUser(String uid) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc) : null);
  }

  /// Tüm üyeleri listeler (Admin için).
  Stream<List<AppUser>> watchAllMembers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: AppConstants.roleMember)
        .orderBy('fullName')
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList());
  }

  /// Kullanıcı bilgilerini günceller.
  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  /// Üyelik süresini uzatır.
  Future<void> extendMembership({
    required String uid,
    required DateTime newEndDate,
    String? packageName,
  }) async {
    final updateData = <String, dynamic>{
      'membershipEnd': Timestamp.fromDate(newEndDate),
      'isActive': true,
    };
    if (packageName != null) {
      updateData['packageName'] = packageName;
    }
    await updateUser(uid, updateData);
  }

  /// ─── Paket İşlemleri ───

  /// Yeni paket tanımlar.
  Future<void> createPackage(MembershipPackage package) async {
    await _firestore
        .collection(AppConstants.packagesCollection)
        .add(package.toFirestore());
  }

  /// Tüm paketleri listeler.
  Stream<List<MembershipPackage>> watchAllPackages() {
    return _firestore
        .collection(AppConstants.packagesCollection)
        .orderBy('durationDays')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MembershipPackage.fromFirestore(doc))
            .toList());
  }

  /// Paket siler.
  Future<void> deletePackage(String packageId) async {
    await _firestore
        .collection(AppConstants.packagesCollection)
        .doc(packageId)
        .delete();
  }

  /// ─── Giriş Kaydı (Attendance) İşlemleri ───

  /// Giriş kaydını Firestore'a yazar.
  Future<void> recordAttendance(AttendanceRecord record) async {
    await _firestore
        .collection(AppConstants.attendanceCollection)
        .add(record.toFirestore());
  }

  /// Bugünkü giriş kayıtlarını gerçek zamanlı dinler.
  Stream<List<AttendanceRecord>> watchTodayAttendance() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return _firestore
        .collection(AppConstants.attendanceCollection)
        .where('checkInTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('checkInTime', isLessThan: Timestamp.fromDate(endOfDay))
        .orderBy('checkInTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AttendanceRecord.fromFirestore(doc))
            .toList());
  }

  /// QR kod verisini doğrular.
  /// QR veri formatı: "uid:hash"
  /// HMAC-SHA256 ile zaman penceresine dayalı hash kontrolü.
  /// Başarılıysa kullanıcının uid'sini döner, başarısızsa null.
  String? verifyQrCode(String qrData) {
    final parts = qrData.split(':');
    if (parts.length != 2) return null;

    final uid = parts[0];
    final receivedHash = parts[1];

    // Şu anki ve bir önceki zaman penceresini kontrol et (tolerans)
    final now = DateTime.now().millisecondsSinceEpoch;
    final windowSize = AppConstants.qrRefreshIntervalSeconds * 1000;

    for (int offset = 0; offset <= 1; offset++) {
      final timeWindow = (now ~/ windowSize) - offset;
      final message = '$uid|$timeWindow';
      final key = utf8.encode(AppConstants.qrSecretKey);
      final bytes = utf8.encode(message);
      final hmacSha256 = Hmac(sha256, key);
      final digest = hmacSha256.convert(bytes);

      if (digest.toString() == receivedHash) {
        return uid;
      }
    }

    return null;
  }
}

