import '../entities/auth_credentials.dart';
import '../entities/auth_session.dart';

abstract interface class AuthRepository {
  Future<AuthSession> login(AuthCredentials credentials);
}
