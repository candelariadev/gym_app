import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/ports/session_repository.dart';
import '../../domain/user_role.dart';

class SecureSessionRepository implements SessionRepository {
  const SecureSessionRepository(this._storage);

  static const _sessionKey = 'auth_session';
  final FlutterSecureStorage _storage;

  @override
  Future<void> clear() => _storage.delete(key: _sessionKey);

  @override
  Future<AuthSession?> read() async {
    final encoded = await _storage.read(key: _sessionKey);
    if (encoded == null) return null;
    try {
      final json = jsonDecode(encoded) as Map<String, dynamic>;
      final session = AuthSession(
        accessToken: json['accessToken'] as String,
        accessTokenExpiresAt: DateTime.parse(
          json['accessTokenExpiresAt'] as String,
        ),
        refreshToken: json['refreshToken'] as String,
        refreshTokenExpiresAt: DateTime.parse(
          json['refreshTokenExpiresAt'] as String,
        ),
        ownerId: json['ownerId'] as String,
        user: json['user'] as String,
        role: UserRole.fromBackend(json['role'] as String),
      );
      if (session.isExpired) {
        await clear();
        return null;
      }
      return session;
    } on Object {
      await clear();
      return null;
    }
  }

  @override
  Future<void> save(AuthSession session) {
    return _storage.write(
      key: _sessionKey,
      value: jsonEncode({
        'accessToken': session.accessToken,
        'accessTokenExpiresAt': session.accessTokenExpiresAt.toIso8601String(),
        'refreshToken': session.refreshToken,
        'refreshTokenExpiresAt': session.refreshTokenExpiresAt
            .toIso8601String(),
        'ownerId': session.ownerId,
        'user': session.user,
        'role': session.role.backendValue,
      }),
    );
  }
}
