import 'package:sportbook/feature/Notification/model/dto/notification_dto.dart';
import 'package:sportbook/feature/Notification/model/notification_model.dart';

abstract class NotificationService {
  // Fetch all notifications
  Future<List<NotificationModel>> fetchNotification();
  Future<NotificationDto> getAllNotification();

  // Refresh notifications
  Future<void> refreshNotifications();

  // Mark notifications
  Future<bool> markAsRead(int notificationId);
  Future<bool> markAllAsRead();

  // Get all notification types (extracted from notifications)
  Future<List<String>> getNotificationTypes();

  // Getters
  List<NotificationModel> get notifications;
  bool get isLoading;
  String get error;
  int get unreadCount;
  List<NotificationModel> get unreadNotifications;
  List<NotificationModel> get readNotifications;

  // Filter by type
  List<NotificationModel> getNotificationsByType(String type);
}
