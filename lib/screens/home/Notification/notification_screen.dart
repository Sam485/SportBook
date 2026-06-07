import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<String> category = [
    'All',
    'Bookings',
    'Alerts',
    'Messages',
    'Promotions',
  ];
  String _selectedCat = 'All';

  // Sample notification data
  final List<NotificationItem> notifications = [
    NotificationItem(
      icon: Icons.check_circle,
      title: 'Booking Confirmed',
      description: 'Your booking at Victory FC Club has been confirmed.',
      datetime: 'Today - 2 mins ago',
      category: 'Bookings',
      iconColor: Colors.green,
    ),
    NotificationItem(
      icon: Icons.sports_soccer,
      title: 'Match Reminder',
      description: 'Manchester United vs Liverpool starts in 2 hours.',
      datetime: 'Today - 1 hour ago',
      category: 'Alerts',
      iconColor: Colors.orange,
    ),
    NotificationItem(
      icon: Icons.message,
      title: 'New Message from Coach',
      description: 'Practice session rescheduled to 5 PM tomorrow.',
      datetime: 'Yesterday - 8:30 PM',
      category: 'Messages',
      iconColor: Colors.blue,
    ),
    NotificationItem(
      icon: Icons.local_offer,
      title: 'Weekend Special Offer',
      description: 'Get 20% off on all turf bookings this weekend!',
      datetime: 'Yesterday - 10:15 AM',
      category: 'Promotions',
      iconColor: Colors.purple,
    ),
    NotificationItem(
      icon: Icons.event_available,
      title: 'Payment Successful',
      description:
          'Your payment of ₹1500 for Victory FC Club has been received.',
      datetime: 'Jan 15, 2026 - 3:30 PM',
      category: 'Bookings',
      iconColor: Colors.green,
    ),
    NotificationItem(
      icon: Icons.warning,
      title: 'Match Cancelled',
      description: 'Sunday\'s match has been cancelled due to bad weather.',
      datetime: 'Jan 14, 2026 - 9:00 AM',
      category: 'Alerts',
      iconColor: Colors.red,
    ),
    NotificationItem(
      icon: Icons.people,
      title: 'Team Invitation',
      description: 'You\'ve been invited to join "Weekend Warriors" team.',
      datetime: 'Jan 13, 2026 - 6:45 PM',
      category: 'Messages',
      iconColor: Colors.teal,
    ),
    NotificationItem(
      icon: Icons.emoji_events,
      title: 'Tournament Alert',
      description: 'Registration for Summer Cup 2026 is now open!',
      datetime: 'Jan 12, 2026 - 2:00 PM',
      category: 'Alerts',
      iconColor: Colors.amber,
    ),
    NotificationItem(
      icon: Icons.star,
      title: 'Achievement Unlocked',
      description:
          'You\'ve completed 10 bookings! Bronze member badge awarded.',
      datetime: 'Jan 10, 2026 - 11:20 AM',
      category: 'Promotions',
      iconColor: Colors.yellow,
    ),
    NotificationItem(
      icon: Icons.refresh,
      title: 'Booking Rescheduled',
      description: 'Your booking has been rescheduled to Jan 20th at 6 PM.',
      datetime: 'Jan 9, 2026 - 4:15 PM',
      category: 'Bookings',
      iconColor: Colors.orange,
    ),
    NotificationItem(
      icon: Icons.feedback,
      title: 'Rate Your Experience',
      description:
          'How was your recent match at Victory FC Club? Leave a review!',
      datetime: 'Jan 8, 2026 - 10:00 AM',
      category: 'Messages',
      iconColor: Colors.indigo,
    ),
    NotificationItem(
      icon: Icons.card_giftcard,
      title: 'Birthday Special',
      description: 'Happy Birthday! Enjoy a free session on us this week.',
      datetime: 'Jan 5, 2026 - 12:00 PM',
      category: 'Promotions',
      iconColor: Colors.pink,
    ),
  ];

  List<NotificationItem> get _filteredNotifications {
    if (_selectedCat == 'All') {
      return notifications;
    }
    return notifications.where((n) => n.category == _selectedCat).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Notifications', style: AppTheme.tsTitle),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All notifications marked as read'),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Category Sliver
            SliverToBoxAdapter(child: _category()),

            // Notifications List Sliver
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              sliver: _filteredNotifications.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No notifications in ${_selectedCat.toLowerCase()}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return _notificationCard(_filteredNotifications[index]);
                      }, childCount: _filteredNotifications.length),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _category() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: category.length,
          itemBuilder: (_, i) {
            final cat = category[i];
            final sel = _selectedCat == cat;
            return GestureDetector(
              onTap: () => setState(() => _selectedCat = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.kAccent : AppTheme.kCard,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: sel ? AppTheme.kAccent : AppTheme.kBorder,
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
                    Text(
                      cat,
                      style: TextStyle(
                        color: sel ? const Color(0xFF0A1828) : Colors.white60,
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

  Widget _notificationCard(NotificationItem notification) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Opened: ${notification.title}')),
          );
        },
        child: Container(
          width: double.infinity,
          decoration: AppTheme.cardDecoration(),
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
              style: AppTheme.tsTitle.copyWith(fontSize: 15),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  notification.description,
                  style: AppTheme.tsBody.copyWith(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  notification.datetime,
                  style: AppTheme.tsSub.copyWith(fontSize: 11),
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

// Notification Model
class NotificationItem {
  final IconData icon;
  final String title;
  final String description;
  final String datetime;
  final String category;
  final Color iconColor;
  bool isRead;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.datetime,
    required this.category,
    required this.iconColor,
    this.isRead = false,
  });
}
