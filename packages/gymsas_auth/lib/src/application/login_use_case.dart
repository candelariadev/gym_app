import '../domain/auth_error.dart';
import '../domain/entities/auth_credentials.dart';
import '../domain/entities/auth_session.dart';
import '../domain/ports/auth_repository.dart';
import '../domain/ports/session_repository.dart';

class LoginUseCase {
  const LoginUseCase({
    required AuthRepository authRepository,
    required SessionRepository sessionRepository,
  }) : _authRepository = authRepository,
       _sessionRepository = sessionRepository;

  final AuthRepository _authRepository;
  final SessionRepository _sessionRepository;

  Future<AuthSession> call(AuthCredentials credentials) async {
    if (credentials.ownerId.trim().isEmpty) {
      throw const AuthException(AuthErrorCode.configurationMissing);
    }
    final session = await _authRepository.login(credentials);
    await _sessionRepository.save(session);
    return session;
  }
}
