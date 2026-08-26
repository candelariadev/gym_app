import 'auth_session.dart';
import '../user_role.dart';

enum FederatedAuthState { authenticated, onboardingRequired }

class FederatedIdentity {
  const FederatedIdentity({
    required this.uid,
    required this.email,
    required this.name,
    required this.onboardingCompleted,
    this.picture,
    this.nickname,
    this.role,
  });

  final String uid;
  final String email;
  final String name;
  final String? picture;
  final String? nickname;
  final String? role;
  final bool onboardingCompleted;
}

class FederatedAuthFlow {
  const FederatedAuthFlow({
    required this.state,
    required this.identity,
    this.session,
  });

  final FederatedAuthState state;
  final FederatedIdentity identity;
  final AuthSession? session;

  AuthSession? sessionForContinuation() {
    if (state == FederatedAuthState.onboardingRequired) {
      if (session != null || identity.onboardingCompleted) {
        throw const FormatException('Invalid onboarding-required auth state');
      }
      return null;
    }
    if (!identity.onboardingCompleted || session == null) {
      throw const FormatException(
        'Authenticated flow requires a completed session',
      );
    }
    final identityRole = identity.role;
    if (identityRole == null ||
        UserRole.fromBackend(identityRole) != session!.role) {
      throw const FormatException('Identity and session roles do not match');
    }
    return session;
  }
}
