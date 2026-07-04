// screens/settings/settings_screen.dart - WITH AVATAR UPDATE FUNCTIONALITY
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
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
import 'package:sportbook/screens/settings/features/favorite_club.dart';
import 'package:sportbook/screens/settings/features/history_booking.dart';
import 'package:sportbook/screens/settings/features/language_selection.dart';
import 'package:sportbook/screens/settings/features/profile_screen.dart';
import 'package:sportbook/translations/app_translations.dart';
import '../../providers/theme_provider.dart';
import '../../providers/language_provider.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationsEnabled = true;
  bool _isLoading = true;
  bool _isSkeletonLoading = true;
  bool _isDisposed = false;
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;
  bool _isFirstLoad = true;

  // User profile data
  UserModel? _user;

  // Booking data
  GetAllBookingDto? _bookingsData;
  bool _isBookingsLoading = true;

  // Favorite clubs
  int _favoriteCount = 0;

  // Avatar state
  File? _selectedAvatarImage;
  bool _isAvatarLoading = false;

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
    if (_isDisposed || !mounted) return;

    setState(() {
      _isCheckingAuth = true;
      _isSkeletonLoading = true;
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
                _isSkeletonLoading = false;
              });
            }
            return;
          }
        } else {
          _isAuthenticated = false;
          if (mounted && !_isDisposed) {
            setState(() {
              _isCheckingAuth = false;
              _isSkeletonLoading = false;
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
          _isSkeletonLoading = false;
        });
      }
    }
  }

  // ============================================================
  // REFRESH METHODS
  // ============================================================

  Future<void> _loadAllData() async {
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    try {
      await Future.wait([
        _loadUserProfile(),
        _loadBookings(),
        _loadFavorites(),
      ]);
    } catch (e) {
      // Handle errors
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isSkeletonLoading = false;
          _isFirstLoad = false;
        });
      }
    }
  }

  Future<void> _refreshAllData() async {
    if (!_isAuthenticated || _isDisposed || !mounted) return;

    setState(() {
      _isLoading = true;
      _isBookingsLoading = true;
      _isSkeletonLoading = true;
    });

    await _loadAllData();

    if (mounted && !_isDisposed) {
      setState(() {
        _isLoading = false;
        _isBookingsLoading = false;
        _isSkeletonLoading = false;
      });
    }
  }

  Future<void> _refreshBookings() async {
    if (!_isAuthenticated || _isDisposed || !mounted) return;
    await _loadBookings();
  }

  Future<void> _refreshFavorites() async {
    if (!_isAuthenticated || _isDisposed || !mounted) return;
    await _loadFavorites();
  }

  // ============================================================
  // LOAD METHODS
  // ============================================================

  Future<void> _loadNotificationSettings() async {
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
    if (_isDisposed || !mounted) return;

    setState(() {
      _isNotificationsEnabled = value;
    });

    await _saveNotificationSettings(value);
  }

  Future<void> _loadUserProfile() async {
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
  // AVATAR METHODS - NEW ADDED FUNCTIONALITY
  // ============================================================

  Future<void> _showAvatarPickerDialog() async {
    if (_isAvatarLoading) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: (isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub)
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'choose_photo'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),
              _buildPickerOption(
                icon: Icons.photo_library_rounded,
                label: 'choose_from_library'.tr(context),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
                isDark: isDark,
              ),
              _buildPickerOption(
                icon: Icons.camera_alt_rounded,
                label: 'take_a_photo'.tr(context),
                onTap: () {
                  Navigator.pop(context);
                  _takePhotoWithCamera();
                },
                isDark: isDark,
              ),
              if (_user?.avatarUrl != null || _selectedAvatarImage != null)
                _buildPickerOption(
                  icon: Icons.delete_rounded,
                  label: 'remove_photo'.tr(context),
                  onTap: () {
                    Navigator.pop(context);
                    _removeAvatar();
                  },
                  isDark: isDark,
                  isDestructive: true,
                ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPickerOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.red : AppTheme.kAccent;
    final textColor = isDestructive ? Colors.red : null;

    return ListTile(
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          color: textColor ?? (isDark ? Colors.white : AppTheme.kLightText),
        ),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickImageFromGallery() async {
    if (_isAvatarLoading) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null && mounted && !_isDisposed) {
        final file = File(image.path);
        await _uploadAvatar(file);
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: $e',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _takePhotoWithCamera() async {
    if (_isAvatarLoading) return;

    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null && mounted && !_isDisposed) {
        final file = File(image.path);
        await _uploadAvatar(file);
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to take photo: $e',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _uploadAvatar(File imageFile) async {
    if (_isAvatarLoading) return;

    setState(() {
      _isAvatarLoading = true;
      _selectedAvatarImage = imageFile;
    });

    try {
      final updatedUser = await _userService.updateAvatar(imageFile);

      if (!_isDisposed && mounted) {
        setState(() {
          _user = updatedUser;
          _selectedAvatarImage = null;
          _isAvatarLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'avatar_updated'.tr(context),
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _selectedAvatarImage = null;
          _isAvatarLoading = false;
        });

        String errorMessage = e.toString();
        if (errorMessage.contains('Exception:')) {
          errorMessage = errorMessage.replaceAll('Exception: ', '');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${'avatar_update_failed'.tr(context)}: $errorMessage',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _removeAvatar() async {
    if (_isAvatarLoading) return;

    setState(() {
      _isAvatarLoading = true;
    });

    try {
      // If your API has a remove avatar endpoint, call it here
      // For now, we'll just show a message

      if (!_isDisposed && mounted) {
        setState(() {
          _selectedAvatarImage = null;
          _isAvatarLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Remove avatar feature coming soon',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.grey,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isAvatarLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to remove avatar: $e',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ============================================================
  // NAVIGATION METHODS
  // ============================================================

  void _navigateToHistory() {
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

  void _showLanguageSelector() async {
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

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _signOut() async {
    if (_isDisposed || !mounted) return;

    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.card(context),
        title: Text(
          'sign_out'.tr(context),
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: const TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: AppTheme.kTextSub,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'cancel'.tr(context),
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: AppTheme.kTextSub,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: AppTheme.elevatedButtonStyle(backgroundColor: Colors.red),
            child: Text(
              'sign_out'.tr(context),
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
          ),
        ],
      ),
    );

    if (shouldSignOut != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _tokenService.clearToken();
      _userService.clearUser();

      setState(() {
        _bookingsData = null;
        _isAuthenticated = false;
        _user = null;
        _favoriteCount = 0;
      });

      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
        // ignore: empty_catches
      } catch (e) {}

      if (mounted && !_isDisposed) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted && !_isDisposed) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      }
    } finally {
      if (mounted && !_isDisposed) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    if (_isDisposed || !mounted) return;
    Navigator.pushNamed(context, AppRoutes.login);
  }

  void _navigateToSignUp() {
    if (_isDisposed || !mounted) return;
    Navigator.pushNamed(context, AppRoutes.signup);
  }

  // ============================================================
  // BUILD METHOD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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
                        SliverToBoxAdapter(
                          child: _isSkeletonLoading
                              ? _buildSkeletonProfile(isDark)
                              : _profileInfo(isDark),
                        ),
                        SliverToBoxAdapter(
                          child: _isSkeletonLoading
                              ? _buildSkeletonButton(isDark)
                              : _singleButton(
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
                          child: _isSkeletonLoading
                              ? _buildSkeletonButton(isDark)
                              : _singleButton(
                                  'favorites'.tr(context).toUpperCase(),
                                  Icons.favorite_rounded,
                                  'favorites'.tr(context),
                                  '$_favoriteCount ${'favorite_clubs'.tr(context)}',
                                  onTap: _navigateToFavorites,
                                ),
                        ),
                        SliverToBoxAdapter(
                          child: _isSkeletonLoading
                              ? _buildSkeletonMultipleButton(isDark)
                              : _multipleButton(themeProvider),
                        ),
                        SliverToBoxAdapter(
                          child: _isSkeletonLoading
                              ? _buildSkeletonSignOutButton(isDark)
                              : _signOutButton(),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SKELETON WIDGETS
  // ============================================================

  Widget _buildSkeletonProfile(bool isDark) {
    final skeletonBaseColor = isDark
        ? const Color(0xFF1E3A5F)
        : const Color(0xFFE0E0E0);
    final skeletonHighlightColor = isDark
        ? const Color(0xFF2A4A6F)
        : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 5, 10, 0),
      child: Container(
        width: double.infinity,
        height: 230,
        decoration: AppTheme.cardDecorationAdaptive(context),
        child: Skeletonizer(
          enabled: true,
          effect: ShimmerEffect(
            baseColor: skeletonBaseColor,
            highlightColor: skeletonHighlightColor,
          ),
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
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 16,
                            width: 120,
                            color: isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 12,
                            width: 80,
                            color: isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 12,
                            width: 100,
                            color: isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: List.generate(
                    3,
                    (index) => Expanded(
                      child: Container(
                        height: 60,
                        margin: EdgeInsets.only(right: index < 2 ? 2 : 0),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.kCardAlt
                              : AppTheme.kLightCardAlt,
                          borderRadius: BorderRadius.circular(
                            index == 0 ? 20 : (index == 2 ? 20 : 0),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 14,
                              width: 30,
                              color: isDark
                                  ? AppTheme.kCard
                                  : AppTheme.kLightCard,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 10,
                              width: 40,
                              color: isDark
                                  ? AppTheme.kCard
                                  : AppTheme.kLightCard,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 45,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: AppTheme.kAccent.withValues(alpha: 0.3),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonButton(bool isDark) {
    final skeletonBaseColor = isDark
        ? const Color(0xFF1E3A5F)
        : const Color(0xFFE0E0E0);
    final skeletonHighlightColor = isDark
        ? const Color(0xFF2A4A6F)
        : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: skeletonBaseColor,
          highlightColor: skeletonHighlightColor,
        ),
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
                    color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 14,
                        width: 100,
                        color: isDark
                            ? AppTheme.kCardAlt
                            : AppTheme.kLightCardAlt,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 10,
                        width: 150,
                        color: isDark
                            ? AppTheme.kCardAlt
                            : AppTheme.kLightCardAlt,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeletonMultipleButton(bool isDark) {
    final skeletonBaseColor = isDark
        ? const Color(0xFF1E3A5F)
        : const Color(0xFFE0E0E0);
    final skeletonHighlightColor = isDark
        ? const Color(0xFF2A4A6F)
        : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 14,
            width: 100,
            color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
          ),
          const SizedBox(height: 8),
          Skeletonizer(
            enabled: true,
            effect: ShimmerEffect(
              baseColor: skeletonBaseColor,
              highlightColor: skeletonHighlightColor,
            ),
            child: Column(
              children: List.generate(
                3,
                (index) => Container(
                  width: double.infinity,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
                    borderRadius: BorderRadius.only(
                      topLeft: index == 0 ? Radius.circular(12) : Radius.zero,
                      topRight: index == 0 ? Radius.circular(12) : Radius.zero,
                      bottomLeft: index == 2
                          ? Radius.circular(12)
                          : Radius.zero,
                      bottomRight: index == 2
                          ? Radius.circular(12)
                          : Radius.zero,
                    ),
                    border: Border(
                      bottom: index < 2
                          ? BorderSide(
                              color: isDark
                                  ? AppTheme.kBorder
                                  : AppTheme.kLightBorder,
                            )
                          : BorderSide.none,
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
                            color: isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 14,
                                width: 100,
                                color: isDark
                                    ? AppTheme.kCardAlt
                                    : AppTheme.kLightCardAlt,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                height: 10,
                                width: 120,
                                color: isDark
                                    ? AppTheme.kCardAlt
                                    : AppTheme.kLightCardAlt,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 20,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 16,
                          height: 16,
                          color: isDark
                              ? AppTheme.kCardAlt
                              : AppTheme.kLightCardAlt,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonSignOutButton(bool isDark) {
    final skeletonBaseColor = isDark
        ? const Color(0xFF1E3A5F)
        : const Color(0xFFE0E0E0);
    final skeletonHighlightColor = isDark
        ? const Color(0xFF2A4A6F)
        : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: skeletonBaseColor,
          highlightColor: skeletonHighlightColor,
        ),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: Colors.red.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGIN REQUIRED STATE
  // ============================================================

  Widget _buildLoginRequiredState(bool isDark) {
    if (_isDisposed) return const SizedBox.shrink();

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                border: Border.all(
                  color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 40,
                color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'you_are_not_signed_in'.tr(context),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'sign_in_to_access_settings'.tr(context),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _navigateToLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kAccent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(
                  'sign_in'.tr(context),
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: _navigateToSignUp,
                style: OutlinedButton.styleFrom(
                  foregroundColor: isDark ? Colors.white : AppTheme.kLightText,
                  side: BorderSide(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(
                  'create_account'.tr(context),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppTheme.kLightText,
                  ),
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
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              ),
              icon: Icon(Icons.settings, color: AppTheme.textPrimary(context)),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // UPDATED PROFILE INFO WITH AVATAR PICKER
  // ============================================================

  Widget _profileInfo(bool isDark) {
    if (_isDisposed) return const SizedBox.shrink();
    if (!_isAuthenticated) return const SizedBox.shrink();

    if (_isLoading && _isFirstLoad) {
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
            Text(
              'Failed to load profile',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadUserProfile,
              child: Text(
                'Retry',
                style: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ============================================================
            // AVATAR WITH PICKER - UPDATED WITH NEW FUNCTIONALITY
            // ============================================================
            GestureDetector(
              onTap: _isAvatarLoading ? null : _showAvatarPickerDialog,
              child: Stack(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.kAccent, width: 1.8),
                    ),
                    alignment: Alignment.center,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: _buildAvatarContent(isDark),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.kAccent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppTheme.kBg : AppTheme.kLightBg,
                          width: 2,
                        ),
                      ),
                      child: _isAvatarLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt,
                              size: 16,
                              color: Colors.black,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // User name
            Text(_user!.fullName, style: AppTheme.tsTitleAdaptive(context)),
            const SizedBox(height: 8),
            // Stats row
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
          ],
        ),
      ),
    );
  }

  // Helper method to build avatar content
  Widget _buildAvatarContent(bool isDark) {
    if (_isAvatarLoading) {
      return Container(
        color: AppTheme.cardAlt(context),
        child: const Center(
          child: CircularProgressIndicator(
            color: AppTheme.kAccent,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_selectedAvatarImage != null) {
      return Image.file(_selectedAvatarImage!, fit: BoxFit.cover);
    }

    final avatarUrl = _user?.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildAvatarPlaceholder(isDark),
        loadingBuilder: (_, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: AppTheme.cardAlt(context),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.kAccent,
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }

    return _buildAvatarPlaceholder(isDark);
  }

  Widget _buildAvatarPlaceholder(bool isDark) {
    return Container(
      color: AppTheme.cardAlt(context),
      child: Icon(
        Icons.person,
        size: 36,
        color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
      ),
    );
  }

  // ============================================================
  // REST OF THE WIDGETS (unchanged)
  // ============================================================

  Widget _singleButton(
    String label,
    IconData icon,
    String title,
    String subTitle, {
    required VoidCallback onTap,
  }) {
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
                              fontFamily: AppTheme.fontFamily,
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
                              fontFamily: AppTheme.fontFamily,
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
                              style: AppTheme.tsLabelAdaptive(context).copyWith(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 14.5,
                              ),
                            ),
                            Text(
                              'booking_reminders'.tr(context),
                              style: AppTheme.tsSubAdaptive(context).copyWith(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isNotificationsEnabled,
                        onChanged: _isAuthenticated
                            ? (value) {
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
                                  fontFamily: AppTheme.fontFamily,
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
                                  fontFamily: AppTheme.fontFamily,
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
                                  fontFamily: AppTheme.fontFamily,
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
                                  fontFamily: AppTheme.fontFamily,
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
