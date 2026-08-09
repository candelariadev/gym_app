import '../domain/ports/session_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._sessionRepository);

  final SessionRepository _sessionRepository;

  Future<void> call() => _sessionRepository.clear();
}
