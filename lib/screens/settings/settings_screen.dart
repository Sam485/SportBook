import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _profileSection()),
            // History Bookings
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: _bannerButton('History bookings', Icons.history, () {
                  // Handle button press
                }),
              ),
            ),
            // Notifications
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: _notificationSettings(
                  'Notifications',
                  Icons.notifications_outlined,
                ),
              ),
            ),
            // Manage Subscriptions
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: _bannerButton(
                  'Manage Subscriptions',
                  Icons.subscriptions,
                  () {
                    // Handle button press
                  },
                ),
              ),
            ),
            // Language
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: _bannerButton('Language', Icons.language, () {
                  // Handle button press
                }),
              ),
            ),
            // Pasword & Security
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: _bannerButton('Password & Security', Icons.lock, () {
                  // Handle button press
                }),
              ),
            ),
            // Appearance
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: _bannerButton(
                  'Appearances',
                  Icons.dark_mode_outlined,
                  () {
                    // Handle button press
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),
      child: Row(
        children: [
          Text('Settings', style: AppTheme.tsTitle.copyWith(fontSize: 22)),
          Spacer(),
          IconButton(
            onPressed: () {
              // Handle edit profile action
            },
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _profileSection() {
    return Container(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.kAccent,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          Text(
            'John Doe',
            style: AppTheme.tsTitle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'Johndoe@gmail.com | +1 234 567 890',
            style: AppTheme.tsBody.copyWith(fontSize: 14, color: Colors.grey),
          ),
          Text('Location: New York, USA', style: AppTheme.tsSub),
        ],
      ),
    );
  }

  Widget _bannerButton(String text, IconData icon, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        decoration: AppTheme.cardDecoration(radius: 20),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.kAccent),
            const SizedBox(width: 10),
            Text(text, style: AppTheme.tsBody.copyWith(fontSize: 14)),
            Spacer(),
            if (text == 'Appearances')
              Text('Dark', style: AppTheme.tsSub.copyWith(fontSize: 12)),
            Icon(
              Icons.keyboard_arrow_right_rounded,
              color: AppTheme.kTextSub,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _notificationSettings(String text, IconData icon) {
    return Container(
      decoration: AppTheme.cardDecoration(radius: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.kAccent),
          const SizedBox(width: 10),
          Text(text, style: AppTheme.tsBody.copyWith(fontSize: 14)),
          Spacer(),
          if (text == 'Appearances')
            Text('Dark', style: AppTheme.tsSub.copyWith(fontSize: 12)),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: _isNotificationsEnabled,
              onChanged: (value) {
                setState(() {
                  _isNotificationsEnabled = value;
                });
              },
              activeColor: AppTheme.kAccent,
              inactiveThumbColor: AppTheme.kTextSub,
            ),
          ),
        ],
      ),
    );
  }
}
