// home_screen.dart - WITH AVATAR UPDATE FIX
import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Banner/model/banner_model.dart';
import 'package:sportbook/feature/Banner/service/banner_service.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/model/get_all_booking_dto.dart';
import 'package:sportbook/feature/Booking/service/booking_service.dart';
import 'package:sportbook/feature/Category/model/category_model.dart';
import 'package:sportbook/feature/Category/service/category_service.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/feature/User/model/update_dto.dart';
import 'package:sportbook/feature/User/model/user_model.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/screens/home/ViewAll/upcoming_booking_viewall.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/cards/booking_card.dart';
import 'package:sportbook/widgets/common/banner_carousel.dart';
import 'package:sportbook/widgets/common/map_picker_screen.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/cards/club_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInitialized = false;
  bool _isSkeletonLoading = true;
  bool _shouldRefreshOnReturn = true;

  String _selectedCat = 'all';
  String _locationLabel = 'Phnom Penh';
  bool _isDisposed = false;
  bool _isLoading = true;
  int _refreshCounter = 0;

  // Default location: Phnom Penh, Cambodia
  static const double _defaultLat = 11.5564;
  static const double _defaultLng = 104.9282;
  static const String _defaultLocationLabel = 'Phnom Penh';

  // Location for nearby search
  double? _currentLat = _defaultLat;
  double? _currentLng = _defaultLng;

  // Fixed distance - 20km
  static const int _radius = 20;

  // SharedPreferences keys
  static const String _prefLat = 'user_lat';
  static const String _prefLng = 'user_lng';
  static const String _prefLocationLabel = 'user_location_label';
  static const String _prefHasLocation = 'has_saved_location';

  // Services
  final _userService = getIt<UserService>();
  final _bannerService = getIt<BannerService>();
  final _categoryService = getIt<CategoryService>();
  late final SportClubService _clubService;
  late final BookingService _bookingService;

  List<BannerModel>? _banners;
  UserModel? _user;
  List<CategoryModel> _categories = [];
  bool _isCategoriesLoading = true;

  // Booking data
  GetAllBookingDto? _bookingsData;
  bool _isBookingsLoading = true;
  bool _hasBookingsError = false;

  // Get clubs from service
  List<SportClubModel> get _clubs => List.from(_clubService.nearbyClubs);

  // Get upcoming bookings (filtered by status)
  List<BookingModel> get _upcomingBookings {
    if (_bookingsData == null || _hasBookingsError) return [];
    return _bookingsData!.data.where((booking) {
      final status = booking.status.toLowerCase();
      return status == 'pending' || status == 'confirmed';
    }).toList();
  }

  // Filter clubs by category ID
  List<SportClubModel> get _filteredClubs {
    if (_selectedCat == 'all') {
      return _clubs;
    }
    return _clubs
        .where(
          (club) => club.categories.any(
            (cat) =>
                cat.id.toString() == _selectedCat || cat.name == _selectedCat,
          ),
        )
        .toList();
  }

  // Check if user is authenticated
  Future<bool> _isAuthenticated() async {
    try {
      final tokenService = getIt<TokenService>();
      return await tokenService.hasValidTokenAsync();
    } catch (e) {
      return false;
    }
  }

  // Show login required dialog
  void _showLoginRequiredDialog(BuildContext context, {String? message}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'login_required'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          message ?? 'login_to_book'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(context),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.login);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kAccent,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            child: Text('login'.tr(context)),
          ),
        ],
      ),
    );
  }

  // Navigate to booking flow with auth check
  Future<void> _navigateToBookingFlow(SportClubModel club) async {
    final isAuth = await _isAuthenticated();

    if (!isAuth) {
      // ignore: use_build_context_synchronously
      _showLoginRequiredDialog(context);
      return;
    }

    _shouldRefreshOnReturn = false;

    final result = await Navigator.pushNamed(
      // ignore: use_build_context_synchronously
      context,
      AppRoutes.bookingFlow,
      arguments: club,
    );

    _shouldRefreshOnReturn = true;

    if (result == true && mounted) {
      await _onRefresh();
    }
  }

  // Navigate to club detailed view
  void _navigateToClubDetailed(SportClubModel club) {
    Navigator.pushNamed(context, AppRoutes.clubDetailed, arguments: club);
  }

  // ============================================================
  // LOCATION PERSISTENCE METHODS
  // ============================================================

  Future<void> _saveLocationToPrefs({
    required double lat,
    required double lng,
    required String label,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_prefLat, lat);
      await prefs.setDouble(_prefLng, lng);
      await prefs.setString(_prefLocationLabel, label);
      await prefs.setBool(_prefHasLocation, true);
      // ignore: empty_catches
    } catch (e) {}
  }

  Future<Map<String, dynamic>?> _loadLocationFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasLocation = prefs.getBool(_prefHasLocation) ?? false;

      if (!hasLocation) {
        return null;
      }

      final lat = prefs.getDouble(_prefLat);
      final lng = prefs.getDouble(_prefLng);
      final label = prefs.getString(_prefLocationLabel) ?? 'Phnom Penh';

      if (lat != null && lng != null) {
        return {'lat': lat, 'lng': lng, 'label': label};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // INITIALIZATION METHODS
  // ============================================================

  Future<void> initialLoad() async {
    setState(() {
      _isSkeletonLoading = true;
    });

    try {
      // Load public data first (banners, categories)
      final publicResults = await Future.wait([
        _bannerService.getAllActiveBanner(),
        _categoryService.fetchCategories(limit: 100),
      ]);

      // Try to load user profile (may fail if not authenticated)
      try {
        await _userService.getProfile();
        _user = _userService.currentUser;

        if (_user != null && _user!.lat != null && _user!.lng != null) {
          _currentLat = _user!.lat;
          _currentLng = _user!.lng;
          _locationLabel = _user!.location ?? 'Phnom Penh';
          await _saveLocationToPrefs(
            lat: _currentLat!,
            lng: _currentLng!,
            label: _locationLabel,
          );
        }
      } catch (e) {
        final savedLocation = await _loadLocationFromPrefs();
        if (savedLocation != null) {
          _currentLat = savedLocation['lat'];
          _currentLng = savedLocation['lng'];
          _locationLabel = savedLocation['label'];
        } else {
          _currentLat = _defaultLat;
          _currentLng = _defaultLng;
          _locationLabel = _defaultLocationLabel;
        }
      }

      // Try to load bookings (may fail if not authenticated)
      try {
        final bookingsData = await _bookingService.getAllBookings(
          page: 1,
          limit: 10,
        );
        _bookingsData = bookingsData;
        _hasBookingsError = false;
      } catch (e) {
        _bookingsData = null;
        _hasBookingsError = true;
      }

      // Load clubs with timeout and fallback
      await _loadClubsWithFallback();

      if (!_isDisposed && mounted) {
        setState(() {
          _banners = publicResults[0] as List<BannerModel>?;
          _categories = publicResults[1] as List<CategoryModel>;
          _isBookingsLoading = false;
          _isCategoriesLoading = false;
          _isLoading = false;
          _isSkeletonLoading = false;
          _refreshCounter++;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _isCategoriesLoading = false;
          _isBookingsLoading = false;
          _hasBookingsError = true;
          _isSkeletonLoading = false;
          _refreshCounter++;
        });
      }
    }
  }

  // Load clubs with timeout and fallback
  Future<void> _loadClubsWithFallback() async {
    try {
      if (_currentLat != null && _currentLng != null) {
        await _clubService
            .fetchNearbyClubs(
              lat: _currentLat!,
              lng: _currentLng!,
              radius: _radius,
            )
            .timeout(
              const Duration(seconds: 15),
              onTimeout: () {
                return Future.value([]);
              },
            );
      } else {
        final allClubsDto = await _clubService.getAllSportClub(
          page: 1,
          limit: 100,
        );
        _clubService.setNearbyClubs(allClubsDto.data);
      }
    } catch (e) {
      try {
        final allClubsDto = await _clubService.getAllSportClub(
          page: 1,
          limit: 100,
        );
        _clubService.setNearbyClubs(allClubsDto.data);
      } catch (fallbackError) {
        _clubService.setNearbyClubs([]);
      }
    }
  }

  // Refresh clubs with UI update
  Future<void> _refreshNearbyClubsWithUIUpdate(double lat, double lng) async {
    try {
      setState(() {
        _isLoading = true;
        _isSkeletonLoading = true;
      });

      await _clubService.fetchNearbyClubs(lat: lat, lng: lng, radius: _radius);

      await _saveLocationToPrefs(lat: lat, lng: lng, label: _locationLabel);

      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _isSkeletonLoading = false;
          _refreshCounter++;
        });
      }
    } catch (e) {
      try {
        final allClubsDto = await _clubService.getAllSportClub(
          page: 1,
          limit: 100,
        );
        _clubService.setNearbyClubs(allClubsDto.data);
        if (!_isDisposed && mounted) {
          setState(() {
            _isLoading = false;
            _isSkeletonLoading = false;
            _refreshCounter++;
          });
        }
      } catch (_) {
        if (!_isDisposed && mounted) {
          setState(() {
            _isLoading = false;
            _isSkeletonLoading = false;
          });
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    if (!_isInitialized) {
      _isInitialized = true;

      _clubService = getIt<SportClubService>();
      _bookingService = getIt<BookingService>();

      _clubService.addListener(_onServiceChanged);

      // ADD LISTENER FOR USER SERVICE CHANGES
      _userService.addListener(_onUserServiceChanged);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        initialLoad();
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clubService.removeListener(_onServiceChanged);
    _userService.removeListener(_onUserServiceChanged);
    super.dispose();
  }

  // USER SERVICE CHANGE LISTENER - Updates avatar automatically
  void _onUserServiceChanged() {
    // Skip if disposed or we don't want to refresh
    if (_isDisposed || !mounted) return;

    // Skip refresh if we're returning from booking flow
    if (!_shouldRefreshOnReturn) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        setState(() {
          _user = _userService.currentUser;
          _refreshCounter++; // Force rebuild of widgets
        });
      }
    });
  }

  // Service change listener for club service
  void _onServiceChanged() {
    if (!_shouldRefreshOnReturn) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        setState(() {
          _refreshCounter++;
        });
      }
    });
  }

  // ============================================================
  // NAVIGATION METHODS
  // ============================================================

  Future<void> _onRefresh() async {
    await initialLoad();
  }

  void _navigateToExplore() {
    Navigator.pushNamed(context, AppRoutes.explore);
  }

  void _navigateBookings() {
    final upcoming = _upcomingBookings;
    if (upcoming.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'no_upcoming_bookings'.tr(context),
            style: const TextStyle(fontFamily: AppTheme.fontFamily),
          ),
          backgroundColor: Colors.grey,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpcomingBookingViewAll(
          title: 'upcoming_bookings'.tr(context),
          bookings: upcoming,
        ),
      ),
    );
  }

  void _navigateViewAll() {
    final clubs = _filteredClubs;
    if (clubs.isEmpty) return;
    Navigator.pushNamed(
      context,
      AppRoutes.viewAll,
      arguments: {'title': 'clubs_nearby'.tr(context), 'data': clubs},
    );
  }

  void _openLocationPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.60,
          width: double.infinity,
          decoration: const BoxDecoration(color: Colors.transparent),
          child: MapPickerScreen(
            initialLat: _currentLat,
            initialLng: _currentLng,
            initialLabel: _locationLabel,
          ),
        );
      },
    );

    if (result != null && result.isNotEmpty && mounted) {
      setState(() {
        _locationLabel = result;
      });

      if (_user != null) {
        await _updateUserLocation(result);
      } else {
        if (_currentLat != null && _currentLng != null) {
          await _saveLocationToPrefs(
            lat: _currentLat!,
            lng: _currentLng!,
            label: result,
          );
        }
      }

      if (_currentLat != null && _currentLng != null) {
        await _refreshNearbyClubsWithUIUpdate(_currentLat!, _currentLng!);
      }
    }
  }

  Future<void> _updateUserLocation(String location) async {
    try {
      setState(() {
        _isLoading = true;
        _isSkeletonLoading = true;
      });

      final updateDto = UpdateDto(
        fullName: _user?.fullName ?? '',
        location: location,
        lat: _currentLat ?? 0.0,
        lng: _currentLng ?? 0.0,
      );

      await _userService.updateProfile(updateDto);

      setState(() {
        _user = _userService.currentUser;
        _locationLabel = _user?.location ?? location;
        _currentLat = _user?.lat;
        _currentLng = _user?.lng;
        _isLoading = false;
        _isSkeletonLoading = false;
      });

      if (_currentLat != null && _currentLng != null) {
        await _saveLocationToPrefs(
          lat: _currentLat!,
          lng: _currentLng!,
          label: location,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Location updated successfully',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isSkeletonLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update location',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.kAccent,
        backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        child: SafeArea(
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _header(isDark)),
              SliverToBoxAdapter(child: _banner()),
              SliverToBoxAdapter(child: _categoriesWidget(isDark)),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title:
                      '${'clubs_nearby'.tr(context)} (${_filteredClubs.length})',
                  onAction: _navigateViewAll,
                  isDark: isDark,
                ),
              ),
              SliverToBoxAdapter(child: _clubsList(isDark)),
              SliverToBoxAdapter(
                child: SectionHeader(
                  title: 'upcoming_bookings'.tr(context),
                  onAction: _navigateBookings,
                  isDark: isDark,
                ),
              ),
              SliverToBoxAdapter(child: _bookingsList(isDark)),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────────
  Widget _header(bool isDark) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.kAccent, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppTheme.kAccent.withValues(alpha: 0.3),
                blurRadius: 10,
              ),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: _user?.avatarUrl != null && _user!.avatarUrl!.isNotEmpty
                ? Image.network(
                    _user!.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppTheme.kAccent,
                        size: 26,
                      ),
                    ),
                    loadingBuilder: (_, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: AppTheme.kAccent,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppTheme.kAccent,
                      size: 26,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'hello_message'
                  .tr(context)
                  .replaceAll('{name}', _user?.fullName ?? 'Guest'),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: _openLocationPicker,
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_rounded,
                    color: AppTheme.kAccent,
                    size: 13,
                  ),
                  const SizedBox(width: 3),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Text(
                      _locationLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: AppTheme.kAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppTheme.kAccent,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        InkWell(
          onTap: () => Navigator.pushNamed(context, AppRoutes.notification),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
              border: Border.all(
                color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.notifications_outlined,
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  size: 22,
                ),
                Positioned(
                  top: 11,
                  right: 11,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.kAccent,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _banner() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: BannerCarousel(banners: _banners),
  );

  Widget _categoriesWidget(bool isDark) {
    if (_isCategoriesLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: SizedBox(
            height: 30,
            width: 30,
            child: CircularProgressIndicator(
              color: AppTheme.kAccent,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (_categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final displayCategories = [
      CategoryModel(
        id: 0,
        name: 'all'.tr(context),
        imageUrl: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ..._categories,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        height: 48,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayCategories.length,
          itemBuilder: (_, i) {
            final cat = displayCategories[i];
            final isAll = cat.id == 0;
            final catId = isAll ? 'all' : cat.id.toString();
            final sel = _selectedCat == catId;

            return GestureDetector(
              onTap: () => setState(() {
                _selectedCat = catId;
              }),
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
                            color: AppTheme.kAccent.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isAll) ...[
                      Text(
                        _getCategoryEmoji(cat.name),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      isAll ? 'all'.tr(context) : cat.name,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
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

  String _getCategoryEmoji(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'football':
        return '⚽';
      case 'basketball':
        return '🏀';
      case 'tennis':
        return '🎾';
      case 'badminton':
        return '🏸';
      case 'gym':
        return '🏋️';
      case 'volleyball':
        return '🏐';
      case 'swimming':
        return '🏊';
      case 'yoga':
        return '🧘';
      case 'boxing':
        return '🥊';
      case 'running':
        return '🏃';
      default:
        return '🏅';
    }
  }

  // ── Clubs List with Skeleton Loading ──────────────────────────────────────
  Widget _clubsList(bool isDark) {
    if (_isSkeletonLoading) {
      final skeletonBaseColor = isDark
          ? const Color(0xFF1E3A5F)
          : const Color(0xFFE0E0E0);
      final skeletonHighlightColor = isDark
          ? const Color(0xFF2A4A6F)
          : const Color(0xFFF5F5F5);

      return Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: skeletonBaseColor,
          highlightColor: skeletonHighlightColor,
        ),
        child: SizedBox(
          height: 290,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 3,
            itemBuilder: (_, i) => Container(
              width: 280,
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image skeleton
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.kCardAlt
                          : AppTheme.kLightCardAlt,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(22),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    height: 14,
                                    width: double.infinity,
                                    color: isDark
                                        ? AppTheme.kCardAlt
                                        : AppTheme.kLightCardAlt,
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: 10,
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
                        const SizedBox(height: 8),
                        Container(
                          height: 1,
                          color: isDark
                              ? AppTheme.kBorder
                              : AppTheme.kLightBorder,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              height: 12,
                              width: 80,
                              color: isDark
                                  ? AppTheme.kCardAlt
                                  : AppTheme.kLightCardAlt,
                            ),
                            const Spacer(),
                            Container(
                              height: 30,
                              width: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: AppTheme.kAccent,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          height: 250,
          decoration: AppTheme.cardDecorationAdaptive(context),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.kAccent),
                SizedBox(height: 16),
                Text(
                  'Loading clubs...',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.kTextSub,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_clubService.isLoadingNearby) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Container(
          height: 250,
          decoration: AppTheme.cardDecorationAdaptive(context),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: AppTheme.kAccent),
                SizedBox(height: 16),
                Text(
                  'Loading nearby clubs...',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: AppTheme.kTextSub,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final clubs = _filteredClubs;

    if (clubs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecorationAdaptive(context),
          child: Column(
            children: [
              Icon(
                Icons.sports,
                color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'no_clubs_nearby'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'suggest_change_location'.tr(context),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _openLocationPicker,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text('change_location'.tr(context)),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 290,
      child: ListView.builder(
        key: ValueKey('clubs_list_$_refreshCounter'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: clubs.length,
        itemBuilder: (_, i) => ClubCard(
          key: ValueKey('club_${clubs[i].id}_$_refreshCounter'),
          club: clubs[i],
          onBookPressed: _navigateToBookingFlow,
          onDetailPressed: _navigateToClubDetailed,
        ),
      ),
    );
  }

  // ── Bookings List ──────────────────────────────────────────────────────────
  Widget _bookingsList(bool isDark) {
    if (_isSkeletonLoading || _isBookingsLoading) {
      final skeletonBaseColor = isDark
          ? const Color(0xFF1E3A5F)
          : const Color(0xFFE0E0E0);
      final skeletonHighlightColor = isDark
          ? const Color(0xFF2A4A6F)
          : const Color(0xFFF5F5F5);

      return Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: skeletonBaseColor,
          highlightColor: skeletonHighlightColor,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: Column(
            children: List.generate(
              3,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image skeleton
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.kCardAlt
                            : AppTheme.kLightCardAlt,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                      ),
                    ),
                    // Content skeleton
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
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
                                      width: double.infinity,
                                      color: isDark
                                          ? AppTheme.kCardAlt
                                          : AppTheme.kLightCardAlt,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 12,
                                      width: 120,
                                      color: isDark
                                          ? AppTheme.kCardAlt
                                          : AppTheme.kLightCardAlt,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 18,
                                height: 18,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            height: 1,
                            color: isDark
                                ? AppTheme.kBorder
                                : AppTheme.kLightBorder,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                height: 12,
                                width: 150,
                                color: isDark
                                    ? AppTheme.kCardAlt
                                    : AppTheme.kLightCardAlt,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                width: 13,
                                height: 13,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Container(
                                height: 24,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.kCardAlt
                                      : AppTheme.kLightCardAlt,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                height: 24,
                                width: 80,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppTheme.kCardAlt
                                      : AppTheme.kLightCardAlt,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final upcoming = _upcomingBookings;

    if (upcoming.isEmpty || _hasBookingsError) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecorationAdaptive(context),
          child: Column(
            children: [
              Icon(
                Icons.calendar_today,
                color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
                size: 40,
              ),
              const SizedBox(height: 8),
              Text(
                'no_upcoming_bookings'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'book_a_club_to_get_started'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _navigateToExplore,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.kAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text('browse_clubs'.tr(context)),
              ),
            ],
          ),
        ),
      );
    }

    final displayBookings = upcoming.length > 3
        ? upcoming.sublist(0, 3)
        : upcoming;

    return Column(
      children: displayBookings.map((booking) {
        return BookingCard(
          key: ValueKey('booking_${booking.id}_$_refreshCounter'),
          booking: booking,
        );
      }).toList(),
    );
  }
}
