enum UserRole {
  trainer(backendValue: 'TRAINER'),
  advised(backendValue: 'ADVISED');

  const UserRole({required this.backendValue});

  final String backendValue;

  static UserRole fromBackend(String value) {
    return UserRole.values.firstWhere(
      (role) => role.backendValue == value.toUpperCase(),
      orElse: () => throw FormatException('Unsupported role: $value'),
    );
  }
}
