// lib/feature/User/service/user_service.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sportbook/feature/User/model/login_request_dto.dart';
import 'package:sportbook/feature/User/model/login_response_%20model.dart';
import 'package:sportbook/feature/User/model/register_request_dto.dart';
import 'package:sportbook/feature/User/model/update_dto.dart';
import 'package:sportbook/feature/User/model/user_model.dart';

abstract class UserService extends ChangeNotifier {
  Future<LoginResponse> loginUser(LoginRequestDto login);
  Future<LoginResponse> registerUser(RegisterRequestDto register);
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(UpdateDto data);
  Future<UserModel> updateAvatar(File file);

  // Firebase OTP methods
  Future<LoginResponse> loginWithFirebase({
    required String firebaseToken,
    required String fcmToken,
  });

  Future<LoginResponse> registerUserWithFirebase({
    required RegisterRequestDto userData,
    required String firebaseToken,
    required String fcmToken,
  });

  // State getters
  UserModel? get currentUser;
  bool get isLoading;
  String get error;

  void updateUserLocally(UserModel user);
  void clearUser();
}
