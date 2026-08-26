import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_auth/src/infrastructure/mappers/jwt_claims_mapper.dart';

void main() {
  test('mapea el rol TRAINER desde el JWT', () {
    final payload = base64Url.encode(
      utf8.encode(
        jsonEncode({
          'sub': 'tenant_1',
          'user': 'coach_demo',
          'role': 'TRAINER',
        }),
      ),
    );
    final claims = const JwtClaimsMapper().fromToken(
      'header.$payload.signature',
    );

    expect(claims.ownerId, 'tenant_1');
    expect(claims.user, 'coach_demo');
    expect(claims.role, UserRole.trainer);
  });

  test('identifica una sesión emitida por Firebase y su plan actual', () {
    final payload = base64Url.encode(
      utf8.encode(
        jsonEncode({
          'sub': 'individual-account',
          'user': 'firebase-user',
          'role': 'ADVISED',
          'firebaseUid': 'firebase-uid-1',
          'plan': 'INDIVIDUAL',
        }),
      ),
    );

    final claims = const JwtClaimsMapper().fromToken(
      'header.$payload.signature',
    );

    expect(claims.firebaseUid, 'firebase-uid-1');
    expect(claims.plan, 'INDIVIDUAL');
  });
}
