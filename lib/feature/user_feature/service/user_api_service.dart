import 'package:dio/dio.dart';
import 'package:sportbook/feature/user_feature/model/login_request_dto.dart';
import 'package:sportbook/feature/user_feature/model/login_response_%20model.dart';
import 'package:sportbook/feature/user_feature/model/register_request_dto.dart';
import 'package:sportbook/feature/user_feature/model/user_model.dart';

class UserApiService {
  final Dio dio;

  UserApiService(this.dio);

  Future<LoginResponse> registerUser(RegisterRequestDto register) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: register.toJson(),
      );
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  Future<LoginResponse> loginUser(LoginRequestDto login) async {
    try {
      final response = await dio.post('/auth/login', data: login.toJson());
      return LoginResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
