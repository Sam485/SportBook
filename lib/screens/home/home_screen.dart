// home_screen.dart - COMPLETE FIXED VERSION WITH REAL BOOKINGS
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/Banner/model/banner_model.dart';
import 'package:sportbook/feature/Banner/service/banner_service.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/model/get_all_booking_dto.dart';
import 'package:sportbook/feature/Booking/service/booking_service.dart';
import 'package:sportbook/feature/Category/model/category_model.dart';
import 'package:sportbook/feature/Category/service/category_service.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/User/model/update_dto.dart';
import 'package:sportbook/feature/User/model/user_model.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/common/banner_carousel.dart';
import 'package:sportbook/widgets/common/map_picker_screen.dart';
import '../../core/theme.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/cards/booked_card.dart';
import '../../widgets/cards/club_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCat = 'all';
  String _locationLabel = 'New York';
  bool _isDisposed = false;
  bool _isLoading = true;
  int _refreshCounter = 0;

  // Location for nearby search
  double? _currentLat;
  double? _currentLng;
  int _radius = 10; // Default radius in km

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
  String? _bookingsError;

  // Get nearby clubs from service
  List<SportClubModel> get _clubs => List.from(_clubService.nearbyClubs);

  // Get upcoming bookings (filtered by status)
  List<BookingModel> get _upcomingBookings {
    if (_bookingsData == null) return [];
    // Filter for upcoming bookings (pending, confirmed)
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

  Future<void> initialLoad() async {
    try {
      // Get user profile first
      await _userService.getProfile();
      _user = _userService.currentUser;

      // Get user location from profile
      if (_user != null) {
        _currentLat = _user!.lat;
        _currentLng = _user!.lng;
        _locationLabel = _user!.location ?? 'New York';
      }

      // Load all data in parallel
      final results = await Future.wait([
        _bannerService.getAllActiveBanner(),
        _categoryService.fetchCategories(limit: 100),
        _bookingService.getAllBookings(page: 1, limit: 10),
      ]);

      // Load nearby clubs using user location
      if (_currentLat != null && _currentLng != null) {
        await _clubService.fetchNearbyClubs(
          lat: _currentLat!,
          lng: _currentLng!,
          radius: _radius,
        );
      } else {
        // If no location, use default coordinates (Phnom Penh)
        await _clubService.fetchNearbyClubs(
          lat: 11.5564,
          lng: 104.9282,
          radius: _radius,
        );
      }

      if (!_isDisposed && mounted) {
        setState(() {
          _banners = results[0] as List<BannerModel>?;
          _categories = results[1] as List<CategoryModel>;
          _bookingsData = results[2] as GetAllBookingDto;
          _isBookingsLoading = false;
          _isCategoriesLoading = false;
          _isLoading = false;
          _refreshCounter++;
        });
      }
    } catch (e) {
      print('Error loading initial data: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _isLoading = false;
          _isCategoriesLoading = false;
          _isBookingsLoading = false;
          _bookingsError = e.toString();
          _refreshCounter++;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _clubService = getIt<SportClubService>();
    _bookingService = getIt<BookingService>();

    // Listen to service changes
    _clubService.addListener(_onServiceChanged);

    initialLoad();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clubService.removeListener(_onServiceChanged);
    super.dispose();
  }

  void _onServiceChanged() {
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

  // ✅ Refresh data
  Future<void> _onRefresh() async {
    await initialLoad();
  }

  // ✅ Navigate to booking flow and refresh on return
  Future<void> _navigateToBookingFlow(SportClubModel club) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.bookingFlow,
      arguments: club,
    );

    // Refresh data when returning from booking flow
    if (result == true || mounted) {
      await _onRefresh();
    }
  }

  // ✅ Navigate to explore screen
  void _navigateToExplore() {
    Navigator.pushNamed(context, AppRoutes.explore);
  }

  // ✅ Navigate to bookings screen
  void _navigateBookings() {
    Navigator.pushNamed(context, AppRoutes.allbookings, arguments: true);
  }

  // ✅ Navigate view all clubs
  void _navigateViewAll() {
    final clubs = _filteredClubs;
    if (clubs.isEmpty) return;
    Navigator.pushNamed(
      context,
      AppRoutes.viewAll,
      arguments: {'title': 'clubs_nearby'.tr(context), 'data': clubs},
    );
  }

  // ✅ Open location picker
  void _openLocationPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      isDismissible: false,
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

      await _updateUserLocation(result);

      // Refresh nearby clubs with new location
      if (_currentLat != null && _currentLng != null) {
        await _refreshNearbyClubs(_currentLat!, _currentLng!);
      }
    }
  }

  Future<void> _updateUserLocation(String location) async {
    try {
      setState(() {
        _isLoading = true;
      });

      final updateDto = UpdateDto(
        fullName: _user?.fullName ?? '',
        location: location,
        lat: _currentLat ?? 0.0,
        lng: _currentLng ?? 0.0,
      );

      await _userService.updateProfile(updateDto);

      // Update user after profile update
      setState(() {
        _user = _userService.currentUser;
        _locationLabel = _user?.location ?? location;
        _currentLat = _user?.lat;
        _currentLng = _user?.lng;
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location updated successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _refreshNearbyClubs(double lat, double lng) async {
    try {
      await _clubService.fetchNearbyClubs(lat: lat, lng: lng, radius: _radius);
      if (!_isDisposed && mounted) {
        setState(() {
          _refreshCounter++;
        });
      }
    } catch (e) {
      if (!_isDisposed && mounted) {
        print('Failed to refresh nearby clubs: $e');
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
                  title: 'clubs_nearby'.tr(context),
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
                color: AppTheme.kAccent.withOpacity(0.3),
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
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            InkWell(
              onTap: _openLocationPicker,
              borderRadius: BorderRadius.circular(8),
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
                    if (!isAll) ...[
                      Text(
                        _getCategoryEmoji(cat.name),
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      isAll ? 'all'.tr(context) : cat.name,
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

  Widget _clubsList(bool isDark) {
    if (_clubService.isLoadingNearby || _isLoading) {
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
                  style: TextStyle(color: AppTheme.kTextSub, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_clubService.errorNearby.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecorationAdaptive(context),
          child: Column(
            children: [
              Icon(
                Icons.error_outline,
                color: isDark ? Colors.white60 : AppTheme.kLightTextSub,
                size: 48,
              ),
              const SizedBox(height: 12),
              Text(
                'Failed to load clubs',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _clubService.errorNearby,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  if (_currentLat != null && _currentLng != null) {
                    await _clubService.fetchNearbyClubs(
                      lat: _currentLat!,
                      lng: _currentLng!,
                      radius: _radius,
                    );
                  } else {
                    await _clubService.fetchNearbyClubs(
                      lat: 11.5564,
                      lng: 104.9282,
                      radius: _radius,
                    );
                  }
                  if (!_isDisposed && mounted) setState(() {});
                },
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
                icon: const Icon(Icons.refresh, size: 18),
                label: Text('retry'.tr(context)),
              ),
            ],
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
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try expanding your search radius or changing location',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              // Radius selector
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Radius: ',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.kLightText,
                      fontSize: 14,
                    ),
                  ),
                  DropdownButton<int>(
                    value: _radius,
                    dropdownColor: isDark
                        ? AppTheme.kCard
                        : AppTheme.kLightCard,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.kLightText,
                    ),
                    items: const [
                      DropdownMenuItem(value: 5, child: Text('5 km')),
                      DropdownMenuItem(value: 10, child: Text('10 km')),
                      DropdownMenuItem(value: 20, child: Text('20 km')),
                      DropdownMenuItem(value: 50, child: Text('50 km')),
                    ],
                    onChanged: (newRadius) async {
                      if (newRadius != null && mounted) {
                        setState(() {
                          _radius = newRadius;
                          _isLoading = true;
                        });

                        if (_currentLat != null && _currentLng != null) {
                          await _clubService.fetchNearbyClubs(
                            lat: _currentLat!,
                            lng: _currentLng!,
                            radius: _radius,
                          );
                        } else {
                          await _clubService.fetchNearbyClubs(
                            lat: 11.5564,
                            lng: 104.9282,
                            radius: _radius,
                          );
                        }

                        if (mounted) {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                  ),
                ],
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
        ),
      ),
    );
  }

  // ── Bookings List ──────────────────────────────────────────────────────────
  Widget _bookingsList(bool isDark) {
    if (_isBookingsLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Container(
          height: 120,
          decoration: AppTheme.cardDecorationAdaptive(context),
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: AppTheme.kAccent,
                  strokeWidth: 2,
                ),
                SizedBox(height: 12),
                Text(
                  'Loading bookings...',
                  style: TextStyle(color: AppTheme.kTextSub, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_bookingsError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.cardDecorationAdaptive(context),
          child: Column(
            children: [
              Icon(Icons.error_outline, color: Colors.orange, size: 32),
              const SizedBox(height: 8),
              Text(
                'Failed to load bookings',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _bookingsError!,
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final upcoming = _upcomingBookings;

    if (upcoming.isEmpty) {
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
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'book_a_club_to_get_started'.tr(context),
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _navigateToExplore, // ✅ Navigate to explore
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
                ),
                child: Text(
                  'browse_clubs'.tr(context),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show only first 3 upcoming bookings
    final displayBookings = upcoming.length > 3
        ? upcoming.sublist(0, 3)
        : upcoming;

    return Column(
      children: displayBookings.map((booking) {
        return BookedCard(
          key: ValueKey('booking_${booking.id}_$_refreshCounter'),
          booking: booking,
          onBookingUpdated: _onRefresh, // ✅ Refresh when booking is updated
        );
      }).toList(),
    );
  }
}
