import '../../domain/auth_error.dart';
import '../../domain/entities/auth_credentials.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/ports/auth_repository.dart';
import '../datasources/auth_graphql_data_source.dart';
import '../mappers/auth_api_error_mapper.dart';
import '../mappers/jwt_claims_mapper.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthGraphQlDataSource dataSource,
    required JwtClaimsMapper claimsMapper,
    required AuthApiErrorMapper errorMapper,
  }) : _dataSource = dataSource,
       _claimsMapper = claimsMapper,
       _errorMapper = errorMapper;

  final AuthGraphQlDataSource _dataSource;
  final JwtClaimsMapper _claimsMapper;
  final AuthApiErrorMapper _errorMapper;

  @override
  Future<AuthSession> login(AuthCredentials credentials) async {
    try {
      final token = await _dataSource.login(
        ownerId: credentials.ownerId,
        user: credentials.user,
        password: credentials.password,
      );
      final claims = _claimsMapper.fromToken(token.token);
      return AuthSession(
        accessToken: token.token,
        accessTokenExpiresAt: token.expiresAt,
        refreshToken: token.refreshToken,
        refreshTokenExpiresAt: token.refreshExpiresAt,
        ownerId: claims.ownerId,
        user: claims.user,
        role: claims.role,
        nickname: claims.nickname,
        firebaseUid: claims.firebaseUid,
        plan: claims.plan,
      );
    } on AuthException {
      rethrow;
    } on Object catch (error) {
      throw _errorMapper.from(error);
    }
  }
}
