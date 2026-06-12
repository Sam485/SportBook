import 'package:sportbook/feature/user_feature/model/login_request_dto.dart';
import 'package:sportbook/feature/user_feature/model/login_response_%20model.dart';
import 'package:sportbook/feature/user_feature/model/register_request_dto.dart';

abstract class Userrepository {
  Future<LoginResponse> loginUser(LoginRequestDto login);
  Future<LoginResponse> registerUser(RegisterRequestDto register);
}
