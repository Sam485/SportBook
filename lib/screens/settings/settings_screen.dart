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
            SliverToBoxAdapter(child: _profileIno()),
            SliverToBoxAdapter(
              child: _singleButton(
                'account',
                Icons.history,
                'History Bookings',
                'View past sessions',
              ),
            ),
            SliverToBoxAdapter(child: _multipleButton()),
            SliverToBoxAdapter(
              child: _singleButton(
                'security',
                Icons.lock_outline,
                'Passwrod & Security',
                'Last changed 3 months ago',
              ),
            ),
            SliverToBoxAdapter(child: _signOutButton()),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
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

  Widget _profileIno() {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: Container(
        width: double.infinity,
        height: 230,
        decoration: AppTheme.cardDecoration(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.kAccent, width: 1.8),
                    ),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        'https://imgs.search.brave.com/EipFQVm-X300u0qBZX5vva8FbVwDEBUGookALc-rjNM/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMucGV4ZWxzLmNv/bS9waG90b3MvMTUz/OTM1OTAvcGV4ZWxz/LXBob3RvLTE1Mzkz/NTkwL2ZyZWUtcGhv/dG8tb2YtcGhvdG8t/b2YtYS1zaGlydGxl/c3MtaGFuZHNvbWUt/bWFuLWFnYWluc3Qt/dGhlLXNreS5qcGVn/P2F1dG89Y29tcHJl/c3MmY3M9dGlueXNy/Z2ImZHByPTEmdz01/MDA',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppTheme.kCardAlt,
                          child: const Icon(
                            Icons.image_not_supported,
                            color: AppTheme.kTextSub,
                            size: 36,
                          ),
                        ),
                        loadingBuilder: (_, c, p) => p == null
                            ? c
                            : Container(
                                color: AppTheme.kCardAlt,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTheme.kAccent,
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('John Doe', style: AppTheme.tsTitle),
                      Text('johndoe@gmail.com', style: AppTheme.tsBody),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_pin,
                            color: AppTheme.kAccent,
                            size: 14,
                          ),
                          Text('New York, USA', style: AppTheme.tsAccent),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width * 0.42,
                    decoration: AppTheme.cardDecoration().copyWith(
                      borderRadius: BorderRadiusGeometry.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                      color: AppTheme.kCardAlt,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('12', style: AppTheme.tsTitle),
                          Text('Bookings', style: AppTheme.tsSub),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: 60,
                    width: MediaQuery.of(context).size.width * 0.42,
                    decoration: AppTheme.cardDecoration().copyWith(
                      borderRadius: BorderRadiusGeometry.only(
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
                      ),
                      color: AppTheme.kCardAlt,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text('3', style: AppTheme.tsTitle),
                          Text('Upcoming', style: AppTheme.tsSub),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {},
                  style: AppTheme.elevatedButtonStyle(
                    backgroundColor: AppTheme.kAccent.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit),
                      const SizedBox(width: 5),
                      Text('Edit Profile'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _singleButton(
    String label,
    IconData icon,
    String title,
    String subTitle,
  ) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTheme.tsBody),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            height: 60,
            decoration: AppTheme.cardDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppTheme.kBg),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.tsLabel.copyWith(fontSize: 14.5),
                      ),
                      Text(subTitle, style: AppTheme.tsSub),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios, color: AppTheme.kTextSub),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _multipleButton() {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PREFERENCES', style: AppTheme.tsBody),
          const SizedBox(height: 8),
          Column(
            children: [
              // Notification
              Container(
                width: double.infinity,
                height: 60,
                decoration: AppTheme.cardDecoration().copyWith(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: AppTheme.kBg,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: AppTheme.tsLabel.copyWith(fontSize: 14.5),
                          ),
                          Text(
                            'Booking reminders & alerts',
                            style: AppTheme.tsSub,
                          ),
                        ],
                      ),
                      Spacer(),
                      Switch(
                        value: _isNotificationsEnabled,
                        onChanged: (value) => setState(() {
                          value != value;
                        }),
                      ),
                    ],
                  ),
                ),
              ),
              //Language
              Container(
                width: double.infinity,
                height: 60,
                decoration: AppTheme.cardDecoration().copyWith(
                  borderRadius: BorderRadius.circular(0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.language_outlined,
                          color: AppTheme.kBg,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Language',
                            style: AppTheme.tsLabel.copyWith(fontSize: 14.5),
                          ),
                          Text('English (US)', style: AppTheme.tsSub),
                        ],
                      ),
                      Spacer(),
                      Row(
                        children: [
                          _badge('EN'),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.kTextSub,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 60,
                decoration: AppTheme.cardDecoration().copyWith(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.dark_mode_outlined,
                          color: AppTheme.kBg,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appearance',
                            style: AppTheme.tsLabel.copyWith(fontSize: 14.5),
                          ),
                          Text('Theme & display', style: AppTheme.tsSub),
                        ],
                      ),
                      Spacer(),
                      Row(
                        children: [
                          _badge('Dark'),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: AppTheme.kTextSub,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _signOutButton() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: ElevatedButton(
        onPressed: () {},
        style: AppTheme.elevatedButtonStyle(backgroundColor: Colors.red),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.logout), Text('Sign out')],
        ),
      ),
    );
  }

  Widget _badge(String data) {
    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.kBorder),
        borderRadius: BorderRadius.circular(15),
        color: AppTheme.kBg,
      ),
      child: Center(child: Text(data, style: AppTheme.tsBody)),
    );
  }
}
