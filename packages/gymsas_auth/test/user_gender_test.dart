import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_auth/gymsas_auth.dart';

void main() {
  test('expone los valores admitidos por el backend', () {
    expect(UserGender.values.map((gender) => gender.backendValue), [
      'MALE',
      'FEMALE',
      'OTHER',
    ]);
  });

  test('convierte el valor backend sin depender de mayusculas', () {
    expect(UserGender.fromBackend('female'), UserGender.female);
  });

  test('rechaza un valor que el backend no admite', () {
    expect(
      () => UserGender.fromBackend('UNSUPPORTED'),
      throwsA(isA<FormatException>()),
    );
  });
}
