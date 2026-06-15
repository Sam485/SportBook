import 'dart:io';

import 'package:sportbook/feature/User/model/login_request_dto.dart';
import 'package:sportbook/feature/User/model/login_response_%20model.dart';
import 'package:sportbook/feature/User/model/register_request_dto.dart';
import 'package:sportbook/feature/User/model/update_dto.dart';
import 'package:sportbook/feature/User/model/user_model.dart';
import 'package:sportbook/feature/User/repositories/user_api_repository.dart';
import 'package:sportbook/feature/User/service/user_service.dart';

class UserServiceImp implements UserService {
  final UserApiRepository userApiRepository;

  UserServiceImp(this.userApiRepository);

  @override
  Future<LoginResponse> loginUser(LoginRequestDto login) async {
    try {
      return await userApiRepository.loginUser(login);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<LoginResponse> registerUser(RegisterRequestDto register) async {
    try {
      return await userApiRepository.registerUser(register);
    } catch (e) {
      throw Exception('Register Failed: $e');
    }
  }

  @override
  Future<UserModel> getProfile() async {
    try {
      return await userApiRepository.getProfile();
    } catch (e) {
      throw Exception('Retrieve Failed: $e');
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateDto data) async {
    try {
      return await userApiRepository.updateProfile(data);
    } catch (e) {
      throw Exception('Retrieve failed: $e');
    }
  }

  @override
  Future<UserModel> updateAvatar(File file) async {
    try {
      return await userApiRepository.updateAvatar(file);
    } catch (e) {
      throw Exception('Retrieve failed: $e');
    }
  }
}
