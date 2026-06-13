import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sportbook/feature/Token/model/token_model.dart';

class TokenApi {
  final Dio dio;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  TokenApi(this.dio);

  Future<TokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );
      return TokenModel.fromJson(
        response.data,
        await _storage.read(key: 'refresh_token'),
      );
    } on DioException catch (e) {
      throw Exception("Failed to refresh token: ${e.message}");
    }
  }
}
