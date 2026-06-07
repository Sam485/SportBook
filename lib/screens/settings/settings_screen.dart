import 'package:flutter/material.dart';
import 'package:sportbook/screens/settings/features/appearance_selection.dart';
import 'package:sportbook/screens/settings/features/editing_profile.dart';
import 'package:sportbook/screens/settings/features/history_booking.dart';
import 'package:sportbook/screens/settings/features/language_selection.dart';
import 'package:sportbook/screens/settings/features/password_security.dart';
import '../../core/theme.dart';
import '../../models/models.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationsEnabled = true;

  // User profile data
  String _userName = 'John Doe';
  String _userEmail = 'johndoe@gmail.com';
  String _userLocation = 'New York, USA';
  String _userImageUrl =
      'https://imgs.search.brave.com/EipFQVm-X300u0qBZX5vva8FbVwDEBUGookALc-rjNM/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMucGV4ZWxzLmNv/bS9waG90b3MvMTUz/OTM1OTAvcGV4ZWxz/LXBob3RvLTE1Mzkz/NTkwL2ZyZWUtcGhv/dG8tb2YtcGhvdG8t/b2YtYS1zaGlydGxl/c3MtaGFuZHNvbWUt/bWFuLWFnYWluc3Qt/dGhlLXNreS5qcGVn/P2F1dG89Y29tcHJl/c3MmY3M9dGlueXNy/Z2ImZHByPTEmdz01/MDA';

  // Language and theme
  String _currentLanguage = 'EN';
  String _currentTheme = 'dark';

  // Sample history bookings (replace with actual data)
  List<SportBooking> _historyBookings = [];

  @override
  void initState() {
    super.initState();
    _loadSampleHistoryBookings();
  }

  void _loadSampleHistoryBookings() {
    // Add sample history bookings - replace with your actual data
    // _historyBookings = your actual history bookings list
  }

  // Navigation Methods
  void _navigateToHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HistoryBookingsScreen(historyBookings: _historyBookings),
      ),
    );
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          currentName: _userName,
          currentEmail: _userEmail,
          currentLocation: _userLocation,
          currentImageUrl: _userImageUrl,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        if (result['name'] != null) _userName = result['name'];
        if (result['email'] != null) _userEmail = result['email'];
        if (result['location'] != null) _userLocation = result['location'];
        // Handle image if needed
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }
  }

  void _navigateToPasswordSecurity() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasswordSecurityScreen()),
    );
  }

  void _showLanguageSelector() async {
    final selectedLanguage = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelector(currentLanguage: _currentLanguage),
    );

    if (selectedLanguage != null && mounted) {
      setState(() {
        _currentLanguage = selectedLanguage;
      });
    }
  }

  void _showAppearanceSelector() async {
    final selectedTheme = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppearanceSelector(currentTheme: _currentTheme),
    );

    if (selectedTheme != null && mounted) {
      setState(() {
        _currentTheme = selectedTheme;
      });
    }
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.kCard,
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppTheme.kTextSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.kTextSub),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: AppTheme.elevatedButtonStyle(backgroundColor: Colors.red),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _profileInfo()),
            SliverToBoxAdapter(
              child: _singleButton(
                'account',
                Icons.history,
                'History Bookings',
                'View past sessions',
                onTap: _navigateToHistory,
              ),
            ),
            SliverToBoxAdapter(child: _multipleButton()),
            SliverToBoxAdapter(
              child: _singleButton(
                'security',
                Icons.lock_outline,
                'Password & Security',
                'Last changed 3 months ago',
                onTap: _navigateToPasswordSecurity,
              ),
            ),
            SliverToBoxAdapter(child: _signOutButton()),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
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
          const Spacer(),
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

  Widget _profileInfo() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: GestureDetector(
        onTap: _navigateToEditProfile,
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
                        child: _userImageUrl.isNotEmpty
                            ? Image.network(
                                _userImageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppTheme.kCardAlt,
                                  child: const Icon(
                                    Icons.person,
                                    size: 36,
                                    color: AppTheme.kTextSub,
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
                              )
                            : Container(
                                color: AppTheme.kCardAlt,
                                child: const Icon(
                                  Icons.person,
                                  size: 36,
                                  color: AppTheme.kTextSub,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_userName, style: AppTheme.tsTitle),
                          Text(_userEmail, style: AppTheme.tsBody),
                          Row(
                            children: [
                              Icon(
                                Icons.location_pin,
                                color: AppTheme.kAccent,
                                size: 14,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  _userLocation,
                                  style: AppTheme.tsAccent,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.edit, color: AppTheme.kAccent, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: AppTheme.cardDecoration().copyWith(
                          borderRadius: const BorderRadius.only(
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
                    ),
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: AppTheme.cardDecoration().copyWith(
                          borderRadius: const BorderRadius.only(
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
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: _navigateToEditProfile,
                    style: AppTheme.elevatedButtonStyle(
                      backgroundColor: AppTheme.kAccent.withOpacity(0.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, size: 18),
                        SizedBox(width: 5),
                        Text('Edit Profile'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _singleButton(
    String label,
    IconData icon,
    String title,
    String subTitle, {
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: AppTheme.tsBody),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
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
                        color: AppTheme.kTextSub,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: AppTheme.kBg),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTheme.tsLabel.copyWith(fontSize: 14.5),
                          ),
                          Text(subTitle, style: AppTheme.tsSub),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.kTextSub,
                      size: 16,
                    ),
                  ],
                ),
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
                  borderRadius: const BorderRadius.only(
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
                          color: AppTheme.kTextSub,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: AppTheme.kBg,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
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
                      ),
                      Switch(
                        value: _isNotificationsEnabled,
                        onChanged: (value) => setState(() {
                          _isNotificationsEnabled = value;
                        }),
                        activeColor: AppTheme.kAccent,
                      ),
                    ],
                  ),
                ),
              ),
              // Language
              GestureDetector(
                onTap: _showLanguageSelector,
                child: Container(
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
                            color: AppTheme.kTextSub,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.language_outlined,
                            color: AppTheme.kBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Language',
                                style: AppTheme.tsLabel.copyWith(
                                  fontSize: 14.5,
                                ),
                              ),
                              Text(
                                _currentLanguage == 'EN'
                                    ? 'English (US)'
                                    : 'Khmer',
                                style: AppTheme.tsSub,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _badge(_currentLanguage),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.kTextSub,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Appearance
              GestureDetector(
                onTap: _showAppearanceSelector,
                child: Container(
                  width: double.infinity,
                  height: 60,
                  decoration: AppTheme.cardDecoration().copyWith(
                    borderRadius: const BorderRadius.only(
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
                            color: AppTheme.kTextSub,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.dark_mode_outlined,
                            color: AppTheme.kBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appearance',
                                style: AppTheme.tsLabel.copyWith(
                                  fontSize: 14.5,
                                ),
                              ),
                              Text(
                                _currentTheme == 'dark'
                                    ? 'Dark Mode'
                                    : (_currentTheme == 'light'
                                          ? 'Light Mode'
                                          : 'System Default'),
                                style: AppTheme.tsSub,
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _badge(
                              _currentTheme == 'dark'
                                  ? 'Dark'
                                  : (_currentTheme == 'light'
                                        ? 'Light'
                                        : 'System'),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.kTextSub,
                              size: 16,
                            ),
                          ],
                        ),
                      ],
                    ),
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
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: _signOut,
        style: AppTheme.elevatedButtonStyle(backgroundColor: Colors.red),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.logout), SizedBox(width: 8), Text('Sign out')],
        ),
      ),
    );
  }

  Widget _badge(String data) {
    return Container(
      height: 30,
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.kBorder),
        borderRadius: BorderRadius.circular(15),
        color: AppTheme.kBg,
      ),
      child: Center(child: Text(data, style: AppTheme.tsBody)),
    );
  }
}
