import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_auth/src/infrastructure/repositories/secure_session_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));
  test(
    'token vencido conserva identidad local sin convertirlo en token valido',
    () async {
      const storage = FlutterSecureStorage();
      const repository = SecureSessionRepository(storage);
      final payload = base64Url.encode(
        utf8.encode(
          jsonEncode({'sub': 'tenant', 'user': 'user', 'role': 'ADVISED'}),
        ),
      );
      await repository.save(
        AuthSession(
          accessToken: 'header.$payload.synthetic',
          accessTokenExpiresAt: DateTime(2020),
          refreshToken: 'synthetic-refresh',
          refreshTokenExpiresAt: DateTime(2030),
          ownerId: 'tenant',
          user: 'user',
          role: UserRole.advised,
        ),
      );
      final restored = await repository.read();
      expect(restored?.user, 'user');
      expect(restored?.isExpired, isTrue);
      expect(await storage.read(key: 'auth_session'), isNotNull);
      await repository.clear();
      expect(await repository.read(), isNull);
    },
  );
}
