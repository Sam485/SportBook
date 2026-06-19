import 'package:sportbook/feature/Notification/model/dto/notification_dto.dart';
import 'package:sportbook/feature/Notification/model/notification_model.dart';
import 'package:sportbook/feature/Notification/repository/notification_repository.dart';
import 'package:sportbook/feature/Notification/service/notification_service.dart';

class NotificationServiceImp implements NotificationService {
  final NotificationRepository _repository;

  // State management
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String _error = '';
  List<String> _notificationTypes = [];

  // Getters
  @override
  List<NotificationModel> get notifications => _notifications;

  @override
  bool get isLoading => _isLoading;

  @override
  String get error => _error;

  NotificationServiceImp(this._repository);

  @override
  Future<List<NotificationModel>> fetchNotification() async {
    _isLoading = true;
    _error = '';

    try {
      final dto = await getAllNotification();
      _notifications = dto.data;

      // Extract unique types from notifications
      _extractNotificationTypes();

      _isLoading = false;
      return _notifications;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      rethrow;
    }
  }

  @override
  Future<NotificationDto> getAllNotification() async {
    try {
      return await _repository.getNotification();
    } catch (e) {
      throw Exception('Fail to retrieve data: $e');
    }
  }

  @override
  Future<void> refreshNotifications() async {
    await fetchNotification();
  }

  @override
  Future<bool> markAsRead(int notificationId) async {
    try {
      final result = await _repository.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = _notifications[index].copyWith(isRead: true);
      }

      return result;
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  @override
  Future<bool> markAllAsRead() async {
    try {
      // Check if there are any unread notifications
      if (unreadCount == 0) {
        return true; // Nothing to mark
      }

      final result = await _repository.markAllAsRead();

      // Update local state
      _notifications = _notifications.map((n) {
        return n.copyWith(isRead: true);
      }).toList();

      return result;
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: $e');
    }
  }

  @override
  Future<List<String>> getNotificationTypes() async {
    // If we already have types cached, return them
    if (_notificationTypes.isNotEmpty) {
      return _notificationTypes;
    }

    // Extract from local notifications
    _extractNotificationTypes();
    return _notificationTypes;
  }

  // Helper method to extract unique types from notifications
  void _extractNotificationTypes() {
    final types = <String>{};
    for (final notification in _notifications) {
      if (notification.type.isNotEmpty) {
        types.add(notification.type);
      }
    }
    _notificationTypes = types.toList();

    // Sort alphabetically
    if (_notificationTypes.isNotEmpty) {
      _notificationTypes.sort();
    }
  }

  @override
  int get unreadCount {
    return _notifications.where((n) => !n.isRead).length;
  }

  @override
  List<NotificationModel> get unreadNotifications {
    return _notifications.where((n) => !n.isRead).toList();
  }

  @override
  List<NotificationModel> get readNotifications {
    return _notifications.where((n) => n.isRead).toList();
  }

  @override
  List<NotificationModel> getNotificationsByType(String type) {
    if (type == 'all') {
      return _notifications;
    }
    return _notifications.where((n) => n.type == type).toList();
  }
}
