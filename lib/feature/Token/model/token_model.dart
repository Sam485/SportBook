class TokenModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiredIn;
  final DateTime? receivedAt; // Add received timestamp

  TokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiredIn,
    this.receivedAt,
  });

  factory TokenModel.fromJson(
    Map<String, dynamic> json,
    String? existRefreshToken,
  ) {
    return TokenModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? existRefreshToken ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expiredIn: json['expires_in'] ?? 0,
      receivedAt: DateTime.now(),
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

  // Check if token is expired
  bool isExpired() {
    if (receivedAt == null) return true;
    final expiryTime = receivedAt!.add(Duration(seconds: expiredIn));
    return DateTime.now().isAfter(expiryTime);
  }

  // Get remaining time in seconds
  int getRemainingTime() {
    if (receivedAt == null) return 0;
    final expiryTime = receivedAt!.add(Duration(seconds: expiredIn));
    return expiryTime.difference(DateTime.now()).inSeconds;
  }

  // Check if token is about to expire (within next 5 minutes)
  bool isExpiringSoon() {
    return getRemainingTime() < 300; // 5 minutes
  }

  // Create copy with updated tokens
  TokenModel copyWith({
    String? accessToken,
    String? refreshToken,
    String? tokenType,
    int? expiredIn,
    DateTime? receivedAt,
  }) {
    return TokenModel(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenType: tokenType ?? this.tokenType,
      expiredIn: expiredIn ?? this.expiredIn,
      receivedAt: receivedAt ?? this.receivedAt,
    );
  }
}
