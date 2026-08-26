import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../dto/federated_auth_flow_dto.dart';

class FederatedAuthGraphQlDataSource {
  const FederatedAuthGraphQlDataSource(this._client);
  final GraphQlClient _client;

  static const _fields = r'''
    state
    identity { uid email name picture nickname role onboardingCompleted }
    session { token expiresAt refreshToken refreshExpiresAt }
  ''';

  Future<FederatedAuthFlowDto> signIn(String idToken) async {
    final data = await _client.execute(
      document:
          'mutation FirebaseSignIn(\$input: FirebaseSignInInput!) { firebaseSignIn(input: \$input) { $_fields } }',
      variables: {
        'input': {'idToken': idToken},
      },
    );
    return FederatedAuthFlowDto(
      json: data['firebaseSignIn'] as Map<String, dynamic>,
    );
  }

  Future<FederatedAuthFlowDto> complete(Map<String, dynamic> input) async {
    final data = await _client.execute(
      document:
          'mutation CompleteIndividualOnboarding(\$input: IndividualOnboardingInput!) { completeIndividualOnboarding(input: \$input) { $_fields } }',
      variables: {'input': input},
    );
    return FederatedAuthFlowDto(
      json: data['completeIndividualOnboarding'] as Map<String, dynamic>,
    );
  }
}
