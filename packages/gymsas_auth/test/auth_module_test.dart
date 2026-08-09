import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

void main() {
  test('dispose es idempotente y cierra los recursos del modulo', () {
    final module = AuthModule.production(
      graphQlEndpoint: 'https://api.example/graphql',
    );

    module.dispose();
    module.dispose();

    expect(module.isDisposed, isTrue);
  });
}
