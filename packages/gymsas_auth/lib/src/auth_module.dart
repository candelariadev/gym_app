import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';

import 'application/login_use_case.dart';
import 'application/logout_use_case.dart';
import 'domain/ports/session_repository.dart';
import 'infrastructure/datasources/auth_graphql_data_source.dart';
import 'infrastructure/mappers/auth_api_error_mapper.dart';
import 'infrastructure/mappers/jwt_claims_mapper.dart';
import 'infrastructure/repositories/auth_repository_impl.dart';
import 'infrastructure/repositories/secure_session_repository.dart';

class AuthModule {
  AuthModule._({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.sessionRepository,
    required GraphQlClient graphQlClient,
  }) : _graphQlClient = graphQlClient;

  factory AuthModule.production({required String graphQlEndpoint}) {
    final graphQlClient = HttpGraphQlClient(endpoint: graphQlEndpoint);
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    const sessionRepository = SecureSessionRepository(storage);
    final authRepository = AuthRepositoryImpl(
      dataSource: AuthGraphQlDataSource(graphQlClient),
      claimsMapper: const JwtClaimsMapper(),
      errorMapper: const AuthApiErrorMapper(),
    );

    return AuthModule._(
      loginUseCase: LoginUseCase(
        authRepository: authRepository,
        sessionRepository: sessionRepository,
      ),
      logoutUseCase: const LogoutUseCase(sessionRepository),
      sessionRepository: sessionRepository,
      graphQlClient: graphQlClient,
    );
  }

  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final SessionRepository sessionRepository;
  final GraphQlClient _graphQlClient;
  bool _isDisposed = false;

  bool get isDisposed => _isDisposed;

  void dispose() {
    if (_isDisposed) return;
    _isDisposed = true;
    _graphQlClient.close();
  }
}
