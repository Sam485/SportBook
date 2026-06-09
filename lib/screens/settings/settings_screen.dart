import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportbook/screens/settings/features/appearance_selection.dart';
import 'package:sportbook/screens/settings/features/editing_profile.dart';
import 'package:sportbook/screens/settings/features/history_booking.dart';
import 'package:sportbook/screens/settings/features/language_selection.dart';
import 'package:sportbook/screens/settings/features/password_security.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/theme_provider.dart'; // Add this import

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
  final String _userImageUrl =
      'https://imgs.search.brave.com/EipFQVm-X300u0qBZX5vva8FbVwDEBUGookALc-rjNM/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMucGV4ZWxzLmNv/bS9waG90b3MvMTUz/OTM1OTAvcGV4ZWxz/LXBob3RvLTE1Mzkz/NTkwL2ZyZWUtcGhv/dG8tb2YtcGhvdG8t/b2YtYS1zaGlydGxl/c3MtaGFuZHNvbWUt/bWFuLWFnYWluc3Qt/dGhlLXNreS5qcGVn/P2F1dG89Y29tcHJl/c3MmY3M9dGlueXNy/Z2ImZHByPTEmdz01/MDA';

  // Language state (keep this as it's separate from theme)
  String _currentLanguage = 'EN';

  // Remove this line - we'll get theme from provider instead:
  // String _currentTheme = 'dark';

  // Sample history bookings
  final List<SportBooking> _historyBookings = [];

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
    // Get theme provider
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final selectedTheme = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AppearanceSelector(
        currentTheme: themeProvider.currentTheme, // Get from provider
      ),
    );

    if (selectedTheme != null && mounted) {
      // Trigger rebuild to update the UI
      setState(() {});
    }
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card(context),
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
    // Listen to theme provider for changes
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              scrollBehavior: const ScrollBehavior().copyWith(
                overscroll: false,
              ),
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
                SliverToBoxAdapter(child: _multipleButton(themeProvider)),
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
      },
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Text('Settings', style: AppTheme.tsTitleAdaptive(context)),
          const Spacer(),
          IconButton(
            onPressed: () {
              // Handle edit profile action
            },
            icon: Icon(Icons.settings, color: AppTheme.textPrimary(context)),
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
          decoration: AppTheme.cardDecorationAdaptive(context),
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
                                  color: AppTheme.cardAlt(context),
                                  child: Icon(
                                    Icons.person,
                                    size: 36,
                                    color: AppTheme.textSub(context),
                                  ),
                                ),
                                loadingBuilder: (_, c, p) => p == null
                                    ? c
                                    : Container(
                                        color: AppTheme.cardAlt(context),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: AppTheme.kAccent,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                              )
                            : Container(
                                color: AppTheme.cardAlt(context),
                                child: Icon(
                                  Icons.person,
                                  size: 36,
                                  color: AppTheme.textSub(context),
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
                          Text(
                            _userName,
                            style: AppTheme.tsTitleAdaptive(context),
                          ),
                          Text(
                            _userEmail,
                            style: AppTheme.tsBodyAdaptive(context),
                          ),
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
                                  style: const TextStyle(
                                    color: AppTheme.kAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.edit, color: AppTheme.kAccent, size: 20),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: AppTheme.cardDecorationAdaptive(context)
                            .copyWith(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                              ),
                              color: AppTheme.cardAlt(context),
                            ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                '12',
                                style: AppTheme.tsTitleAdaptive(context),
                              ),
                              Text(
                                'Bookings',
                                style: AppTheme.tsSubAdaptive(context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 60,
                        decoration: AppTheme.cardDecorationAdaptive(context)
                            .copyWith(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                              color: AppTheme.cardAlt(context),
                            ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                '3',
                                style: AppTheme.tsTitleAdaptive(context),
                              ),
                              Text(
                                'Upcoming',
                                style: AppTheme.tsSubAdaptive(context),
                              ),
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
          Text(label.toUpperCase(), style: AppTheme.tsBodyAdaptive(context)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 60,
              decoration: AppTheme.cardDecorationAdaptive(context),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Container(
                      width: 45,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.textSub(context),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: AppTheme.bg(context)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: AppTheme.tsLabelAdaptive(
                              context,
                            ).copyWith(fontSize: 14.5),
                          ),
                          Text(
                            subTitle,
                            style: AppTheme.tsSubAdaptive(context),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: AppTheme.textSub(context),
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

  Widget _multipleButton(ThemeProvider themeProvider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PREFERENCES', style: AppTheme.tsBodyAdaptive(context)),
          const SizedBox(height: 8),
          Column(
            children: [
              // Notification
              Container(
                width: double.infinity,
                height: 60,
                decoration: AppTheme.cardDecorationAdaptive(context).copyWith(
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
                          color: AppTheme.textSub(context),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.notifications_outlined,
                          color: isDark ? AppTheme.kBg : AppTheme.kLightBg,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notifications',
                              style: AppTheme.tsLabelAdaptive(
                                context,
                              ).copyWith(fontSize: 14.5),
                            ),
                            Text(
                              'Booking reminders & alerts',
                              style: AppTheme.tsSubAdaptive(context),
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
                  decoration: AppTheme.cardDecorationAdaptive(
                    context,
                  ).copyWith(borderRadius: BorderRadius.circular(0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 45,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.textSub(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.language_outlined,
                            color: isDark ? AppTheme.kBg : AppTheme.kLightBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Language',
                                style: AppTheme.tsLabelAdaptive(
                                  context,
                                ).copyWith(fontSize: 14.5),
                              ),
                              Text(
                                _currentLanguage == 'EN'
                                    ? 'English (US)'
                                    : 'Khmer',
                                style: AppTheme.tsSubAdaptive(context),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _badge(_currentLanguage),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.textSub(context),
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
                  decoration: AppTheme.cardDecorationAdaptive(context).copyWith(
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
                            color: AppTheme.textSub(context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.dark_mode_outlined,
                            color: isDark ? AppTheme.kBg : AppTheme.kLightBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appearance',
                                style: AppTheme.tsLabelAdaptive(
                                  context,
                                ).copyWith(fontSize: 14.5),
                              ),
                              Text(
                                themeProvider.currentTheme == 'dark'
                                    ? 'Dark Mode'
                                    : (themeProvider.currentTheme == 'light'
                                          ? 'Light Mode'
                                          : 'System Default'),
                                style: AppTheme.tsSubAdaptive(context),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _badge(
                              themeProvider.currentTheme == 'dark'
                                  ? 'Dark'
                                  : (themeProvider.currentTheme == 'light'
                                        ? 'Light'
                                        : 'System'),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: AppTheme.textSub(context),
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
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border(context)),
        borderRadius: BorderRadius.circular(15),
        color: AppTheme.bg(context),
      ),
      child: Center(child: Text(data, style: AppTheme.tsBodyAdaptive(context))),
    );
  }
}
