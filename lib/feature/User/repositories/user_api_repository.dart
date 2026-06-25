import 'dart:io';
import 'package:dio/dio.dart';
import 'package:sportbook/feature/User/model/change_pass_reqeuest_dto.dart';
import 'package:sportbook/feature/User/model/login_request_dto.dart';
import 'package:sportbook/feature/User/model/login_response_model.dart';
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
    try {
      final response = await dio.post(
        '/auth/phone-login',
        data: {'firebase_token': firebaseToken, 'fcm_token': fcmToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw Exception('Phone login failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        'Server error: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // Firebase OTP Sign Up
  Future<LoginResponse> registerUserWithFirebase({
    required RegisterRequestDto userData,
    required String firebaseToken,
    required String fcmToken,
  }) async {
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponse.fromJson(response.data);
      } else {
        throw Exception('Phone registration failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception(
        'Server error: ${e.response?.data['message'] ?? e.message}',
      );
    } catch (e) {
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
  // feature/User/repositories/user_api_repository.dart
  // ✅ FIXED: Avatar upload with proper multipart handling
  Future<UserModel> updateAvatar(File avatar) async {
    try {
      // Check if file exists
      if (!await avatar.exists()) {
        throw Exception('File does not exist: ${avatar.path}');
      }

      // Get file size
      final fileSize = await avatar.length();

      // Check file size (max 5MB)
      if (fileSize > 5 * 1024 * 1024) {
        throw Exception('File too large. Maximum size is 5MB.');
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

      final response = await dio.post(
        '/users/me/avatar',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          followRedirects: true,
          maxRedirects: 5,
          validateStatus: (status) {
            // Allow all status codes to be handled in code
            return status != null && status < 500;
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Try to parse the response
        UserModel? updatedUser;

        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;

          // If response contains user data directly
          if (data.containsKey('id') || data.containsKey('full_name')) {
            updatedUser = UserModel.fromJson(data);
          }
          // If response contains user wrapped in data field
          else if (data.containsKey('data')) {
            final userData = data['data'];
            if (userData is Map<String, dynamic>) {
              updatedUser = UserModel.fromJson(userData);
            }
          }
          // If response just contains avatar URL
          else if (data.containsKey('avatar_url')) {
            // Fetch full user data
            updatedUser = await getProfile();
          }
        }

        // If we couldn't parse the response, fetch fresh user data
        updatedUser ??= await getProfile();

        return updatedUser;
      } else {
        throw Exception('Upload failed: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Try to extract error message
      String errorMessage = 'Upload failed';
      if (e.response?.data != null) {
        try {
          final data = e.response!.data;
          if (data is Map<String, dynamic>) {
            errorMessage =
                data['message'] ??
                data['error'] ??
                data['detail'] ??
                'Upload failed';
          } else if (data is String) {
            errorMessage = data;
          }
        } catch (parseError) {
          // Ignore parsing errors
        }
      }

      // Handle specific error codes
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid file format. Please upload a valid image.');
      } else if (e.response?.statusCode == 413) {
        throw Exception('File too large. Maximum size is 5MB.');
      } else if (e.response?.statusCode == 401) {
        throw Exception('Please login again to upload avatar.');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        throw Exception(
          'Connection timeout. Please check your internet connection.',
        );
      } else if (e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Receive timeout. Server is not responding.');
      } else {
        throw Exception(errorMessage);
      }
    } catch (e) {
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
      final response = await dio.put(
        '/users/me/password',
        data: request.toJson(),
      );

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
      throw Exception('Unexpected error: ${e.toString()}');
    }
  }

  // feature/User/repositories/user_api_repository.dart
  Future<void> forgotPassword({
    required String firebaseToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await dio.post(
        '/auth/forgot-password',
        data: {
          'firebase_token': firebaseToken,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw Exception('Failed to reset password: ${response.statusCode}');
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
