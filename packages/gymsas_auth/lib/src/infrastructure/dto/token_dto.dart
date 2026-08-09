class TokenDto {
  const TokenDto({
    required this.token,
    required this.expiresAt,
    required this.refreshToken,
    required this.refreshExpiresAt,
  });

  factory TokenDto.fromJson(Map<String, dynamic> json) {
    return TokenDto(
      token: json['token'] as String,
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      refreshToken: json['refreshToken'] as String,
      refreshExpiresAt: DateTime.parse(json['refreshExpiresAt'] as String),
    );
  }

  final String token;
  final DateTime expiresAt;
  final String refreshToken;
  final DateTime refreshExpiresAt;
}
