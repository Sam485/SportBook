import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Notification/service/notification_service.dart';
import 'package:sportbook/translations/app_translations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notificationService = getIt<NotificationService>();

  String _selectedCat = 'all';
  List<String> _categories = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      await _notificationService.fetchNotification();

      // Get unique categories from notifications
      final types = await _notificationService.getNotificationTypes();

      setState(() {
        _categories = ['all', ...types.where((t) => t != 'all')];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<NotificationItem> get _filteredNotifications {
    final notifications = _notificationService.notifications;

    if (_selectedCat == 'all') {
      return notifications
          .map(
            (n) => NotificationItem(
              id: n.id,
              title: n.title,
              description: n.body,
              icon: _getIconForType(n.type),
              iconColor: _getColorForType(n.type),
              datetime: _formatDate(n.createdAt),
              category: n.type,
              isRead: n.isRead,
            ),
          )
          .toList();
    }

    return notifications
        .where((n) => n.type == _selectedCat)
        .map(
          (n) => NotificationItem(
            id: n.id,
            title: n.title,
            description: n.body,
            icon: _getIconForType(n.type),
            iconColor: _getColorForType(n.type),
            datetime: _formatDate(n.createdAt),
            category: n.type,
            isRead: n.isRead,
          ),
        )
        .toList();
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'bookings':
        return Icons.calendar_today;
      case 'alerts':
        return Icons.warning_amber_rounded;
      case 'messages':
        return Icons.message_rounded;
      case 'promotions':
        return Icons.local_offer_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'bookings':
        return Colors.blue;
      case 'alerts':
        return Colors.orange;
      case 'messages':
        return Colors.green;
      case 'promotions':
        return Colors.purple;
      default:
        return AppTheme.kAccent;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Add this to the NotificationScreen class
  Future<void> _markAllAsRead() async {
    try {
      // Show loading indicator
      setState(() {});

      final result = await _notificationService.markAllAsRead();

      if (result && mounted) {
        setState(() {});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('all_notifications_read'.tr(context)),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all as read: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _notificationService.markAsRead(id);
      setState(() {});
    } catch (e) {
      // Silent fail
      if (kDebugMode) {
        print('Failed to mark as read: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: AppBar(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'notifications'.tr(context),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          // Mark all as read button
          if (_notificationService.unreadCount > 0)
            IconButton(
              icon: Icon(
                Icons.done_all,
                color: isDark ? Colors.white : AppTheme.kLightText,
              ),
              onPressed: _markAllAsRead,
            ),
          // Refresh button
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: isDark ? Colors.white : AppTheme.kLightText,
            ),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            if (_categories.isNotEmpty)
              SliverToBoxAdapter(child: _category(isDark)),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              sliver: _buildContent(isDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.kAccent),
              const SizedBox(height: 16),
              Text(
                'loading'.tr(context),
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
              ),
              const SizedBox(height: 16),
              Text(
                'error'.tr(context),
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadNotifications,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kAccent,
                  foregroundColor: const Color(0xFF0A1828),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text('retry'.tr(context)),
              ),
            ],
          ),
        ),
      );
    }

    final filtered = _filteredNotifications;

    if (filtered.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notifications_none,
                size: 80,
                color: isDark ? Colors.grey[600] : Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                _selectedCat == 'all'
                    ? 'no_notifications'.tr(context)
                    : 'No notifications in $_selectedCat',
                style: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return _notificationCard(filtered[index], isDark);
      }, childCount: filtered.length),
    );
  }

  Widget _category(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _categories.length,
          itemBuilder: (_, i) {
            final catKey = _categories[i];
            final catDisplayName = _getCategoryDisplayName(catKey);
            final sel = _selectedCat == catKey;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = catKey),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.kAccent
                      : (isDark ? AppTheme.kCard : AppTheme.kLightCard),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: sel
                        ? AppTheme.kAccent
                        : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                  ),
                  boxShadow: sel
                      ? [
                          BoxShadow(
                            color: AppTheme.kAccent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (catKey != 'all') ...[
                      Icon(
                        _getIconForType(catKey),
                        color: sel
                            ? const Color(0xFF0A1828)
                            : (isDark
                                  ? Colors.white60
                                  : AppTheme.kLightTextSub),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      catDisplayName,
                      style: TextStyle(
                        color: sel
                            ? const Color(0xFF0A1828)
                            : (isDark
                                  ? Colors.white60
                                  : AppTheme.kLightTextSub),
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getCategoryDisplayName(String categoryKey) {
    switch (categoryKey) {
      case 'all':
        return 'all'.tr(context);
      case 'bookings':
        return 'bookings'.tr(context);
      case 'alerts':
        return 'alerts'.tr(context);
      case 'messages':
        return 'messages'.tr(context);
      case 'promotions':
        return 'promotions'.tr(context);
      default:
        return categoryKey;
    }
  }

  Widget _notificationCard(NotificationItem notification, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          // Mark as read when tapped
          if (!notification.isRead) {
            _markAsRead(notification.id);
          }
          // Navigate to notification detail or handle the notification
          _handleNotificationTap(notification);
        },
        child: Container(
          width: double.infinity,
          decoration: AppTheme.cardDecorationAdaptive(context),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.iconColor.withOpacity(0.2),
              ),
              child: Icon(
                notification.icon,
                color: notification.iconColor,
                size: 24,
              ),
            ),
            title: Text(
              notification.title,
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 15,
                fontWeight: notification.isRead
                    ? FontWeight.w600
                    : FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.datetime,
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            trailing: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: notification.isRead
                    ? Colors.transparent
                    : AppTheme.kAccent,
              ),
            ),
            isThreeLine: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Handle different notification types
    switch (notification.category) {
      case 'bookings':
        // Navigate to booking details
        if (kDebugMode) {
          print('Navigate to booking: ${notification.id}');
        }
        break;
      case 'alerts':
        // Show alert dialog or navigate
        if (kDebugMode) {
          print('Show alert: ${notification.id}');
        }
        break;
      case 'messages':
        // Navigate to message
        break;
      case 'promotions':
        // Show promotion details
        break;
      default:
        // Default action
        break;
    }
  }
}

// Keep your existing NotificationItem model
class NotificationItem {
  final int id;
  final String title;
  final String description;
  final IconData icon;
  final Color iconColor;
  final String datetime;
  final String category;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.datetime,
    required this.category,
    required this.isRead,
  });
}
