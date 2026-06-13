import 'package:sportbook/feature/User/model/login_request_dto.dart';
import 'package:sportbook/feature/User/model/login_response_%20model.dart';
import 'package:sportbook/feature/User/model/register_request_dto.dart';
import 'package:sportbook/feature/User/model/user_model.dart';
import 'package:sportbook/feature/User/repositories/user_repository.dart';
import 'package:sportbook/feature/User/service/user_api_service.dart';

class UserRepositoryImp implements Userrepository {
  final UserApiService userApiService;

  UserRepositoryImp(this.userApiService);

  @override
  Future<LoginResponse> loginUser(LoginRequestDto login) async {
    try {
      return await userApiService.loginUser(login);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<LoginResponse> registerUser(RegisterRequestDto register) async {
    try {
      return await userApiService.registerUser(register);
    } catch (e) {
      throw Exception('Register Failed: $e');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      return await userApiService.getProfile();
    } catch (e) {
      throw Exception('Retrieve Failed: $e');
    }
  }
}
