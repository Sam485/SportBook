import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Notification/service/notification_service.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/translations/app_translations.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final _notificationService = getIt<NotificationService>();
  final _tokenService = getIt<TokenService>();

  String _selectedCat = 'all';
  List<String> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isDisposed = false;
  bool _isCheckingAuth = true;

  // ✅ Get user-friendly error message
  String get _userFriendlyErrorMessage {
    if (_errorMessage.isEmpty) return 'something_went_wrong'.tr(context);

    final msg = _errorMessage.toLowerCase();
    if (msg.contains('timeout') || msg.contains('timed out')) {
      return 'connection_timeout'.tr(context);
    } else if (msg.contains('network') || msg.contains('internet')) {
      return 'network_error'.tr(context);
    } else if (msg.contains('401') || msg.contains('unauthorized')) {
      return 'unauthorized'.tr(context);
    } else if (msg.contains('500') || msg.contains('server')) {
      return 'server_error'.tr(context);
    } else if (msg.contains('404') || msg.contains('not found')) {
      return 'not_found'.tr(context);
    } else {
      return 'something_went_wrong'.tr(context);
    }
  }

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // ✅ Check if user is authenticated
  Future<void> _checkAuthentication() async {
    setState(() {
      _isCheckingAuth = true;
    });

    try {
      final hasValidToken = await _tokenService.hasValidTokenAsync();

      if (!hasValidToken) {
        // Try to refresh token
        final refreshToken = await _tokenService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshed = await _tokenService.refreshAccessToken();
          if (!refreshed) {
            // Not authenticated - redirect to login
            _redirectToLogin();
            return;
          }
        } else {
          // No token - redirect to login
          _redirectToLogin();
          return;
        }
      }

      // User is authenticated, load notifications
      setState(() {
        _isCheckingAuth = false;
      });
      _loadNotifications();
    } catch (e) {
      _redirectToLogin();
    }
  }

  // ✅ Redirect to login screen
  void _redirectToLogin() {
    if (!_isDisposed && mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      });
    }
  }

  Future<void> _loadNotifications() async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      await _notificationService.fetchNotification();

      // Get unique categories from notifications
      final types = await _notificationService.getNotificationTypes();

      if (!_isDisposed && mounted) {
        setState(() {
          _categories = ['all', ...types.where((t) => t != 'all')];
          _isLoading = false;
          _hasError = false;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _errorMessage = e.toString();
          _hasError = true;
          _isLoading = false;
        });
      }
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

  Future<void> _markAllAsRead() async {
    if (_isDisposed) return;

    try {
      setState(() {});

      final result = await _notificationService.markAllAsRead();

      if (result && !_isDisposed && mounted) {
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
      if (!_isDisposed && mounted) {
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
    if (_isDisposed) return;

    try {
      await _notificationService.markAsRead(id);
      if (!_isDisposed && mounted) {
        setState(() {});
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to mark as read: $e');
      }
    }
  }

  void _showNotificationDetail(NotificationItem notification) {
    if (_isDisposed) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => NotificationDetailDialog(
        notification: notification,
        onConfirm: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Show loading while checking auth
    if (_isCheckingAuth) {
      return Scaffold(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppTheme.kAccent,
                strokeWidth: 3,
              ),
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
          if (_notificationService.unreadCount > 0)
            IconButton(
              icon: Icon(
                Icons.done_all,
                color: isDark ? Colors.white : AppTheme.kLightText,
              ),
              onPressed: _markAllAsRead,
            ),
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

    // ✅ Show friendly error message
    if (_hasError) {
      return SliverFillRemaining(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.wifi_off_rounded,
                  size: 64,
                  color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
                ),
                const SizedBox(height: 16),
                Text(
                  _userFriendlyErrorMessage,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
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
                    : 'no_notifications_in_category'
                          .tr(context)
                          .replaceAll('{category}', _selectedCat),
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
          // Show notification detail dialog
          _showNotificationDetail(notification);
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

// ============================================================================
// Notification Detail Dialog
// ============================================================================

class NotificationDetailDialog extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onConfirm;

  const NotificationDetailDialog({
    super.key,
    required this.notification,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: size.width * 0.92,
        constraints: BoxConstraints(
          maxWidth: 420,
          maxHeight: size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.kCard : Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image
            Container(
              height: 190,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                image: const DecorationImage(
                  image: NetworkImage(
                    'https://images.unsplash.com/photo-1511882150382-421056c89033?w=800&h=400&fit=crop&crop=center',
                  ),
                  fit: BoxFit.cover,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      isDark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.black.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.kAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        notification.category,
                        style: TextStyle(
                          color: const Color(0xFF0A1828),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  notification.title,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.3,
                  ),
                  maxLines: 2,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  notification.description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey[700],
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Divider line
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              height: 1,
              color: isDark ? Colors.grey[800] : Colors.grey[200],
            ),

            const SizedBox(height: 16),

            // OK Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.kAccent,
                    foregroundColor: const Color(0xFF0A1828),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'OK',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
