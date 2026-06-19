import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sportbook/feature/Token/model/token_model.dart';

class TokenApi {
  final Dio dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  TokenApi(this.dio);

  Future<TokenModel> refreshToken(String refreshToken) async {
    try {
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(
          // Don't use auth interceptor for refresh
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final existingRefreshToken = await _storage.read(key: 'refresh_token');
        return TokenModel.fromJson(
          response.data,
          existingRefreshToken ?? refreshToken,
        );
      } else {
        throw Exception('Refresh failed with status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Refresh token expired or invalid
        throw Exception('Refresh token expired. Please login again.');
      }
      throw Exception("Failed to refresh token: ${e.message}");
    } catch (e) {
      throw Exception("Failed to refresh token: $e");
    }
  }
}
