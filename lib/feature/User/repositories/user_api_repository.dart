import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sportbook/feature/User/model/login_request_dto.dart';
import 'package:sportbook/feature/User/model/login_response_%20model.dart';
import 'package:sportbook/feature/User/model/register_request_dto.dart';
import 'package:sportbook/feature/User/model/update_dto.dart';
import 'package:sportbook/feature/User/model/user_model.dart';

class UserApiRepository {
  final Dio dio;

  UserApiRepository(this.dio);

  Future<LoginResponse> registerUser(RegisterRequestDto register) async {
    try {
      final response = await dio.post(
        '/auth/register',
        data: register.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Server error: ${e.response?.data['message'] ?? e.message}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<LoginResponse> loginUser(LoginRequestDto login) async {
    try {
      final response = await dio.post('/auth/login', data: login.toJson());

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Server error: ${e.response?.data['message'] ?? e.message}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  // Firebase OTP Login
  Future<LoginResponse> loginWithFirebase({
    required String firebaseToken,
    required String fcmToken,
  }) async {
    print('\n🔵 [API] loginWithFirebase STARTED');
    print('📤 [API] Request Data:');
    print('   └─ Firebase Token Length: ${firebaseToken.length}');
    print(
      '   └─ FCM Token: ${fcmToken.isEmpty ? 'empty' : fcmToken.substring(0, 30) + '...'}',
    );

    try {
      final response = await dio.post(
        '/auth/phone-login', // Updated endpoint
        data: {'firebase_token': firebaseToken, 'fcm_token': fcmToken},
      );

      print('📥 [API] Response Received:');
      print('   └─ Status Code: ${response.statusCode}');
      print('   └─ Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [API] Login successful');
        return LoginResponse.fromJson(response.data);
      } else {
        print('❌ [API] Login failed with status: ${response.statusCode}');
        throw Exception('Phone login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [API] Dio Exception:');
      print('   └─ Type: ${e.type}');
      print('   └─ Message: ${e.message}');
      print('   └─ Response: ${e.response?.data}');
      print('   └─ Status Code: ${e.response?.statusCode}');
      throw Exception(
        'Server error: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      print('❌ [API] Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  // Firebase OTP Sign Up
  Future<LoginResponse> registerUserWithFirebase({
    required RegisterRequestDto userData,
    required String firebaseToken,
    required String fcmToken,
  }) async {
    print('\n🔵 [API] registerUserWithFirebase STARTED');
    print('📤 [API] Request Data:');
    print('   └─ Name: ${userData.name}');
    print('   └─ Phone: ${userData.phone}');
    print('   └─ Firebase Token Length: ${firebaseToken.length}');

    try {
      final response = await dio.post(
        '/auth/phone-register', // Update this endpoint if different
        data: {
          'full_name': userData.name,
          'phone': userData.phone,
          'firebase_token': firebaseToken,
          'fcm_token': fcmToken,
        },
      );

      print('📥 [API] Response Received:');
      print('   └─ Status Code: ${response.statusCode}');
      print('   └─ Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ [API] Registration successful');
        return LoginResponse.fromJson(response.data);
      } else {
        throw Exception('Phone registration failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [API] Dio Exception: ${e.response?.data}');
      throw Exception(
        'Server error: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      print('❌ [API] Unexpected error: $e');
      throw Exception('Unexpected error: $e');
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await dio.get('/users/me');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Retrieve Failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Server error: ${e.response?.data['message'] ?? e.message}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<UserModel> updateProfile(UpdateDto updateData) async {
    try {
      final response = await dio.put('/users/me', data: updateData.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('An error occure: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Server error: ${e.response?.data['message'] ?? e.message}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<UserModel> updateAvatar(File avatar) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(avatar.path),
      });

      final response = await dio.post('/users/me/avatar', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromJson(response.data);
      } else {
        throw Exception('Error with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          'Server error: ${e.response?.data['message'] ?? e.message}',
        );
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
