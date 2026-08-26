import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('authenticated flow continues with the role session', () {
    final session = _session(UserRole.advised);
    final flow = FederatedAuthFlow(
      state: FederatedAuthState.authenticated,
      identity: const FederatedIdentity(
        uid: 'uid',
        email: 'user@example.com',
        name: 'Kevin',
        role: 'ADVISED',
        onboardingCompleted: true,
      ),
      session: session,
    );

    expect(flow.sessionForContinuation(), same(session));
  });

  test('authenticated flow rejects a missing session', () {
    const flow = FederatedAuthFlow(
      state: FederatedAuthState.authenticated,
      identity: FederatedIdentity(
        uid: 'uid',
        email: 'user@example.com',
        name: 'Kevin',
        role: 'ADVISED',
        onboardingCompleted: true,
      ),
    );

    expect(flow.sessionForContinuation, throwsFormatException);
  });

  test('authenticated flow rejects identity and session role mismatch', () {
    final flow = FederatedAuthFlow(
      state: FederatedAuthState.authenticated,
      identity: const FederatedIdentity(
        uid: 'uid',
        email: 'user@example.com',
        name: 'Kevin',
        role: 'TRAINER',
        onboardingCompleted: true,
      ),
      session: _session(UserRole.advised),
    );

    expect(flow.sessionForContinuation, throwsFormatException);
  });
}

AuthSession _session(UserRole role) => AuthSession(
  accessToken: 'access',
  accessTokenExpiresAt: DateTime.utc(2030),
  refreshToken: 'refresh',
  refreshTokenExpiresAt: DateTime.utc(2031),
  ownerId: 'account',
  user: 'user',
  role: role,
);
