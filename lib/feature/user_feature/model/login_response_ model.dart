import 'package:sportbook/feature/user_feature/model/user_model.dart';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expireIn;
  final UserModel user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expireIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
      expireIn: json['expires_in'] ?? 0,
      user: UserModel.fromJson(json['user']),
    );
  }
}
