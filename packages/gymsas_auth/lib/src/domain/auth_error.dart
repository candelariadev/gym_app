enum AuthErrorCode {
  configurationMissing,
  invalidCredentials,
  authUnavailable,
  server,
  invalidResponse,
  timeout,
  network,
  invalidSession,
  incompleteSession,
  unexpected,
}

class AuthException implements Exception {
  const AuthException(this.code);

  final AuthErrorCode code;

  @override
  String toString() => 'AuthException(${code.name})';
}
