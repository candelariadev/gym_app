import '../domain/entities/federated_auth_flow.dart';
import '../domain/entities/individual_onboarding.dart';
import '../domain/ports/federated_auth_repository.dart';
import '../domain/ports/external_identity_provider.dart';
import '../domain/ports/session_repository.dart';

class CompleteIndividualOnboardingUseCase {
  const CompleteIndividualOnboardingUseCase(
    this._provider,
    this._auth,
    this._sessions,
  );
  final ExternalIdentityProvider _provider;
  final FederatedAuthRepository _auth;
  final SessionRepository _sessions;

  Future<FederatedAuthFlow> call(IndividualOnboarding onboarding) async {
    final verified = IndividualOnboarding(
      idToken: await _provider.refreshIdToken(),
      nickname: onboarding.nickname,
      password: onboarding.password,
      role: onboarding.role,
      advised: onboarding.advised,
      trainer: onboarding.trainer,
    );
    final result = await _auth.completeOnboarding(verified);
    final session = result.sessionForContinuation();
    if (session == null) {
      throw const FormatException('Completed onboarding requires a session');
    }
    await _sessions.save(session);
    return result;
  }
}
