import 'dart:convert';

import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  test('envia variables y bearer token y retorna data', () async {
    final httpClient = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer access-token');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['variables'], {'page': 1});
      return http.Response('{"data":{"items":[1]}}', 200);
    });
    final client = HttpGraphQlClient(
      endpoint: 'https://api.example/graphql',
      httpClient: httpClient,
    );

    final data = await client.execute(
      document: 'query Items { items }',
      variables: const {'page': 1},
      accessToken: 'access-token',
    );

    expect(data['items'], [1]);
  });

  test(
    'conserva los errores GraphQL para mapearlos en la aplicacion',
    () async {
      final client = HttpGraphQlClient(
        endpoint: 'https://api.example/graphql',
        httpClient: MockClient(
          (_) async => http.Response(
            '{"errors":[{"message":"Invalid credentials"}]}',
            200,
          ),
        ),
      );

      await expectLater(
        client.execute(document: 'mutation Login { login }'),
        throwsA(
          isA<GraphQlException>().having(
            (error) => error.errors.first.message,
            'message',
            'Invalid credentials',
          ),
        ),
      );
    },
  );

  test('close es idempotente y termina el lifecycle del cliente', () {
    final client = HttpGraphQlClient(endpoint: 'https://api.example/graphql');

    client.close();
    client.close();

    expect(client.isClosed, isTrue);
  });
}
