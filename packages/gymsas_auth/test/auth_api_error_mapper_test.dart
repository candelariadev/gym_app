import 'package:flutter_test/flutter_test.dart';
import 'package:gymsas_api_client/gymsas_api_client.dart';
import 'package:gymsas_auth/gymsas_auth.dart';
import 'package:gymsas_auth/src/infrastructure/mappers/auth_api_error_mapper.dart';

void main() {
  const mapper = AuthApiErrorMapper();

  test('convierte credenciales invalidas de GraphQL', () {
    final result = mapper.from(
      const GraphQlException([
        GraphQlError(
          message: 'El texto puede cambiar',
          extensions: {'httpStatus': 401},
        ),
      ]),
    );

    expect(result.code, AuthErrorCode.invalidCredentials);
  });

  test('clasifica indisponibilidad por status estable', () {
    final result = mapper.from(
      const GraphQlException([
        GraphQlError(message: 'Any message', extensions: {'httpStatus': 502}),
      ]),
    );

    expect(result.code, AuthErrorCode.authUnavailable);
  });

  test('convierte timeout tecnico a error de autenticacion', () {
    final result = mapper.from(
      const ApiClientException(ApiClientErrorCode.timeout),
    );

    expect(result.code, AuthErrorCode.timeout);
  });
}
