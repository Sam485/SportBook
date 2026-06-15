import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:sportbook/feature/User/model/login_request_dto.dart';
import 'package:sportbook/feature/User/model/login_response_%20model.dart';
import 'package:sportbook/feature/User/model/register_request_dto.dart';
import 'package:sportbook/feature/User/model/update_dto.dart';
import 'package:sportbook/feature/User/model/user_model.dart';

abstract class UserService {
  Future<LoginResponse> loginUser(LoginRequestDto login);
  Future<LoginResponse> registerUser(RegisterRequestDto register);
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateDto data);
  Future<UserModel> updateAvatar(File file);
}
