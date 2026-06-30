import 'package:cloud_firestore/cloud_firestore.dart';

/// Giriş kaydı modeli.
/// Firestore 'attendance' koleksiyonundaki dokümanları temsil eder.
class AttendanceRecord {
  final String id;
  final String uid;
  final String fullName;
  final DateTime checkInTime;
  final bool verifiedByAdmin;

  const AttendanceRecord({
    required this.id,
    required this.uid,
    required this.fullName,
    required this.checkInTime,
    this.verifiedByAdmin = true,
  });

  /// Firestore dokümanından AttendanceRecord oluşturur.
  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AttendanceRecord(
      id: doc.id,
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? '',
      checkInTime:
          (data['checkInTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      verifiedByAdmin: data['verifiedByAdmin'] ?? true,
    );
  }

  /// AttendanceRecord'ı Firestore dokümanına dönüştürür.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'fullName': fullName,
      'checkInTime': Timestamp.fromDate(checkInTime),
      'verifiedByAdmin': verifiedByAdmin,
    };
  }
}
