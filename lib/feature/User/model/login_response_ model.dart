import 'user_model.dart';
import '../../Token/model/token_model.dart';

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
        expiredIn: json['expires_in'] ?? 0,
      ),
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': tokenModel.accessToken,
      'refresh_token': tokenModel.refreshToken,
      'token_type': tokenModel.tokenType,
      'expires_in': tokenModel.expiredIn,
      'user': user.toJson(),
    };
  }
}
