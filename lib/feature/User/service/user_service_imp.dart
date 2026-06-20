import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sportbook/feature/User/model/change_pass_reqeuest_dto.dart';
import 'package:sportbook/feature/User/model/login_request_dto.dart';
import 'package:sportbook/feature/User/model/login_response_%20model.dart';
import 'package:sportbook/feature/User/model/register_request_dto.dart';
import 'package:sportbook/feature/User/model/update_dto.dart';
import 'package:sportbook/feature/User/model/user_model.dart';
import 'package:sportbook/feature/User/repositories/user_api_repository.dart';
import 'package:sportbook/feature/User/service/user_service.dart';

class UserServiceImp extends ChangeNotifier implements UserService {
  final UserApiRepository userApiRepository;

  UserModel? _currentUser;
  bool _isLoading = false;
  String _error = '';

  @override
  UserModel? get currentUser => _currentUser;
  @override
  bool get isLoading => _isLoading;
  @override
  String get error => _error;

  UserServiceImp(this.userApiRepository);

  @override
  Future<LoginResponse> loginUser(LoginRequestDto login) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await userApiRepository.loginUser(login);
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<LoginResponse> registerUser(RegisterRequestDto register) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await userApiRepository.registerUser(register);
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<LoginResponse> loginWithFirebase({
    required String firebaseToken,
    required String fcmToken,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await userApiRepository.loginWithFirebase(
        firebaseToken: firebaseToken,
        fcmToken: fcmToken,
      );
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<LoginResponse> registerUserWithFirebase({
    required RegisterRequestDto userData,
    required String firebaseToken,
    required String fcmToken,
  }) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final response = await userApiRepository.registerUserWithFirebase(
        userData: userData,
        firebaseToken: firebaseToken,
        fcmToken: fcmToken,
      );
      _currentUser = response.user;
      _isLoading = false;
      notifyListeners();
      return response;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<UserModel> getProfile() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final user = await userApiRepository.getProfile();
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<UserModel> updateProfile(UpdateDto data) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final user = await userApiRepository.updateProfile(data);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<UserModel> updateAvatar(File file) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final user = await userApiRepository.updateAvatar(file);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  Future<void> changePassword(ChangePasswordRequestDto request) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      await userApiRepository.changePassword(request);
      _isLoading = false;
      _error = '';
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // ✅ NEW: Refresh current user data from server
  @override
  Future<UserModel> refreshCurrentUser() async {
    try {
      final user = await getProfile();
      _currentUser = user;
      notifyListeners();
      return user;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void updateUserLocally(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }

  @override
  void clearUser() {
    _currentUser = null;
    _isLoading = false;
    _error = '';
    notifyListeners();
  }
}
