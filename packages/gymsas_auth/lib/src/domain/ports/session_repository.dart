import '../entities/auth_session.dart';

abstract interface class SessionRepository {
  Future<AuthSession?> read();
  Future<void> save(AuthSession session);
  Future<void> clear();
}
