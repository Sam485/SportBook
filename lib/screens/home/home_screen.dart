import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/Banner/model/banner_model.dart';
import 'package:sportbook/feature/Banner/service/banner_service.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/User/model/user_model.dart';
import 'package:sportbook/feature/User/service/user_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/translations/app_translations.dart';
import 'package:sportbook/widgets/common/banner_carousel.dart';
import 'package:sportbook/widgets/common/map_picker_screen.dart';
import '../../core/theme.dart';
import '../../feature/static/models/models.dart';
import '../../feature/static/services/data_service.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/cards/booking_card.dart';
import '../../widgets/cards/club_card.dart';
import '../../widgets/common/location_picker_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCat = 'all';
  String _locationLabel = 'New York';

  final _userService = getIt<UserService>();
  final _bannerService = getIt<BannerService>();

  // Get the sport club service
  late final SportClubService _clubService;

  List<BannerModel>? _banners;
  UserModel? _user;

  // Get clubs directly from service
  List<SportClubModel> get _clubs => _clubService.clubs;

  // Get filtered clubs based on selected category
  List<SportClubModel> get _filteredClubs {
    if (_selectedCat == 'all') {
      return _clubs;
    }
    return _clubs
        .where(
          (club) =>
              club.categories.any((cat) => cat.toString() == _selectedCat),
        )
        .toList();
  }

  // Keep bookings from static data for now
  List<SportBooking> get _bookings =>
      DataService.filteredBookings(_selectedCat);

  Future<void> initialLoad() async {
    try {
      // Load banners, user, and clubs in parallel
      final results = await Future.wait([
        _bannerService.getAllActiveBanner(),
        _userService.getProfile(),
        _clubService.fetchClubs(),
      ]);

      setState(() {
        _banners = results[0] as List<BannerModel>?;
        _user = results[1] as UserModel?;
        _locationLabel = _user?.location ?? 'New York';
      });
    } catch (e) {
      print('Error loading initial data: $e');
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _clubService = getIt<SportClubService>();
    initialLoad();
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

  void _navigateBookings() {
    Navigator.pushNamed(context, AppRoutes.allbookings, arguments: true);
  }

  void _openLocationPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerSheet(),
    );

    if (!mounted) return;

    if (result == '__open_map__') {
      // User chose "Pin on Map" — open the full-screen map picker
      final city = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (_) => const MapPickerScreen()),
      );
      if (city != null && city.isNotEmpty) {
        setState(() => _locationLabel = city);
        // Refresh clubs with new location
        await _refreshClubsWithLocation(city);
      }
    } else if (result != null && result.isNotEmpty) {
      setState(() => _locationLabel = result);
      // Refresh clubs with new location
      await _refreshClubsWithLocation(result);
    }
  }

  Future<void> _refreshClubsWithLocation(String location) async {
    try {
      await _clubService.fetchClubs(search: location);
      if (mounted) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clubs updated for $location'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update clubs: $e'),
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
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(isDark)),
            SliverToBoxAdapter(child: _banner()),
            SliverToBoxAdapter(child: _categories(isDark)),
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
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => BookingCard(booking: _bookings[i]),
                childCount: _bookings.length,
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
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
          child: Container(
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

  Widget _categories(bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: DataService.categories.length,
        itemBuilder: (_, i) {
          final cat = DataService.categories[i];
          final sel = _selectedCat == cat.id;
          return GestureDetector(
            onTap: () => setState(() => _selectedCat = cat.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                  Text(cat.emoji, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text(
                    cat.name,
                    style: TextStyle(
                      color: sel
                          ? const Color(0xFF0A1828)
                          : (isDark ? Colors.white60 : AppTheme.kLightTextSub),
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

  Widget _clubsList(bool isDark) {
    // Show loading state
    if (_clubService.isLoading) {
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
                  style: TextStyle(color: AppTheme.kTextSub, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Show error state
    if (_clubService.error.isNotEmpty) {
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
                _clubService.error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () async {
                  await _clubService.fetchClubs();
                  if (mounted) setState(() {});
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

    // Get filtered clubs
    final clubs = _filteredClubs;

    // Show empty state
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
                'no_clubs_for_sport'.tr(context),
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try selecting a different category or location',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show clubs list - FIXED: using clubs instead of _clubs
    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: clubs.length,
        itemBuilder: (_, i) =>
            ClubCard(club: clubs[i]), // Changed from _clubs[i] to clubs[i]
      ),
    );
  }

  // Helper method to manually refresh data (pull to refresh would call this)
  Future<void> refreshData() async {
    await initialLoad();
  }
}
