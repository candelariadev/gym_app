enum UserSource {
  mobileApp('MOBILE_APP');

  const UserSource(this.backendValue);

  final String backendValue;

  static UserSource fromBackend(String value) {
    return switch (value.trim().toUpperCase()) {
      'MOBILE_APP' => UserSource.mobileApp,
      _ => throw const FormatException('Unsupported user source'),
    };
  }
}
