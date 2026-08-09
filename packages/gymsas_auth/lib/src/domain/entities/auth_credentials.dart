class AuthCredentials {
  const AuthCredentials({
    required this.ownerId,
    required this.user,
    required this.password,
  });

  final String ownerId;
  final String user;
  final String password;
}
