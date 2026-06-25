import 'package:cloud_firestore/cloud_firestore.dart';

/// Üyelik paketi modeli.
/// Firestore 'packages' koleksiyonundaki dokümanları temsil eder.
class MembershipPackage {
  final String id;
  final String name;
  final int durationDays;
  final double price;

  const MembershipPackage({
    required this.id,
    required this.name,
    required this.durationDays,
    required this.price,
  });

  /// Firestore dokümanından MembershipPackage oluşturur.
  factory MembershipPackage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MembershipPackage(
      id: doc.id,
      name: data['name'] ?? '',
      durationDays: data['durationDays'] ?? 30,
      price: (data['price'] ?? 0).toDouble(),
    );
  }

  /// MembershipPackage'ı Firestore dokümanına dönüştürür.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'durationDays': durationDays,
      'price': price,
    };
  }

  /// Paketin süresini okunabilir formatta döndürür.
  String get durationLabel {
    if (durationDays >= 365) return '${durationDays ~/ 365} Yıl';
    if (durationDays >= 30) return '${durationDays ~/ 30} Ay';
    return '$durationDays Gün';
  }
}
