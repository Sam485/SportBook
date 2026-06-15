import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/feature/User/model/user_model.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/screens/settings/features/appearance_selection.dart';
import 'package:sportbook/screens/settings/features/editing_profile.dart';
import 'package:sportbook/screens/settings/features/history_booking.dart';
import 'package:sportbook/screens/settings/features/language_selection.dart';
import 'package:sportbook/screens/settings/features/password_security.dart';
import 'package:sportbook/translations/app_translations.dart';
import '../../core/theme.dart';
import '../../feature/static/models/models.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationsEnabled = true;
  bool _isLoading = true;

  // User profile data - will be loaded from API
  UserModel? _user;

  // Static avatar URL for now
  final String _staticAvatarUrl =
      'https://imgs.search.brave.com/EipFQVm-X300u0qBZX5vva8FbVwDEBUGookALc-rjNM/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMucGV4ZWxzLmNv/bS9waG90b3MvMTUz/OTM1OTAvcGV4ZWxz/LXBob3RvLTE1Mzkz/NTkwL2ZyZWUtcGhv/dG8tb2YtcGhvdG8t/b2YtYS1zaGlydGxl/c3MtaGFuZHNvbWUt/bWFuLWFnYWluc3Qt/dGhlLXNreS5qcGVn/P2F1dG89Y29tcHJl/c3MmY3M9dGlueXNy/Z2ImZHByPTEmdz01/MDA';

  // Sample history bookings
  final List<SportBooking> _historyBookings = [];

  // Repositories and services
  final _userService = getIt<UserService>();
  final _tokenService = getIt<TokenService>();

  // Language state
  late String _currentLanguage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadSampleHistoryBookings();
    _loadCurrentLanguage();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);

      // Check if user has valid token
      final hasValidToken = await _tokenService.hasValidTokenAsync();

      if (hasValidToken) {
        // Fetch user profile from API
        final user = await _userService.getProfile();
        setState(() {
          _user = user;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        // Optionally redirect to login
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _loadSampleHistoryBookings() {
    // Add sample history bookings - replace with your actual data
    // You can also fetch from API here
  }

  void _loadCurrentLanguage() {
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    setState(() {
      _currentLanguage = languageProvider.currentLanguage.toUpperCase();
    });
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
    if (_user == null) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfileScreen(
          user: _user!,
          userService: _userService, // Use static URL
        ),
      ),
    );

    if (result != null && mounted) {
      // Refresh user profile after edit
      await _loadUserProfile();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('profile_updated'.tr(context))));
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
        _currentLanguage = selectedLanguage.toUpperCase();
      });
      // Rebuild the UI to update all translations
      setState(() {});
    }
  }

  void _showAppearanceSelector() async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final selectedTheme = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AppearanceSelector(currentTheme: themeProvider.currentTheme),
    );

    if (selectedTheme != null && mounted) {
      setState(() {});
    }
  }

  void _signOut() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text(
          'sign_out'.tr(context),
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: const TextStyle(color: AppTheme.kTextSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(context),
              style: const TextStyle(color: AppTheme.kTextSub),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Clear tokens
              await _tokenService.clearToken();

              // Navigate to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            style: AppTheme.elevatedButtonStyle(backgroundColor: Colors.red),
            child: Text('sign_out'.tr(context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              scrollBehavior: const ScrollBehavior().copyWith(
                overscroll: false,
              ),
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: _profileInfo(isDark)),
                SliverToBoxAdapter(
                  child: _singleButton(
                    'account'.tr(context).toUpperCase(),
                    Icons.history,
                    'history_bookings'.tr(context),
                    'view_past_sessions'.tr(context),
                    onTap: _navigateToHistory,
                  ),
                ),
                SliverToBoxAdapter(child: _multipleButton(themeProvider)),
                SliverToBoxAdapter(
                  child: _singleButton(
                    'security'.tr(context).toUpperCase(),
                    Icons.lock_outline,
                    'password_security'.tr(context),
                    'last_changed'.tr(context),
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
          Text(
            'settings_title'.tr(context),
            style: AppTheme.tsTitleAdaptive(context),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings, color: AppTheme.textPrimary(context)),
          ),
        ],
      ),
    );
  }

  Widget _profileInfo(bool isDark) {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: CircularProgressIndicator(color: AppTheme.kAccent),
        ),
      );
    }

    if (_user == null) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Failed to load profile', style: TextStyle(color: Colors.red)),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _loadUserProfile, child: Text('Retry')),
          ],
        ),
      );
    }

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
                        child: Image.network(
                          _user!.avatarUrl ??
                              _staticAvatarUrl, // Use static URL
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
                            _user!.fullName,
                            style: AppTheme.tsTitleAdaptive(context),
                          ),
                          Text(
                            _user!.email,
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
                                  _user!.location ?? '',
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
                                'total_bookings'.tr(context),
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
                                _user!.isVerified ? '3' : '0',
                                style: AppTheme.tsTitleAdaptive(context),
                              ),
                              Text(
                                _user!.isVerified
                                    ? 'upcoming'.tr(context)
                                    : 'unverified'.tr(context),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.edit, size: 18),
                        const SizedBox(width: 5),
                        Text('edit_profile'.tr(context)),
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
          Text(label, style: AppTheme.tsBodyAdaptive(context)),
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
          Text(
            'preferences'.tr(context).toUpperCase(),
            style: AppTheme.tsBodyAdaptive(context),
          ),
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
                              'notifications'.tr(context),
                              style: AppTheme.tsLabelAdaptive(
                                context,
                              ).copyWith(fontSize: 14.5),
                            ),
                            Text(
                              'booking_reminders'.tr(context),
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
                                'language'.tr(context),
                                style: AppTheme.tsLabelAdaptive(
                                  context,
                                ).copyWith(fontSize: 14.5),
                              ),
                              Text(
                                _currentLanguage == 'EN'
                                    ? 'english'.tr(context)
                                    : 'khmer'.tr(context),
                                style: AppTheme.tsSubAdaptive(context),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _badge(_currentLanguage == 'EN' ? 'EN' : 'KM'),
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
                                'appearance'.tr(context),
                                style: AppTheme.tsLabelAdaptive(
                                  context,
                                ).copyWith(fontSize: 14.5),
                              ),
                              Text(
                                themeProvider.currentTheme == 'dark'
                                    ? 'dark_mode'.tr(context)
                                    : (themeProvider.currentTheme == 'light'
                                          ? 'light_mode'.tr(context)
                                          : 'system_default'.tr(context)),
                                style: AppTheme.tsSubAdaptive(context),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            _badge(
                              themeProvider.currentTheme == 'dark'
                                  ? 'dark'.tr(context)
                                  : (themeProvider.currentTheme == 'light'
                                        ? 'light'.tr(context)
                                        : 'system'.tr(context)),
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
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _signOut,
          style: AppTheme.elevatedButtonStyle(backgroundColor: Colors.red),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.logout),
              const SizedBox(width: 8),
              Text('sign_out'.tr(context)),
            ],
          ),
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
