import '../../domain/auth_error.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/federated_auth_flow.dart';
import '../../domain/entities/individual_onboarding.dart';
import '../../domain/ports/federated_auth_repository.dart';
import '../datasources/federated_auth_graphql_data_source.dart';
import '../dto/federated_auth_flow_dto.dart';
import '../mappers/auth_api_error_mapper.dart';
import '../mappers/jwt_claims_mapper.dart';

class FederatedAuthRepositoryImpl implements FederatedAuthRepository {
  const FederatedAuthRepositoryImpl(
    this._dataSource,
    this._claimsMapper,
    this._errorMapper,
  );
  final FederatedAuthGraphQlDataSource _dataSource;
  final JwtClaimsMapper _claimsMapper;
  final AuthApiErrorMapper _errorMapper;

  @override
  Future<FederatedAuthFlow> signIn(String idToken) =>
      _execute(() => _dataSource.signIn(idToken));

  @override
  Future<FederatedAuthFlow> completeOnboarding(IndividualOnboarding value) {
    final input = <String, dynamic>{
      'idToken': value.idToken,
      'nickname': value.nickname,
      'password': value.password,
      'role': value.role.backendValue,
      if (value.advised != null)
        'advised': {
          'birthdate': value.advised!.birthdate
              .toIso8601String()
              .split('T')
              .first,
          'gender': value.advised!.gender.backendValue,
          'weight': value.advised!.weight,
          'goals': value.advised!.goals,
          'notes': value.advised!.notes,
        },
      if (value.trainer != null)
        'trainer': {
          'bio': value.trainer!.bio,
          'certifications': value.trainer!.certifications,
          'experience': value.trainer!.experience,
        },
    };
    return _execute(() => _dataSource.complete(input));
  }

  Future<FederatedAuthFlow> _execute(
    Future<FederatedAuthFlowDto> Function() action,
  ) async {
    try {
      return _map(await action());
    } on AuthException {
      rethrow;
    } on Object catch (error) {
      throw _errorMapper.from(error);
    }
  }

  FederatedAuthFlow _map(FederatedAuthFlowDto dto) {
    final json = dto.json;
    final identity = json['identity'] as Map<String, dynamic>;
    final sessionJson = json['session'] as Map<String, dynamic>?;
    AuthSession? session;
    if (sessionJson != null) {
      final claims = _claimsMapper.fromToken(sessionJson['token'] as String);
      session = AuthSession(
        accessToken: sessionJson['token'] as String,
        accessTokenExpiresAt: DateTime.parse(
          sessionJson['expiresAt'] as String,
        ),
        refreshToken: sessionJson['refreshToken'] as String,
        refreshTokenExpiresAt: DateTime.parse(
          sessionJson['refreshExpiresAt'] as String,
        ),
        ownerId: claims.ownerId,
        user: claims.user,
        role: claims.role,
        nickname: claims.nickname,
        firebaseUid: claims.firebaseUid,
        plan: claims.plan,
      );
    }
    return FederatedAuthFlow(
      state: json['state'] == 'AUTHENTICATED'
          ? FederatedAuthState.authenticated
          : FederatedAuthState.onboardingRequired,
      identity: FederatedIdentity(
        uid: identity['uid'] as String,
        email: identity['email'] as String,
        name: identity['name'] as String,
        picture: identity['picture'] as String?,
        nickname: identity['nickname'] as String?,
        role: identity['role'] as String?,
        onboardingCompleted: identity['onboardingCompleted'] as bool,
      ),
      session: session,
    );
  }
}
