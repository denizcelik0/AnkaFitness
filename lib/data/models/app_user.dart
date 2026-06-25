import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/enums/user_role.dart';

/// Uygulama kullanıcı modeli.
/// Firestore 'users' koleksiyonundaki dokümanları temsil eder.
class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final String phone;
  final UserRole role;
  final String? packageName;
  final DateTime? membershipStart;
  final DateTime? membershipEnd;
  final bool isActive;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.phone,
    required this.role,
    this.packageName,
    this.membershipStart,
    this.membershipEnd,
    this.isActive = true,
    required this.createdAt,
  });

  /// Firestore dokümanından AppUser oluşturur.
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phone: data['phone'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'member'),
      packageName: data['packageName'],
      membershipStart: (data['membershipStart'] as Timestamp?)?.toDate(),
      membershipEnd: (data['membershipEnd'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// AppUser'ı Firestore dokümanına dönüştürür.
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'phone': phone,
      'role': role.value,
      'packageName': packageName,
      'membershipStart': membershipStart != null
          ? Timestamp.fromDate(membershipStart!)
          : null,
      'membershipEnd':
          membershipEnd != null ? Timestamp.fromDate(membershipEnd!) : null,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Üyeliğin aktif olup olmadığını kontrol eder.
  bool get isMembershipActive {
    if (membershipEnd == null) return false;
    return membershipEnd!.isAfter(DateTime.now()) && isActive;
  }

  /// Kalan gün sayısını hesaplar.
  int get remainingDays {
    if (membershipEnd == null) return 0;
    final days = membershipEnd!.difference(DateTime.now()).inDays;
    return days < 0 ? 0 : days;
  }

  /// Immutable kopya oluşturur (güncellemeler için).
  AppUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phone,
    UserRole? role,
    String? packageName,
    DateTime? membershipStart,
    DateTime? membershipEnd,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      packageName: packageName ?? this.packageName,
      membershipStart: membershipStart ?? this.membershipStart,
      membershipEnd: membershipEnd ?? this.membershipEnd,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
