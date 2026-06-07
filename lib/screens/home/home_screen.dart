import 'package:flutter/material.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/widgets/common/banner_carousel.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
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
  String _locationLabel = 'New York'; // display name

  List<SportClub> get _clubs => DataService.filteredClubs(_selectedCat);
  List<SportBooking> get _bookings =>
      DataService.filteredBookings(_selectedCat);

  void _navigateViewAll() {
    final clubs = _clubs;
    if (clubs.isEmpty) return;
    Navigator.pushNamed(
      context,
      AppRoutes.viewAll,
      arguments: {'title': 'Clubs Nearby', 'data': clubs},
    );
  }

  void _navigateBookings() {
    Navigator.pushNamed(context, AppRoutes.allbookings, arguments: true);
  }

  // ── Location picker ───────────────────────────────────────────────────────
  void _openLocationPicker() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const LocationPickerSheet(),
    );
    if (result != null && result.isNotEmpty) {
      setState(() => _locationLabel = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header()),
            SliverToBoxAdapter(child: _banner()),
            SliverToBoxAdapter(child: _categories()),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Clubs Nearby',
                onAction: _navigateViewAll,
              ),
            ),
            SliverToBoxAdapter(child: _clubsList()),
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Upcoming Bookings',
                onAction: _navigateBookings,
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

  Widget _header() => Padding(
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.kCard,
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
            const Text(
              'Hello, Jane 👋',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 2),
            // ✅ Tapping this now opens the location picker
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
                  Text(
                    _locationLabel,
                    style: const TextStyle(
                      color: AppTheme.kAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
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
              color: AppTheme.kCard,
              border: Border.all(color: AppTheme.kBorder),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
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
    child: const BannerCarousel(),
  );

  Widget _categories() => Padding(
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
                color: sel ? AppTheme.kAccent : AppTheme.kCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: sel ? AppTheme.kAccent : AppTheme.kBorder,
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
                      color: sel ? const Color(0xFF0A1828) : Colors.white60,
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

  Widget _clubsList() {
    final clubs = _clubs;
    if (clubs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.cardDecoration(),
          child: const Center(
            child: Text(
              'No clubs for this sport',
              style: TextStyle(color: AppTheme.kTextSub, fontSize: 14),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 290,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: clubs.length,
        itemBuilder: (_, i) => ClubCard(club: clubs[i]),
      ),
    );
  }
}
