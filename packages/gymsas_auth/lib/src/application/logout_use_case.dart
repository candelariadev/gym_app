import '../domain/ports/session_repository.dart';
import '../domain/ports/external_identity_provider.dart';

class LogoutUseCase {
  const LogoutUseCase(this._sessionRepository, [this._identityProvider]);

  final SessionRepository _sessionRepository;
  final ExternalIdentityProvider? _identityProvider;

  Future<void> call() async {
    await _sessionRepository.clear();
    await _identityProvider?.signOut();
  }
}
