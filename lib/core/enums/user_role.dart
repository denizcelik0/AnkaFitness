/// Kullanıcı rol tanımları.
enum UserRole {
  admin('admin'),
  member('member');

  const UserRole(this.value);
  final String value;

  /// String'den UserRole'e dönüşüm.
  static UserRole fromString(String role) {
    return UserRole.values.firstWhere(
      (e) => e.value == role,
      orElse: () => UserRole.member,
    );
  }
}
