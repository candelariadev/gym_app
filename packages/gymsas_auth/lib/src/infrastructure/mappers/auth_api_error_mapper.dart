import 'package:gymsas_api_client/gymsas_api_client.dart';

import '../../domain/auth_error.dart';

class AuthApiErrorMapper {
  const AuthApiErrorMapper();

  AuthException from(Object error) {
    if (error is GraphQlException) {
      return AuthException(_fromGraphQl(error));
    }
    if (error is ApiClientException) {
      return AuthException(_fromApiClient(error.code));
    }
    if (error is FormatException || error is TypeError) {
      return const AuthException(AuthErrorCode.invalidResponse);
    }
    return const AuthException(AuthErrorCode.unexpected);
  }

  AuthErrorCode _fromGraphQl(GraphQlException error) {
    if (error.errors.isEmpty) return AuthErrorCode.server;
    final rawStatus = error.errors.first.extensions['httpStatus'];
    final status = rawStatus is num
        ? rawStatus.toInt()
        : int.tryParse(rawStatus?.toString() ?? '');
    return switch (status) {
      401 => AuthErrorCode.invalidCredentials,
      502 || 503 || 504 => AuthErrorCode.authUnavailable,
      _ => AuthErrorCode.server,
    };
  }

  AuthErrorCode _fromApiClient(ApiClientErrorCode code) {
    return switch (code) {
      ApiClientErrorCode.server => AuthErrorCode.server,
      ApiClientErrorCode.invalidResponse => AuthErrorCode.invalidResponse,
      ApiClientErrorCode.timeout => AuthErrorCode.timeout,
      ApiClientErrorCode.network => AuthErrorCode.network,
    };
  }
}
