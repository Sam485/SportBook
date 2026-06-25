// screens/settings/settings_screen.dart - FULLY FIXED VERSION
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Booking/model/get_all_booking_dto.dart';
import 'package:sportbook/feature/Booking/service/booking_service.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/feature/User/model/user_model.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/screens/settings/features/appearance_selection.dart';
import 'package:sportbook/screens/settings/features/editing_profile.dart';
import 'package:sportbook/screens/settings/features/favorite_club.dart';
import 'package:sportbook/screens/settings/features/history_booking.dart';
import 'package:sportbook/screens/settings/features/language_selection.dart';
import 'package:sportbook/screens/settings/features/password_security.dart';
import 'package:sportbook/translations/app_translations.dart';
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
  bool _isDisposed = false;
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  // User profile data
  UserModel? _user;

  // Booking data
  GetAllBookingDto? _bookingsData;
  bool _isBookingsLoading = true;

  // Favorite clubs
  int _favoriteCount = 0;

  // Static avatar URL for now
  final String _staticAvatarUrl =
      'https://imgs.search.brave.com/EipFQVm-X300u0qBZX5vva8FbVwDEBUGookALc-rjNM/rs:fit:500:0:1:0/g:ce/aHR0cHM6Ly9pbWFn/ZXMucGV4ZWxzLmNv/bS9waG90b3MvMTUz/OTM1OTAvcGV4ZWxz/LXBob3RvLTE1Mzkz/NTkwL2ZyZWUtcGhv/dG8tb2YtcGhvdG8t/b2YtYS1zaGlydGxl/c3MtaGFuZHNvbWUt/bWFuLWFnYWluc3Qt/dGhlLXNreS5qcGVn/P2F1dG89Y29tcHJl/c3MmY3M9dGlueXNy/Z2ImZHByPTEmdz01/MDA';

  // Services
  final _userService = getIt<UserService>();
  final _tokenService = getIt<TokenService>();
  final _bookingService = getIt<BookingService>();
  final _clubService = getIt<SportClubService>();

  // Language state
  late String _currentLanguage;

  // Notification settings key
  static const String _notificationsKey = 'notifications_enabled';

  @override
  void initState() {
    super.initState();
    _userService.addListener(_onUserServiceChanged);
    _clubService.addListener(_onClubServiceChanged);
    _checkAuthentication();
    _loadCurrentLanguage();
    _loadNotificationSettings();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _userService.removeListener(_onUserServiceChanged);
    _clubService.removeListener(_onClubServiceChanged);
    super.dispose();
  }

  void _onUserServiceChanged() {
    // ✅ Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        setState(() {
          _user = _userService.currentUser;
        });
      }
    });
  }

  void _onClubServiceChanged() {
    // ✅ Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        setState(() {
          _favoriteCount = _clubService.favoriteCount;
        });
      }
    });
  }

  // ============================================================
  // AUTHENTICATION CHECK
  // ============================================================

  Future<void> _checkAuthentication() async {
    // ✅ Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;

    setState(() {
      _isCheckingAuth = true;
    });

    try {
      final hasValidToken = await _tokenService.hasValidTokenAsync();

      if (!hasValidToken) {
        final refreshToken = await _tokenService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshed = await _tokenService.refreshAccessToken();
          if (!refreshed) {
            _isAuthenticated = false;
            if (mounted && !_isDisposed) {
              setState(() {
                _isCheckingAuth = false;
              });
            }
            return;
          }
        } else {
          _isAuthenticated = false;
          if (mounted && !_isDisposed) {
            setState(() {
              _isCheckingAuth = false;
            });
          }
          return;
        }
      }

      _isAuthenticated = true;
      if (mounted && !_isDisposed) {
        setState(() {
          _isCheckingAuth = false;
        });
      }

      // Load all data if authenticated
      await _loadAllData();
    } catch (e) {
      _isAuthenticated = false;
      if (mounted && !_isDisposed) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    }
  }

  // ============================================================
  // REFRESH METHODS
  // ============================================================

  Future<void> _loadAllData() async {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    await Future.wait([_loadUserProfile(), _loadBookings(), _loadFavorites()]);
  }

  Future<void> _refreshAllData() async {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    setState(() {
      _isLoading = true;
      _isBookingsLoading = true;
    });

    await _loadAllData();

    if (mounted && !_isDisposed) {
      setState(() {
        _isLoading = false;
        _isBookingsLoading = false;
      });
    }
  }

  Future<void> _refreshBookings() async {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;
    await _loadBookings();
  }

  Future<void> _refreshFavorites() async {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;
    await _loadFavorites();
  }

  // ============================================================
  // LOAD METHODS
  // ============================================================

  Future<void> _loadNotificationSettings() async {
    // ✅ Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_notificationsKey) ?? true;
      if (mounted && !_isDisposed) {
        setState(() {
          _isNotificationsEnabled = enabled;
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _saveNotificationSettings(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsKey, enabled);
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<void> _toggleNotifications(bool value) async {
    // ✅ Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;

    setState(() {
      _isNotificationsEnabled = value;
    });

    await _saveNotificationSettings(value);
  }

  Future<void> _loadUserProfile() async {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    try {
      if (mounted && !_isDisposed) {
        setState(() => _isLoading = true);
      }

      await _userService.getProfile();

      if (mounted && !_isDisposed) {
        setState(() {
          _user = _userService.currentUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadBookings() async {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    if (mounted && !_isDisposed) {
      setState(() {
        _isBookingsLoading = true;
      });
    }

    try {
      final data = await _bookingService.getAllBookings(page: 1, limit: 100);

      if (mounted && !_isDisposed) {
        setState(() {
          _bookingsData = data;
          _isBookingsLoading = false;
        });
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        setState(() {
          _isBookingsLoading = false;
        });
      }
    }
  }

  Future<void> _loadFavorites() async {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    try {
      await _clubService.fetchFavorite();

      if (mounted && !_isDisposed) {
        setState(() {
          _favoriteCount = _clubService.favoriteCount;
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  void _loadCurrentLanguage() {
    // ✅ Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;

    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );
    if (mounted && !_isDisposed) {
      setState(() {
        _currentLanguage = languageProvider.currentLanguage.toUpperCase();
      });
    }
  }

  // ============================================================
  // COMPUTED PROPERTIES
  // ============================================================

  int get _totalBookings => _bookingsData?.data.length ?? 0;

  int get _upcomingBookingsCount {
    if (_bookingsData == null) return 0;
    return _bookingsData!.data.where((booking) {
      final status = booking.status.toLowerCase();
      return status == 'pending' || status == 'confirmed';
    }).length;
  }

  int get _completedBookingsCount {
    if (_bookingsData == null) return 0;
    return _bookingsData!.data.where((booking) {
      return booking.status.toLowerCase() == 'completed';
    }).length;
  }

  // ============================================================
  // NAVIGATION METHODS
  // ============================================================

  void _navigateToHistory() {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            HistoryBookingsScreen(bookings: _bookingsData?.data ?? []),
      ),
    ).then((_) {
      if (mounted && !_isDisposed) {
        _refreshBookings();
      }
    });
  }

  void _navigateToFavorites() {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FavoriteClub()),
    ).then((_) {
      if (mounted && !_isDisposed) {
        _refreshFavorites();
      }
    });
  }

  void _navigateToEditProfile() async {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
    );

    if (result != null && mounted && !_isDisposed) {
      await _loadUserProfile();
      if (mounted && !_isDisposed) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('profile_updated'.tr(context))));
      }
    }
  }

  void _navigateToPasswordSecurity() {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PasswordSecurityScreen()),
    );
  }

  void _showLanguageSelector() async {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    final selectedLanguage = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LanguageSelector(currentLanguage: _currentLanguage),
    );

    if (selectedLanguage != null && mounted && !_isDisposed) {
      setState(() {
        _currentLanguage = selectedLanguage.toUpperCase();
      });
    }
  }

  void _showAppearanceSelector() async {
    // ✅ Check if widget is still mounted and not disposed
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    final selectedTheme = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AppearanceSelector(currentTheme: themeProvider.currentTheme),
    );

    if (selectedTheme != null && mounted && !_isDisposed) {
      setState(() {});
    }
  }

  void _signOut() async {
    // ✅ Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;

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

              await _tokenService.clearToken();
              _userService.clearUser();

              if (mounted && !_isDisposed) {
                // ignore: use_build_context_synchronously
                Navigator.pushNamed(context, AppRoutes.landing);
              }
            },
            style: AppTheme.elevatedButtonStyle(backgroundColor: Colors.red),
            child: Text('sign_out'.tr(context)),
          ),
        ],
      ),
    );
  }

  // ✅ Navigate to login
  void _navigateToLogin() {
    // ✅ Check if widget is still mounted and not disposed
    if (_isDisposed || !mounted) return;
    Navigator.pushNamed(context, AppRoutes.landing);
  }

  // ============================================================
  // BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    // ✅ Return empty widget if disposed
    if (_isDisposed) return const SizedBox.shrink();

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
          body: SafeArea(
            child: _isCheckingAuth
                ? const Center(child: CircularProgressIndicator())
                : !_isAuthenticated
                ? _buildLoginRequiredState(isDark)
                : RefreshIndicator(
                    onRefresh: _refreshAllData,
                    color: AppTheme.kAccent,
                    backgroundColor: isDark
                        ? AppTheme.kCard
                        : AppTheme.kLightCard,
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
                            _isBookingsLoading
                                ? 'loading'.tr(context)
                                : '$_totalBookings ${'total_bookings'.tr(context)}',
                            onTap: _navigateToHistory,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _singleButton(
                            'favorites'.tr(context).toUpperCase(),
                            Icons.favorite_rounded,
                            'favorites'.tr(context),
                            '$_favoriteCount ${'favorite_clubs'.tr(context)}',
                            onTap: _navigateToFavorites,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: _multipleButton(themeProvider),
                        ),
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
          ),
        );
      },
    );
  }

  // ✅ Login required state
  Widget _buildLoginRequiredState(bool isDark) {
    // ✅ Check if widget is disposed
    if (_isDisposed) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 80,
              color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
            ),
            const SizedBox(height: 24),
            Text(
              'login_required'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'login_to_view_settings'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'login'.tr(context),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WIDGET BUILDERS
  // ============================================================

  Widget _header() {
    // ✅ Check if widget is disposed
    if (_isDisposed) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Text(
            'settings_title'.tr(context),
            style: AppTheme.tsTitleAdaptive(context),
          ),
          const Spacer(),
          if (_isAuthenticated)
            IconButton(
              onPressed: _refreshAllData,
              icon: Icon(
                Icons.refresh_rounded,
                color: AppTheme.textPrimary(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _profileInfo(bool isDark) {
    // ✅ Check if widget is disposed
    if (_isDisposed) return const SizedBox.shrink();
    if (!_isAuthenticated) return const SizedBox.shrink();

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
                        child:
                            _user!.avatarUrl != null &&
                                _user!.avatarUrl!.isNotEmpty
                            ? Image.network(
                                _user!.avatarUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
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
                            : Image.network(
                                _staticAvatarUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Container(
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
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            children: [
                              Text(
                                _isBookingsLoading ? '...' : '$_totalBookings',
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
                              borderRadius: BorderRadius.zero,
                              color: AppTheme.cardAlt(context),
                            ),
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            children: [
                              Text(
                                _isBookingsLoading
                                    ? '...'
                                    : '$_upcomingBookingsCount',
                                style: AppTheme.tsTitleAdaptive(context),
                              ),
                              Text(
                                'upcoming'.tr(context),
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
                          padding: const EdgeInsets.all(6.0),
                          child: Column(
                            children: [
                              Text(
                                _isBookingsLoading
                                    ? '...'
                                    : '$_completedBookingsCount',
                                style: AppTheme.tsTitleAdaptive(context),
                              ),
                              Text(
                                'completed'.tr(context),
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
                      backgroundColor: AppTheme.kAccent.withValues(alpha: 0.5),
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
    // ✅ Check if widget is disposed
    if (_isDisposed) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.tsBodyAdaptive(context)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _isAuthenticated ? onTap : null,
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
                      child: Icon(
                        icon,
                        color: isDark ? AppTheme.kBg : AppTheme.kLightBg,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white
                                  : AppTheme.kLightText,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            subTitle,
                            style: TextStyle(
                              color: isDark
                                  ? AppTheme.kTextSub
                                  : AppTheme.kLightTextSub,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: _isAuthenticated
                          ? AppTheme.textSub(context)
                          : AppTheme.textSub(context).withValues(alpha: 0.3),
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
    // ✅ Check if widget is disposed
    if (_isDisposed) return const SizedBox.shrink();

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
              // Notification - With real toggle functionality
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
                              style: AppTheme.tsSubAdaptive(
                                context,
                              ).copyWith(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isNotificationsEnabled,
                        onChanged: _isAuthenticated
                            ? (value) {
                                // ✅ Check if widget is still mounted
                                if (mounted && !_isDisposed) {
                                  _toggleNotifications(value);
                                }
                              }
                            : null,
                        activeThumbColor: AppTheme.kAccent,
                      ),
                    ],
                  ),
                ),
              ),
              // Language
              GestureDetector(
                onTap: _isAuthenticated ? _showLanguageSelector : null,
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
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.kLightText,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                _currentLanguage == 'EN'
                                    ? 'english'.tr(context)
                                    : 'khmer'.tr(context),
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.kTextSub
                                      : AppTheme.kLightTextSub,
                                  fontSize: 12,
                                ),
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
                              color: _isAuthenticated
                                  ? AppTheme.textSub(context)
                                  : AppTheme.textSub(
                                      context,
                                    ).withValues(alpha: 0.3),
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
                onTap: _isAuthenticated ? _showAppearanceSelector : null,
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
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.kLightText,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                themeProvider.currentTheme == 'dark'
                                    ? 'dark_mode'.tr(context)
                                    : (themeProvider.currentTheme == 'light'
                                          ? 'light_mode'.tr(context)
                                          : 'system_default'.tr(context)),
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.kTextSub
                                      : AppTheme.kLightTextSub,
                                  fontSize: 12,
                                ),
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
                              color: _isAuthenticated
                                  ? AppTheme.textSub(context)
                                  : AppTheme.textSub(
                                      context,
                                    ).withValues(alpha: 0.3),
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
    // ✅ Check if widget is disposed
    if (_isDisposed) return const SizedBox.shrink();
    if (!_isAuthenticated) return const SizedBox.shrink();

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
    // ✅ Check if widget is disposed
    if (_isDisposed) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
        ),
        borderRadius: BorderRadius.circular(15),
        color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
      ),
      child: Center(child: Text(data, style: AppTheme.tsBodyAdaptive(context))),
    );
  }
}
