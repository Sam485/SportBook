import 'package:dio/dio.dart';
import 'package:sportbook/feature/Notification/model/dto/notification_dto.dart';

class NotificationRepository {
  final Dio _dio;
  NotificationRepository(this._dio);

  Future<NotificationDto> getNotification() async {
    try {
      final response = await _dio.get(
        '/users/me/notifications?page=1&limit=20&unread=false',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return NotificationDto.fromJson(response.data);
      } else {
        throw Exception('Error with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Server error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }

  // Fixed: Accepts a single ID or a list of IDs
  Future<bool> markAsRead(int notificationId) async {
    try {
      final response = await _dio.put(
        '/users/me/notifications/read',
        data: {
          'ids': [notificationId],
        }, // Send as list
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Server error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  // Fixed: Returns bool, not response.data
  Future<bool> markAllAsRead() async {
    try {
      final response = await _dio.put(
        '/users/me/notifications/read-all',
        // Some APIs might expect a body
        // data: {}, // Uncomment if needed
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; // Return bool, not response.data
      } else {
        throw Exception('Error with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Server error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }

  // Optional: Mark multiple notifications as read at once
  Future<bool> markMultipleAsRead(List<int> ids) async {
    try {
      final response = await _dio.put(
        '/users/me/notifications/read',
        data: {'ids': ids},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Error with status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Server error: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
  }
}
