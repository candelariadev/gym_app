import 'package:gymsas_exercises/gymsas_exercises.dart';
import 'package:test/test.dart';

void main() {
  test('dispose es idempotente y cierra el modulo', () {
    final module = ExerciseCatalogModule.production(
      graphQlEndpoint: 'https://api.example/graphql',
      accessTokenProvider: () => 'token',
    );

    module.dispose();
    module.dispose();

    expect(module.isDisposed, isTrue);
  });
}
