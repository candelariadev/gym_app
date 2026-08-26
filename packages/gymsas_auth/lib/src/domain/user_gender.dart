enum UserGender {
  male(backendValue: 'MALE'),
  female(backendValue: 'FEMALE'),
  other(backendValue: 'OTHER');

  const UserGender({required this.backendValue});

  final String backendValue;

  static UserGender fromBackend(String value) {
    return UserGender.values.firstWhere(
      (gender) => gender.backendValue == value.toUpperCase(),
      orElse: () => throw FormatException('Unsupported gender: $value'),
    );
  }
}
