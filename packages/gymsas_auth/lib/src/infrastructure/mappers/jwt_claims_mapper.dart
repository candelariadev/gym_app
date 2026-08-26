import 'dart:convert';

import '../../domain/auth_error.dart';
import '../../domain/user_role.dart';

class AuthTokenClaims {
  const AuthTokenClaims({
    required this.ownerId,
    required this.user,
    required this.role,
    this.nickname,
    this.firebaseUid,
    this.plan,
  });

  final String ownerId;
  final String user;
  final UserRole role;
  final String? nickname;
  final String? firebaseUid;
  final String? plan;
}

class JwtClaimsMapper {
  const JwtClaimsMapper();

  AuthTokenClaims fromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) throw const FormatException();
      final payload = utf8.decode(
        base64Url.decode(base64Url.normalize(parts[1])),
      );
      final json = jsonDecode(payload) as Map<String, dynamic>;
      return AuthTokenClaims(
        ownerId: json['sub'] as String,
        user: json['user'] as String,
        role: UserRole.fromBackend(json['role'] as String),
        nickname: json['nickname'] as String?,
        firebaseUid: json['firebaseUid'] as String?,
        plan: json['plan'] as String?,
      );
    } on FormatException {
      throw const AuthException(AuthErrorCode.invalidSession);
    } on TypeError {
      throw const AuthException(AuthErrorCode.incompleteSession);
    }
  }
}
