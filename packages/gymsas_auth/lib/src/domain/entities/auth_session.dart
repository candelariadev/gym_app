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
    this.nickname,
    this.firebaseUid,
    this.plan,
  });

  final String accessToken;
  final DateTime accessTokenExpiresAt;
  final String refreshToken;
  final DateTime refreshTokenExpiresAt;
  final String ownerId;
  final String user;
  final UserRole role;
  final String? nickname;
  final String? firebaseUid;
  final String? plan;

  bool get canManageSubscription => firebaseUid?.trim().isNotEmpty == true;

  String get displayName =>
      nickname?.trim().isNotEmpty == true ? nickname! : user;

  bool get isExpired => DateTime.now().isAfter(accessTokenExpiresAt);
}
