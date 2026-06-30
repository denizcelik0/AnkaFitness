/// QR Prototype uygulama sabitleri.
class AppConstants {
  AppConstants._();

  // ── Genel ──
  static const String appName = 'QR Prototype';
  static const String appVersion = '1.0.0';

  // ── QR Kod Ayarları ──
  /// QR kodun yenilenme süresi (saniye).
  static const int qrRefreshIntervalSeconds = 30;

  /// QR kod hash'leme için secret key.
  /// Üretim ortamında bu değer güvenli bir yerde (env variable vb.) saklanmalı.
  static const String qrSecretKey = 'anka_fitness_qr_secret_2025';

  // ── Firestore Koleksiyon Adları ──
  static const String usersCollection = 'users';
  static const String packagesCollection = 'packages';
  static const String attendanceCollection = 'attendance';

  // ── Kullanıcı Rolleri ──
  static const String roleAdmin = 'admin';
  static const String roleMember = 'member';

  // ── Animasyon Süreleri ──
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 500);

  // ── UI Sabitleri ──
  static const double borderRadius = 16.0;
  static const double borderRadiusSmall = 12.0;
  static const double borderRadiusLarge = 24.0;
  static const double cardElevation = 0.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
}
