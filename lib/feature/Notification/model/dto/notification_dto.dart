import 'package:sportbook/feature/Notification/model/notification_model.dart';

class NotificationDto {
  final List<NotificationModel> data;
  final int total;
  final int unreadCount;
  final int page;
  final int limit;

  NotificationDto({
    required this.data,
    required this.total,
    required this.unreadCount,
    required this.page,
    required this.limit,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic>? items = json['data'] ?? json['items'] ?? json;
    return NotificationDto(
      data: items != null
          ? items.map((e) => NotificationModel.fromJson(e)).toList()
          : [],
      total: json['total'] ?? 0,
      unreadCount: json['unread_count'] ?? 0,
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 0,
    );
  }
}
