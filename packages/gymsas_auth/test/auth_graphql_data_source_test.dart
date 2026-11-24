import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_auth/src/infrastructure/datasources/auth_graphql_data_source.dart';

void main() {
  test('declara MOBILE_APP como source al iniciar sesión', () async {
    final client = _RecordingGraphQlClient();

    await AuthGraphQlDataSource(
      client,
    ).login(user: 'cliente', password: 'Password1!');

    expect(client.variables['input'], {
      'user': 'cliente',
      'password': 'Password1!',
      'source': 'MOBILE_APP',
    });
  });
}

class _RecordingGraphQlClient implements GraphQlClient {
  Map<String, dynamic> variables = const {};

  @override
  void close() {}

  @override
  Future<Map<String, dynamic>> execute({
    required String document,
    Map<String, dynamic> variables = const {},
    String? accessToken,
  }) async {
    this.variables = variables;
    return {
      'login': {
        'token': 'token',
        'expiresAt': '2030-01-01T00:00:00.000Z',
        'refreshToken': 'refresh',
        'refreshExpiresAt': '2030-02-01T00:00:00.000Z',
      },
    };
  }
}
