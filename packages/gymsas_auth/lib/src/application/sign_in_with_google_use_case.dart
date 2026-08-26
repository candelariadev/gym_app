import '../domain/entities/federated_auth_flow.dart';
import '../domain/ports/external_identity_provider.dart';
import '../domain/ports/federated_auth_repository.dart';
import '../domain/ports/session_repository.dart';

class SignInWithGoogleUseCase {
  const SignInWithGoogleUseCase(this._provider, this._auth, this._sessions);
  final ExternalIdentityProvider _provider;
  final FederatedAuthRepository _auth;
  final SessionRepository _sessions;

  Future<FederatedAuthFlow> call() async {
    final result = await _auth.signIn(await _provider.signInWithGoogle());
    final session = result.sessionForContinuation();
    if (session != null) await _sessions.save(session);
    return result;
  }
}
