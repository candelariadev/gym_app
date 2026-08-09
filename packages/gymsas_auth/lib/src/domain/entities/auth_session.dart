import '../user_role.dart';

class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.accessTokenExpiresAt,
    required this.refreshToken,
    required this.refreshTokenExpiresAt,
    required this.ownerId,
    required this.user,
    required this.role,
  });

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final String ownerId;
  final String user;
  final UserRole role;

  bool get isExpired => DateTime.now().isAfter(accessTokenExpiresAt);
}
