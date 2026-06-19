import 'package:sportbook/feature/Token/model/token_model.dart';
import 'package:sportbook/feature/User/model/user_model.dart';

class LoginResponse {
  final TokenModel tokenModel;
  final UserModel user;

  LoginResponse({required this.tokenModel, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      tokenModel: TokenModel(
        accessToken: json['access_token'] ?? '',
        refreshToken: json['refresh_token'] ?? '',
        tokenType: json['token_type'] ?? 'Bearer',
        expiredIn: json['expires_in'] ?? 0, // Now accepts int
      ),
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }
}
