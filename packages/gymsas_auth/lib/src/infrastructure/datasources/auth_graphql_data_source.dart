import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../dto/token_dto.dart';

class AuthGraphQlDataSource {
  const AuthGraphQlDataSource(this._client);

  static const _loginMutation = r'''
    mutation Login($input: LoginInput!) {
      login(input: $input) {
        token
        expiresAt
        refreshToken
        refreshExpiresAt
      }
    }
  ''';

  final GraphQlClient _client;

  Future<TokenDto> login({
    required String ownerId,
    required String user,
    required String password,
  }) async {
    final data = await _client.execute(
      document: _loginMutation,
      variables: {
        'input': {'ownerId': ownerId, 'user': user, 'password': password},
      },
    );
    return TokenDto.fromJson(data['login'] as Map<String, dynamic>);
  }
}
