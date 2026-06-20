import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sportbook/feature/User/model/change_pass_reqeuest_dto.dart';
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
        '/auth/phone-login',
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
        '/auth/phone-register',
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

  // ✅ FIXED: Avatar upload with proper multipart handling
  Future<UserModel> updateAvatar(File avatar) async {
    try {
      print('🟢 [API] updateAvatar STARTED');
      print('   └─ File path: ${avatar.path}');
      print('   └─ File size: ${await avatar.length()} bytes');

      // Check if file exists
      if (!await avatar.exists()) {
        throw Exception('File does not exist: ${avatar.path}');
      }

      // Create multipart file with proper naming
      final fileName = avatar.path.split('/').last;
      final multipartFile = await MultipartFile.fromFile(
        avatar.path,
        filename: fileName,
        contentType: _getContentType(fileName),
      );

      // Create FormData with the file
      final formData = FormData.fromMap({'avatar': multipartFile});

      print('📤 [API] Uploading avatar...');

      final response = await dio.post(
        '/users/me/avatar',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          followRedirects: true,
          maxRedirects: 5,
        ),
      );

      print('📥 [API] Response Status: ${response.statusCode}');
      print('📥 [API] Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Handle different response formats
        if (response.data is Map<String, dynamic>) {
          // If response contains user data directly
          if (response.data.containsKey('id') ||
              response.data.containsKey('full_name')) {
            return UserModel.fromJson(response.data);
          }
          // If response contains user wrapped in data field
          else if (response.data.containsKey('data')) {
            return UserModel.fromJson(response.data['data']);
          }
          // If response just contains avatar URL
          else if (response.data.containsKey('avatar_url')) {
            // Get current user and update avatar URL
            final currentUser = await getProfile();
            return currentUser;
          }
        }
        // If response is just a string (URL or message)
        else if (response.data is String) {
          // Get fresh user data
          final currentUser = await getProfile();
          return currentUser;
        }

        // Fallback: fetch fresh user data
        final freshUser = await getProfile();
        return freshUser;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('❌ [API] Dio Exception:');
      print('   └─ Type: ${e.type}');
      print('   └─ Message: ${e.message}');
      print('   └─ Response: ${e.response?.data}');
      print('   └─ Status Code: ${e.response?.statusCode}');

      String errorMessage = e.message ?? 'Network error';
      if (e.response?.data != null) {
        try {
          final data = e.response!.data;
          if (data is Map<String, dynamic>) {
            errorMessage =
                data['message'] ??
                data['error'] ??
                data['detail'] ??
                errorMessage;
          } else if (data is String) {
            errorMessage = data;
          }
        } catch (parseError) {
          // Ignore parsing errors
        }
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid file format. Please upload a valid image.');
      } else if (e.response?.statusCode == 413) {
        throw Exception('File too large. Maximum size is 5MB.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Please login again to upload avatar.');
      } else {
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ [API] Unexpected error: $e');
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  // Helper method to determine content type
  DioMediaType _getContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return DioMediaType('image', 'jpeg');
      case 'png':
        return DioMediaType('image', 'png');
      case 'gif':
        return DioMediaType('image', 'gif');
      case 'webp':
        return DioMediaType('image', 'webp');
      case 'bmp':
        return DioMediaType('image', 'bmp');
      default:
        return DioMediaType('image', 'jpeg');
    }
  }

  // ✅ FIXED: Change Password Method with proper response handling
  Future<void> changePassword(ChangePasswordRequestDto request) async {
    try {
      final response = await dio.post(
        '/users/me/password',
        data: request.toJson(),
      );

      print('📥 [API] Change Password Response:');
      print('   └─ Status Code: ${response.statusCode}');
      print('   └─ Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        String errorMessage = 'Failed to change password';
        try {
          if (response.data is Map<String, dynamic>) {
            errorMessage = response.data['message'] ?? errorMessage;
          } else if (response.data is String) {
            errorMessage = response.data;
          }
        } catch (e) {
          // Ignore parsing errors
        }
        throw Exception(errorMessage);
      }
    } on DioException catch (e) {
      print('❌ [API] Dio Exception:');
      print('   └─ Type: ${e.type}');
      print('   └─ Message: ${e.message}');
      print('   └─ Response: ${e.response?.data}');
      print('   └─ Status Code: ${e.response?.statusCode}');

      String errorMessage = e.message ?? 'Network error';
      if (e.response?.data != null) {
        try {
          final data = e.response!.data;
          if (data is Map<String, dynamic>) {
            errorMessage =
                data['message'] ??
                data['error'] ??
                data['detail'] ??
                errorMessage;
          } else if (data is String) {
            errorMessage = data;
          }
        } catch (parseError) {
          // Ignore parsing errors
        }
      }

      if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else if (e.response?.statusCode == 400) {
        throw Exception('Invalid request. Please check your password.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Current password is incorrect.');
      } else if (e.response?.statusCode == 422) {
        throw Exception('Password does not meet requirements.');
      } else {
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('❌ [API] Unexpected error: $e');
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }
}
