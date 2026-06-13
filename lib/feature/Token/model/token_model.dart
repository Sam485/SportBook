class TokenModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiredIn; // Changed from String? to int

  TokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiredIn, // Changed to required
  });

  factory TokenModel.fromJson(
    Map<String, dynamic> json,
    String? existRefreshToken,
  ) {
    return TokenModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? existRefreshToken,
      tokenType: json['token_type'] ?? 'Bearer',
      expiredIn: json['expires_in'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiredIn,
    };
  }

  // Helper method to check if token is expired
  bool isExpired() {
    // You might want to store the timestamp when token was received
    // For now, this is a placeholder
    return false;
  }
}
