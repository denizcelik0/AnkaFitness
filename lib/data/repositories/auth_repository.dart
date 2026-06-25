import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication işlemlerini yöneten repository.
class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Mevcut oturum açmış kullanıcıyı döndürür.
  User? get currentUser => _auth.currentUser;

  /// Oturum durumu değişikliklerini dinler.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Email ve şifre ile giriş yapar.
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Email ve şifre ile yeni kullanıcı oluşturur.
  /// Admin tarafından üye kaydı sırasında kullanılır.
  Future<UserCredential> createUserWithEmail({
    required String email,
    required String password,
  }) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Oturumu kapatır.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Şifre sıfırlama e-postası gönderir.
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}
