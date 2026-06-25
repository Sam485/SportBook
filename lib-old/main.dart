import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const SportBookingApp());
}

const kAccent = Color(0xFF29B6F6);
const kBg = Color(0xFF0A1828);
const kCard = Color(0xFF0F2440);
const kCardAlt = Color(0xFF132D4E);
const kBorder = Color(0xFF1E3A5F);
const kTextSub = Color(0xFF6B9BBF);

// ─── MODELS ───────────────────────────────────────────────────────────────────

class SportCategory {
  final String name;
  final String emoji;
  const SportCategory(this.name, this.emoji);
}

class SportClub {
  final String name;
  final String initials;
  final Color color;
  final double distanceKm;
  final String openTime;
  final String closeTime;
  final String venue;
  final String description;
  final List<String> sports;
  final List<String> imageUrls;
  final int totalCourts;
  final double pricePerHour;
  const SportClub(
    this.name,
    this.initials,
    this.color,
    this.distanceKm,
    this.openTime,
    this.closeTime,
    this.venue,
    this.description,
    this.sports,
    this.imageUrls,
    this.totalCourts,
    this.pricePerHour,
  );
}

class SportBooking {
  final String title;
  final String ownerName;
  final String ownerInitials;
  final Color ownerColor;
  final List<String> sportTypes;
  final String venue;
  final List<String> imageUrls;
  final String openTime;
  final String closeTime;
  final int bookedSlots;
  final int totalSlots;
  const SportBooking(
    this.title,
    this.ownerName,
    this.ownerInitials,
    this.ownerColor,
    this.sportTypes,
    this.venue,
    this.imageUrls,
    this.openTime,
    this.closeTime,
    this.bookedSlots,
    this.totalSlots,
  );
  String get primarySport => sportTypes.isNotEmpty ? sportTypes.first : 'Sport';
}

// ─── APP ROOT ─────────────────────────────────────────────────────────────────

class SportBookingApp extends StatelessWidget {
  const SportBookingApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'SportMate',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: kBg,
      colorScheme: const ColorScheme.dark(primary: kAccent, surface: kCard),
    ),
    home: const HomePage(),
  );
}

// ─── HOME PAGE ────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _nav = 0;
  int _cat = 0;

  static const List<SportCategory> categories = [
    SportCategory('All', '🏅'),
    SportCategory('Football', '⚽'),
    SportCategory('Badminton', '🏸'),
    SportCategory('Tennis', '🎾'),
    SportCategory('Basketball', '🏀'),
  ];

  static const List<SportClub> allClubs = [
    SportClub(
      'Victory FC Club',
      'VF',
      Color(0xFF4CAF50),
      1.2,
      '06:00 AM',
      '10:00 PM',
      'Central Park Field A',
      'Professional football training with full-size pitches.',
      ['Football'],
      [
        'https://images.unsplash.com/photo-1510051640316-cee39563ddab?w=800&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
        'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&q=80',
      ],
      3,
      15.0,
    ),
    SportClub(
      'Smash Badminton',
      'SB',
      Color(0xFF29B6F6),
      2.5,
      '07:00 AM',
      '11:00 PM',
      'SportZone Hall 2',
      'Indoor courts with pro-grade synthetic surface.',
      ['Badminton', 'Tennis'],
      [
        'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&q=80',
        'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800&q=80',
      ],
      6,
      12.0,
    ),
    SportClub(
      'Slam Dunk Arena',
      'SD',
      Color(0xFFFF9800),
      4.1,
      '07:00 AM',
      '11:00 PM',
      'Downtown Arena Court 1',
      '3v3 and 5v5 basketball with floodlit courts.',
      ['Basketball'],
      [
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&q=80',
        'https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=800&q=80',
      ],
      5,
      18.0,
    ),
    SportClub(
      'SportZone Hub',
      'SZ',
      Color(0xFFFF5722),
      6.8,
      '06:00 AM',
      '12:00 AM',
      'Riverside Sports Complex',
      'Multi-sport complex for all levels and ages.',
      ['Football', 'Tennis', 'Basketball', 'Badminton'],
      [
        'https://images.unsplash.com/photo-1565728744382-61accd4aa148?w=800&q=80',
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
      ],
      12,
      10.0,
    ),
  ];

  static const List<SportBooking> allBookings = [
    SportBooking(
      'Evening Football Rally',
      'Carlos Mendez',
      'CM',
      Color(0xFF4CAF50),
      ['Football'],
      'Central Park Field A',
      [
        'https://images.unsplash.com/photo-1510051640316-cee39563ddab?w=800&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
        'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&q=80',
      ],
      '08:00 AM',
      '10:00 PM',
      3,
      10,
    ),
    SportBooking(
      'Badminton & Tennis Night',
      'Sarah Kim',
      'SK',
      Color(0xFF29B6F6),
      ['Badminton', 'Tennis'],
      'SportZone Hall 2',
      [
        'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=800&q=80',
        'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=800&q=80',
      ],
      '10:00 AM',
      '09:00 PM',
      2,
      4,
    ),
    SportBooking(
      'Multi-Sport Arena',
      'David Osei',
      'DO',
      Color(0xFFFF9800),
      ['Football', 'Basketball', 'Tennis'],
      'Riverside Sports Complex',
      [
        'https://images.unsplash.com/photo-1565728744382-61accd4aa148?w=800&q=80',
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&q=80',
        'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=800&q=80',
        'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=800&q=80',
      ],
      '07:00 AM',
      '11:00 PM',
      5,
      12,
    ),
    SportBooking(
      '3v3 Basketball Open',
      'Priya Sharma',
      'PS',
      Color(0xFFFF5722),
      ['Basketball'],
      'Downtown Arena Court 1',
      [
        'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=800&q=80',
        'https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=800&q=80',
      ],
      '09:00 AM',
      '08:00 PM',
      4,
      6,
    ),
  ];

  List<SportClub> get _clubs {
    if (_cat == 0) return allClubs;
    final s = categories[_cat].name;
    return allClubs.where((c) => c.sports.contains(s)).toList();
  }

  List<SportBooking> get _bookings {
    if (_cat == 0) return allBookings;
    final s = categories[_cat].name;
    return allBookings.where((b) => b.sportTypes.contains(s)).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: kBg,
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: _banner()),
                SliverToBoxAdapter(child: _categories()),
                SliverToBoxAdapter(
                  child: _sectionHead('Clubs Nearby', 'View All'),
                ),
                SliverToBoxAdapter(child: _nearbyCLubs()),
                SliverToBoxAdapter(
                  child: _sectionHead('Upcoming Bookings', 'View All'),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => _bookingCard(_bookings[i]),
                    childCount: _bookings.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
          _bottomNav(),
        ],
      ),
    ),
  );

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _header() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
    child: Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: kAccent, width: 2),
            boxShadow: [
              BoxShadow(color: kAccent.withValues(alpha: 0.3), blurRadius: 10),
            ],
          ),
          padding: const EdgeInsets.all(2),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: kCard,
            ),
            child: const Icon(Icons.person_rounded, color: kAccent, size: 26),
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
            Row(
              children: const [
                Icon(Icons.location_on_rounded, color: kAccent, size: 13),
                SizedBox(width: 3),
                Text(
                  'New York',
                  style: TextStyle(
                    color: kAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: kAccent,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: kCard,
            border: Border.all(color: kBorder),
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
                    color: kAccent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Banner ──────────────────────────────────────────────────────────────

  Widget _banner() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: Container(
      height: 138,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [const Color(0xFF1A5276), kAccent.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: kAccent.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -24, top: -24, child: _circle(130, 0.08)),
          Positioned(right: 30, bottom: -36, child: _circle(90, 0.06)),
          const Positioned(
            right: 28,
            top: 16,
            child: Text('⚽', style: TextStyle(fontSize: 28)),
          ),
          const Positioned(
            right: 80,
            bottom: 16,
            child: Text('🏸', style: TextStyle(fontSize: 22)),
          ),
          const Positioned(
            right: 16,
            bottom: 16,
            child: Text('🏀', style: TextStyle(fontSize: 20)),
          ),
          const Padding(
            padding: EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Book Your Next\nSport Session',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Find courts, book slots, meet players',
                  style: TextStyle(color: Colors.white70, fontSize: 12.5),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _circle(double s, double o) => Container(
    width: s,
    height: s,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withValues(alpha: o),
    ),
  );

  // ── Categories ──────────────────────────────────────────────────────────

  Widget _categories() => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final sel = _cat == i;
          return GestureDetector(
            onTap: () => setState(() => _cat = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: sel ? kAccent : kCard,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: sel ? kAccent : kBorder),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: kAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    categories[i].emoji,
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    categories[i].name,
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

  // ── Section header ──────────────────────────────────────────────────────

  Widget _sectionHead(String title, String action) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        Text(
          action,
          style: const TextStyle(
            color: kAccent,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  // ── Nearby Clubs ────────────────────────────────────────────────────────

  Widget _nearbyCLubs() {
    final list = _clubs.where((c) => c.distanceKm <= 10).toList();
    if (list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCard,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'No clubs nearby for this sport',
              style: TextStyle(color: kTextSub, fontSize: 14),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 275,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: list.length,
        itemBuilder: (_, i) => _clubCard(list[i]),
      ),
    );
  }

  Widget _clubCard(SportClub c) => Container(
    width: 260,
    margin: const EdgeInsets.only(right: 14),
    clipBehavior: Clip.hardEdge,
    decoration: BoxDecoration(
      color: kCard,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: kBorder),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ClubImageCarousel(imageUrls: c.imageUrls, club: c),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: c.color.withValues(alpha: 0.2),
                      border: Border.all(color: c.color, width: 1.8),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c.initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.lock_open_outlined,
                              color: kAccent,
                              size: 11,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              c.openTime,
                              style: const TextStyle(
                                color: kAccent,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                color: kTextSub,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.lock_outline,
                              color: kTextSub,
                              size: 11,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              c.closeTime,
                              style: const TextStyle(
                                color: kTextSub,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(height: 1, color: kBorder),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.place_outlined, color: kAccent, size: 12),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      c.venue,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.route_outlined, color: kAccent, size: 12),
                  const SizedBox(width: 4),
                  Text(
                    '${c.distanceKm} km away',
                    style: const TextStyle(color: kTextSub, fontSize: 11),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => _showCourtBookingSheet(
                      context: context,
                      name: c.name,
                      initials: c.initials,
                      color: c.color,
                      venue: c.venue,
                      openTime: c.openTime,
                      closeTime: c.closeTime,
                      totalCourts: c.totalCourts,
                      pricePerHour: c.pricePerHour,
                      sports: c.sports,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: kAccent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: kAccent.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Text(
                        'Book',
                        style: TextStyle(
                          color: kBg,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Booking card ─────────────────────────────────────────────────────────

  Widget _bookingCard(SportBooking b) {
    final unique = b.sportTypes.toSet().toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Container(
        decoration: BoxDecoration(
          color: kCard,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: kBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ImageCarousel(imageUrls: b.imageUrls, booking: b),
            InkWell(
              onTap: () => _showCourtBookingSheet(
                context: context,
                name: b.title,
                initials: b.ownerInitials,
                color: b.ownerColor,
                venue: b.venue,
                openTime: b.openTime,
                closeTime: b.closeTime,
                totalCourts: b.totalSlots,
                pricePerHour: 12.0,
                sports: b.sportTypes.toSet().toList(),
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22),
              ),
              splashColor: kAccent.withValues(alpha: 0.08),
              highlightColor: kAccent.withValues(alpha: 0.04),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: b.ownerColor.withValues(alpha: 0.2),
                            border: Border.all(color: b.ownerColor, width: 1.8),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            b.ownerInitials,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                b.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.2,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.lock_open_outlined,
                                    color: kAccent,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    b.openTime,
                                    style: const TextStyle(
                                      color: kAccent,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 3,
                                    height: 3,
                                    decoration: const BoxDecoration(
                                      color: kTextSub,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.lock_outline,
                                    color: kTextSub,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    b.closeTime,
                                    style: const TextStyle(
                                      color: kTextSub,
                                      fontSize: 11.5,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: kTextSub,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(height: 1, color: kBorder),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.place_outlined,
                          color: kAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            b.venue,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.sports_outlined,
                            color: kAccent,
                            size: 13,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: unique
                                .map(
                                  (s) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: kAccent.withValues(alpha: 0.10),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: kAccent.withValues(alpha: 0.35),
                                      ),
                                    ),
                                    child: Text(
                                      '${_emoji(s)} $s',
                                      style: const TextStyle(
                                        color: kAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
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

  String _emoji(String s) {
    switch (s) {
      case 'Football':
        return '⚽';
      case 'Badminton':
        return '🏸';
      case 'Tennis':
        return '🎾';
      case 'Basketball':
        return '🏀';
      default:
        return '🏅';
    }
  }

  // ─── COURT + TIME BOOKING SHEET ──────────────────────────────────────────
  //
  //  Step 1 — Select Sport (if >1 sport)
  //  Step 2 — Select Court
  //  Step 3 — Select Date
  //  Step 4 — Select Time slot
  //  Summary + Confirm button
  // ─────────────────────────────────────────────────────────────────────────

  void _showCourtBookingSheet({
    required BuildContext context,
    required String name,
    required String initials,
    required Color color,
    required String venue,
    required String openTime,
    required String closeTime,
    required int totalCourts,
    required double pricePerHour,
    required List<String> sports,
  }) {
    // Time slots derived from open→close, every 2 hours
    final List<String> timeSlots = _buildTimeSlots(openTime, closeTime);

    // Dates: today + 6 days
    final today = DateTime.now();
    final dates = List.generate(7, (i) => today.add(Duration(days: i)));

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _CourtBookingSheet(
        name: name,
        initials: initials,
        color: color,
        venue: venue,
        openTime: openTime,
        closeTime: closeTime,
        totalCourts: totalCourts,
        pricePerHour: pricePerHour,
        sports: sports,
        timeSlots: timeSlots,
        dates: dates,
        emojiFor: _emoji,
        onConfirm: (sport, court, date, time) {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅  $name · Court $court · ${_fmtDate(date)} · $time',
              ),
              backgroundColor: const Color(0xFF1A3A5C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        },
      ),
    );
  }

  static List<String> _buildTimeSlots(String open, String close) {
    int parseMins(String t) {
      try {
        final p = t.trim().split(':');
        var h = int.parse(p[0]);
        final rest = p[1].split(' ');
        final period = rest[1].toUpperCase();
        if (period == 'PM' && h != 12) h += 12;
        if (period == 'AM' && h == 12) h = 0;
        return h * 60 + int.parse(rest[0]);
      } catch (_) {
        return 0;
      }
    }

    String fmtMins(int m) {
      final h = m ~/ 60;
      final period = h >= 12 ? 'PM' : 'AM';
      final hr = h % 12 == 0 ? 12 : h % 12;
      return '$hr:00 $period';
    }

    final start = parseMins(open);
    final end = parseMins(close);
    final slots = <String>[];
    for (var m = start; m + 120 <= end; m += 120) {
      slots.add('${fmtMins(m)} – ${fmtMins(m + 120)}');
    }
    return slots.isEmpty
        ? [
            '8:00 AM – 10:00 AM',
            '10:00 AM – 12:00 PM',
            '12:00 PM – 2:00 PM',
            '2:00 PM – 4:00 PM',
          ]
        : slots;
  }

  static String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final isToday = DateUtils.isSameDay(d, DateTime.now());
    return isToday ? 'Today' : '${months[d.month - 1]} ${d.day}';
  }

  // ── Bottom nav ───────────────────────────────────────────────────────────

  Widget _bottomNav() => Container(
    decoration: const BoxDecoration(
      color: Color(0xFF0C1E34),
      border: Border(top: BorderSide(color: kBorder, width: 1)),
      boxShadow: [
        BoxShadow(color: Colors.black38, blurRadius: 20, offset: Offset(0, -4)),
      ],
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: GNav(
          gap: 8,
          activeColor: const Color(0xFF0A1828),
          color: Colors.white38,
          iconSize: 22,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          duration: const Duration(milliseconds: 350),
          tabBackgroundColor: kAccent,
          selectedIndex: _nav,
          onTabChange: (i) => setState(() => _nav = i),
          tabs: const [
            GButton(icon: Icons.home_rounded, text: 'Home'),
            GButton(icon: Icons.search_rounded, text: 'Explore'),
            GButton(icon: Icons.calendar_month_rounded, text: 'Bookings'),
            GButton(icon: Icons.group_rounded, text: 'Players'),
            GButton(icon: Icons.settings_rounded, text: 'Settings'),
          ],
        ),
      ),
    ),
  );
}

// ─── COURT BOOKING SHEET ─────────────────────────────────────────────────────
//
//  A single DraggableScrollableSheet with three visible sections:
//   ① Sport picker  (only if >1 sport)
//   ② Court grid
//   ③ Date row
//   ④ Time slot grid
//   ⑤ Summary bar + Confirm button
// ─────────────────────────────────────────────────────────────────────────────

// ─── COURT BOOKING SHEET ─────────────────────────────────────────────────────
//
//  Step 1 — Select Court  (image cards; 2-col grid; tap image → full-screen)
//           If sport = Gym → shows Trainer cards instead
//  Step 2 — Select Date
//  Step 3 — Select Time Range  (1 AM – 12 PM; already-booked hours hidden)
//  Sticky confirm bar with live summary
// ─────────────────────────────────────────────────────────────────────────────

// ── Static court / trainer data ───────────────────────────────────────────────

const _kCourtImages = {
  'Football': [
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?w=600&q=80',
    'https://images.unsplash.com/photo-1431324155629-1a6deb1dec8d?w=600&q=80',
    'https://images.unsplash.com/photo-1510051640316-cee39563ddab?w=600&q=80',
  ],
  'Badminton': [
    'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&q=80',
    'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=600&q=80',
  ],
  'Tennis': [
    'https://images.unsplash.com/photo-1554068865-24cecd4e34b8?w=600&q=80',
    'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=600&q=80',
  ],
  'Basketball': [
    'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=600&q=80',
    'https://images.unsplash.com/photo-1504450758481-7338eba7524a?w=600&q=80',
  ],
  'Gym': [
    'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=600&q=80',
    'https://images.unsplash.com/photo-1571902943202-507ec2618e8f?w=600&q=80',
    'https://images.unsplash.com/photo-1593079831268-3381b0db4a77?w=600&q=80',
  ],
};

const _kTrainers = [
  {
    'name': 'Marcus Webb',
    'spec': 'Strength & Conditioning',
    'img':
        'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?w=400&q=80',
  },
  {
    'name': 'Priya Nair',
    'spec': 'Yoga & Flexibility',
    'img':
        'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400&q=80',
  },
  {
    'name': 'Jake Sullivan',
    'spec': 'CrossFit & HIIT',
    'img':
        'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?w=400&q=80',
  },
  {
    'name': 'Aisha Okafor',
    'spec': 'Nutrition & Wellness',
    'img':
        'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=400&q=80',
  },
];

// ── Widget ────────────────────────────────────────────────────────────────────

class _CourtBookingSheet extends StatefulWidget {
  final String name, initials, venue, openTime, closeTime;
  final Color color;
  final int totalCourts;
  final double pricePerHour;
  final List<String> sports;
  final List<DateTime> dates;
  final String Function(String) emojiFor;
  final void Function(String sport, int court, DateTime date, String timeRange)
  onConfirm;

  const _CourtBookingSheet({
    required this.name,
    required this.initials,
    required this.color,
    required this.venue,
    required this.openTime,
    required this.closeTime,
    required this.totalCourts,
    required this.pricePerHour,
    required this.sports,
    required this.dates,
    required this.emojiFor,
    required this.onConfirm,
    required List<String> timeSlots,
  });

  @override
  State<_CourtBookingSheet> createState() => _CourtBookingSheetState();
}

class _CourtBookingSheetState extends State<_CourtBookingSheet> {
  int? _court; // 1-based court number; for gym = trainer index
  int _dateIdx = 0;
  int? _startH;
  int? _endH;

  // Booked ranges: key = "court-dateIdx", value = [[startH, endH], ...]
  final Map<String, List<List<int>>> _bookedRanges = {};

  // Gym detection
  bool get _isGym => widget.sports.any((s) => s == 'Gym');

  @override
  void initState() {
    super.initState();
    // Seed some demo bookings
    _bookedRanges['1-0'] = [
      [9, 11],
    ];
    _bookedRanges['2-0'] = [
      [14, 16],
    ];
  }

  // ── Time helpers ───────────────────────────────────────────────────────────

  // Fixed range: 12 AM (midnight) → 11 PM  = full 24 h
  static const int _kStartH = 0; // 12:00 AM
  // 11:00 PM (last selectable hour)

  // All hours 12 AM – 11 PM (24 slots)
  List<int> get _allHours => List.generate(24, (i) => i);

  String _key([int? c]) => '${c ?? _court}-$_dateIdx';

  List<List<int>> get _myBookings => _bookedRanges[_key()] ?? [];

  bool _hourBookedForRange(int s, int e) {
    for (final r in _myBookings) {
      if (s < r[1] && e > r[0]) return true;
    }
    return false;
  }

  void _resetTime() => setState(() {
    _startH = null;
    _endH = null;
  });

  bool get _canConfirm =>
      _court != null && _startH != null && _endH != null && _endH! > _startH!;

  static String _fmtH(int h) {
    final p = h >= 12 ? 'PM' : 'AM';
    final hr = h % 12 == 0 ? 12 : h % 12;
    return '$hr:00 $p';
  }

  String get _timeRangeLabel => (_startH != null && _endH != null)
      ? '${_fmtH(_startH!)} – ${_fmtH(_endH!)}'
      : '';

  // ── Court image helper ─────────────────────────────────────────────────────

  String _courtImage(int courtNum) {
    final sport = widget.sports.isNotEmpty ? widget.sports.first : 'Football';
    final imgs = _kCourtImages[sport] ?? _kCourtImages['Football']!;
    return imgs[(courtNum - 1) % imgs.length];
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.55,
      maxChildSize: 0.97,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF0E2038),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          children: [
            _topBar(),
            Expanded(
              child: ListView(
                controller: ctrl,
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 110),
                children: [
                  _stepProgress(),
                  const SizedBox(height: 22),

                  // Step 1 — Court / Trainer
                  _sectionLabel(
                    _isGym ? '① Select Trainer' : '① Select Court',
                    done: _court != null,
                  ),
                  const SizedBox(height: 12),
                  _isGym ? _trainerGrid() : _courtGrid(),
                  const SizedBox(height: 22),

                  // Step 2 — Date
                  _sectionLabel('② Select Date', done: true),
                  const SizedBox(height: 10),
                  _dateRow(),
                  const SizedBox(height: 22),

                  // Step 3 — Time Range
                  _sectionLabel(
                    '③ Select Time Range',
                    done: _canConfirm,
                    hint: _court == null ? '(select court first)' : null,
                  ),
                  const SizedBox(height: 10),
                  _timeRangePicker(),
                ],
              ),
            ),
            _confirmBar(context),
          ],
        ),
      ),
    );
  }

  // ── Top bar ────────────────────────────────────────────────────────────────

  Widget _topBar() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Column(
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withValues(alpha: 0.2),
                border: Border.all(color: widget.color, width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        color: kAccent,
                        size: 12,
                      ),
                      const SizedBox(width: 3),
                      Expanded(
                        child: Text(
                          widget.venue,
                          style: const TextStyle(
                            color: kTextSub,
                            fontSize: 11.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kCardAlt,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: kAccent,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.openTime} – ${widget.closeTime}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Container(height: 1, color: kBorder),
      ],
    ),
  );

  // ── Step progress ──────────────────────────────────────────────────────────

  Widget _stepProgress() {
    final steps = [_isGym ? 'Trainer' : 'Court', 'Date', 'Time'];
    final cur = _court == null
        ? 0
        : _canConfirm
        ? 2
        : 1;

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              color: i ~/ 2 < cur ? kAccent : kBorder,
            ),
          );
        }
        final si = i ~/ 2;
        final done = si < cur;
        final active = si == cur;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? kAccent
                    : active
                    ? kAccent.withValues(alpha: 0.2)
                    : kCardAlt,
                border: Border.all(
                  color: done || active ? kAccent : kBorder,
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: done
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 14,
                    )
                  : Text(
                      '${si + 1}',
                      style: TextStyle(
                        color: active ? kAccent : Colors.white38,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[si],
              style: TextStyle(
                color: done || active ? Colors.white70 : Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      }),
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String title, {bool done = false, String? hint}) => Row(
    children: [
      Text(
        title,
        style: TextStyle(
          color: done ? Colors.white : Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      if (done) ...[
        const SizedBox(width: 6),
        const Icon(Icons.check_circle_rounded, color: kAccent, size: 15),
      ],
      if (hint != null) ...[
        const SizedBox(width: 6),
        Text(hint, style: const TextStyle(color: kTextSub, fontSize: 11.5)),
      ],
    ],
  );

  // ── Court grid (2-column with images) ─────────────────────────────────────

  Widget _courtGrid() {
    final total = widget.totalCourts.clamp(1, 12);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.45,
      ),
      itemCount: total,
      itemBuilder: (_, i) {
        final num = i + 1;
        final sel = _court == num;
        final img = _courtImage(num);
        return GestureDetector(
          onTap: () => setState(() {
            _court = num;
            _resetTime();
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sel ? kAccent : kBorder,
                width: sel ? 2.5 : 1,
              ),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: kAccent.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            // ClipRRect sits INSIDE AnimatedContainer so border is visible
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14.5),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Court photo
                  Image.network(
                    img,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: kCardAlt,
                      child: const Icon(Icons.sports, color: kAccent, size: 32),
                    ),
                  ),

                  // Dark scrim
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          sel
                              ? const Color(0xCC0A1828)
                              : const Color(0x880A1828),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.3, 1.0],
                      ),
                    ),
                  ),

                  // Selected tick
                  if (sel)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kAccent,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),

                  // Expand / view image icon
                  Positioned(
                    top: 8,
                    left: 8,
                    child: GestureDetector(
                      onTap: () => _openFullScreenImage(img, 'Court $num'),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.5),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(
                          Icons.open_in_full_rounded,
                          color: Colors.white70,
                          size: 13,
                        ),
                      ),
                    ),
                  ),

                  // Court label
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Court $num',
                          style: TextStyle(
                            color: sel ? kAccent : Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            shadows: const [
                              Shadow(color: Colors.black87, blurRadius: 4),
                            ],
                          ),
                        ),
                        Text(
                          widget.sports.isNotEmpty
                              ? '${widget.emojiFor(widget.sports.first)} ${widget.sports.first}'
                              : '',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            shadows: [
                              Shadow(color: Colors.black87, blurRadius: 3),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Trainer grid (for Gym clubs) ───────────────────────────────────────────

  Widget _trainerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _kTrainers.length,
      itemBuilder: (_, i) {
        final t = _kTrainers[i];
        final sel = _court == i + 1;
        return GestureDetector(
          onTap: () => setState(() {
            _court = i + 1;
            _resetTime();
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sel ? kAccent : kBorder,
                width: sel ? 2.5 : 1,
              ),
              boxShadow: sel
                  ? [
                      BoxShadow(
                        color: kAccent.withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  t['img']!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: kCardAlt),
                ),

                // Scrim
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Color(0xDD0A1828)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.35, 1.0],
                    ),
                  ),
                ),

                // Selected tick
                if (sel)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kAccent,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),

                // Expand
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () => _openFullScreenImage(t['img']!, t['name']!),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.5),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Icon(
                        Icons.open_in_full_rounded,
                        color: Colors.white70,
                        size: 13,
                      ),
                    ),
                  ),
                ),

                // Name + specialty
                Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t['name']!,
                        style: TextStyle(
                          color: sel ? kAccent : Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          shadows: const [
                            Shadow(color: Colors.black87, blurRadius: 4),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t['spec']!,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 10,
                          shadows: [
                            Shadow(color: Colors.black87, blurRadius: 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Open full-screen image viewer for a court/trainer photo ───────────────

  void _openFullScreenImage(String url, String label) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, _, _) => _SingleImageViewer(url: url, label: label),
        transitionsBuilder: (_, a, _, c) =>
            FadeTransition(opacity: a, child: c),
      ),
    );
  }

  // ── Date row ───────────────────────────────────────────────────────────────

  Widget _dateRow() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return SizedBox(
      height: 74,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.dates.length,
        itemBuilder: (_, i) {
          final d = widget.dates[i];
          final sel = _dateIdx == i;
          final isToday = DateUtils.isSameDay(d, DateTime.now());
          return GestureDetector(
            onTap: () => setState(() {
              _dateIdx = i;
              _resetTime();
            }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 10),
              width: 60,
              decoration: BoxDecoration(
                color: sel ? kAccent : kCardAlt,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: sel ? kAccent : kBorder),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: kAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isToday ? 'Today' : days[d.weekday % 7],
                    style: TextStyle(
                      color: sel ? kBg : kTextSub,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${d.day}',
                    style: TextStyle(
                      color: sel ? kBg : Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    months[d.month - 1],
                    style: TextStyle(
                      color: sel ? kBg.withValues(alpha: 0.6) : kTextSub,
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Time range picker ──────────────────────────────────────────────────────
  //
  //  Both Start and End rows show ALL hours 1 AM → 12 PM.
  //  Hours already booked for this court+date are simply hidden (not shown).
  //  End must be > Start (validated at confirm).
  // ──────────────────────────────────────────────────────────────────────────

  Widget _timeRangePicker() {
    if (_court == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kCardAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, color: kTextSub, size: 15),
            SizedBox(width: 8),
            Text(
              'Select a court first',
              style: TextStyle(color: kTextSub, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // All hours 1 AM – 12 PM
    final allH = _allHours;

    // Filter out hours already booked for any overlapping range
    List<int> availableFor(bool isEnd) => allH.where((h) {
      if (isEnd) {
        if (_startH != null && h <= _startH!) return false;
        return !_hourBookedForRange(_startH ?? _kStartH, h);
      } else {
        // For start: hide hour if it's inside a booked block
        for (final r in _myBookings) {
          if (h >= r[0] && h < r[1]) return false;
        }
        return true;
      }
    }).toList();

    final startHours = availableFor(false);
    final endHours = availableFor(true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Start row ────────────────────────────────────────────────────
        _rowLabel(
          'Start',
          Icons.play_arrow_rounded,
          const Color(0xFF4CAF50),
          _startH,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: startHours.length,
            itemBuilder: (_, i) {
              final h = startHours[i];
              final sel = _startH == h;
              final inR =
                  _startH != null &&
                  _endH != null &&
                  h > _startH! &&
                  h < _endH!;
              return GestureDetector(
                onTap: () => setState(() {
                  _startH = h;
                  if (_endH != null && _endH! <= h) _endH = null;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: sel
                        ? const Color(0xFF4CAF50)
                        : inR
                        ? kAccent.withValues(alpha: 0.15)
                        : kCardAlt,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: sel
                          ? const Color(0xFF4CAF50)
                          : inR
                          ? kAccent.withValues(alpha: 0.4)
                          : kBorder,
                    ),
                  ),
                  child: Text(
                    _fmtH(h),
                    style: TextStyle(
                      color: sel
                          ? Colors.white
                          : inR
                          ? kAccent
                          : Colors.white60,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 14),

        // ── End row ───────────────────────────────────────────────────────
        _rowLabel('End', Icons.stop_rounded, Colors.redAccent, _endH),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: endHours.isEmpty
              ? const Center(
                  child: Text(
                    'No available end times',
                    style: TextStyle(color: kTextSub, fontSize: 12.5),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: endHours.length,
                  itemBuilder: (_, i) {
                    final h = endHours[i];
                    final sel = _endH == h;
                    final inR =
                        _endH != null && h > (_startH ?? 0) && h < _endH!;
                    return GestureDetector(
                      onTap: () => setState(() => _endH = h),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? Colors.redAccent
                              : inR
                              ? kAccent.withValues(alpha: 0.12)
                              : kCardAlt,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: sel
                                ? Colors.redAccent
                                : inR
                                ? kAccent.withValues(alpha: 0.4)
                                : kBorder,
                          ),
                        ),
                        child: Text(
                          _fmtH(h),
                          style: TextStyle(
                            color: sel
                                ? Colors.white
                                : inR
                                ? kAccent
                                : Colors.white60,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),

        // ── Live duration chip ────────────────────────────────────────────
        if (_startH != null && _endH != null && _endH! > _startH!) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: kAccent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: kAccent.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.timelapse_rounded, color: kAccent, size: 15),
                const SizedBox(width: 6),
                Text(
                  '$_timeRangeLabel  (${_endH! - _startH!}h)',
                  style: const TextStyle(
                    color: kAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '\$${((_endH! - _startH!) * widget.pricePerHour).toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _rowLabel(String label, IconData icon, Color color, int? selectedH) =>
      Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 6),
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (selectedH != null) ...[
            const SizedBox(width: 6),
            Text(
              _fmtH(selectedH),
              style: const TextStyle(color: Colors.white70, fontSize: 11.5),
            ),
          ],
        ],
      );

  // ── Confirm sticky bar ─────────────────────────────────────────────────────

  Widget _confirmBar(BuildContext ctx) {
    final label = _isGym
        ? (_court != null ? _kTrainers[_court! - 1]['name']! : '')
        : (_court != null ? 'Court $_court' : '');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2038),
        border: const Border(top: BorderSide(color: kBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_canConfirm) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kCardAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  _dot(),
                  Text(
                    _HomePageState._fmtDate(widget.dates[_dateIdx]),
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  _dot(),
                  Expanded(
                    child: Text(
                      _timeRangeLabel,
                      style: const TextStyle(
                        color: kAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          GestureDetector(
            onTap: _canConfirm
                ? () {
                    final key = _key();
                    (_bookedRanges[key] ??= []).add([_startH!, _endH!]);
                    widget.onConfirm(
                      widget.sports.isNotEmpty ? widget.sports.first : '',
                      _court!,
                      widget.dates[_dateIdx],
                      _timeRangeLabel,
                    );
                  }
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 52,
              decoration: BoxDecoration(
                color: _canConfirm ? kAccent : kBorder,
                borderRadius: BorderRadius.circular(26),
                boxShadow: _canConfirm
                    ? [
                        BoxShadow(
                          color: kAccent.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              alignment: Alignment.center,
              child: Text(
                _canConfirm
                    ? 'Confirm  $_timeRangeLabel  →'
                    : 'Select ${_isGym ? "trainer" : "court"} & time range',
                style: TextStyle(
                  color: _canConfirm ? kBg : Colors.white38,
                  fontSize: _canConfirm ? 14 : 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dot() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 6),
    child: Container(
      width: 3,
      height: 3,
      decoration: const BoxDecoration(color: kTextSub, shape: BoxShape.circle),
    ),
  );
}

// ─── SINGLE IMAGE VIEWER (court / trainer photo) ──────────────────────────────

class _SingleImageViewer extends StatelessWidget {
  final String url;
  final String label;
  const _SingleImageViewer({required this.url, required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              minScale: 1.0,
              maxScale: 4.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white38,
                    size: 64,
                  ),
                ),
              ),
            ),
          ),
          // Top bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Hint
          const Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Pinch to zoom',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final SportBooking booking;
  const _ImageCarousel({required this.imageUrls, required this.booking});
  @override
  State<_ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<_ImageCarousel> {
  int _page = 0;
  bool _fav = false;
  late final PageController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: 10000);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_ctrl.hasClients) return;
    _ctrl.position.moveTo(_ctrl.offset - (d.primaryDelta ?? 0), clamp: false);
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_ctrl.hasClients) return;
    final v = d.primaryVelocity ?? 0;
    final c = _ctrl.page?.round() ?? 10000;
    if (v < -300) {
      _ctrl.animateToPage(
        c + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else if (v > 300)
      // ignore: curly_braces_in_flow_control_structures
      _ctrl.animateToPage(
        c - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    else
      // ignore: curly_braces_in_flow_control_structures
      _ctrl.animateToPage(
        c,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
  }

  void _openFull(BuildContext ctx) => Navigator.of(ctx).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => _FullScreenImageViewer(
        imageUrls: widget.imageUrls,
        initialIndex: _page,
      ),
      transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: SizedBox(
        height: 180,
        width: double.infinity,
        child: GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onTap: () => _openFull(context),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _ctrl,
                itemCount: null,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i % urls.length),
                itemBuilder: (_, i) => Image.network(
                  urls[i % urls.length],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => _fallback(),
                  loadingBuilder: (_, c, p) => p == null ? c : _fallback(),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xCC0A1828)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.45, 1.0],
                  ),
                ),
              ),
              if (urls.length > 1)
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      urls.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 18 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? kAccent
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              if (urls.length > 1)
                Positioned(
                  top: 10,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.photo_library_outlined,
                          color: Colors.white70,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_page + 1} / ${urls.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                right: 12,
                child: GestureDetector(
                  onTap: () => setState(() => _fav = !_fav),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _fav
                          ? kAccent.withValues(alpha: 0.85)
                          : Colors.black.withValues(alpha: 0.4),
                      border: Border.all(
                        color: _fav ? kAccent : Colors.white24,
                      ),
                    ),
                    child: Icon(
                      _fav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fallback() => Container(
    color: const Color(0xFF0D2040),
    child: CustomPaint(painter: _GridPainter()),
  );
}

// ─── CLUB IMAGE CAROUSEL ──────────────────────────────────────────────────────

class _ClubImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final SportClub club;
  const _ClubImageCarousel({required this.imageUrls, required this.club});
  @override
  State<_ClubImageCarousel> createState() => _ClubImageCarouselState();
}

class _ClubImageCarouselState extends State<_ClubImageCarousel> {
  int _page = 0;
  late final PageController _ctrl;
  static const int _kBase = 10000;

  @override
  void initState() {
    super.initState();
    _ctrl = PageController(initialPage: _kBase);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    if (!_ctrl.hasClients) return;
    _ctrl.position.moveTo(_ctrl.offset - (d.primaryDelta ?? 0), clamp: false);
  }

  void _onDragEnd(DragEndDetails d) {
    if (!_ctrl.hasClients) return;
    final v = d.primaryVelocity ?? 0;
    final c = _ctrl.page?.round() ?? _kBase;
    if (v < -300) {
      _ctrl.animateToPage(
        c + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else if (v > 300)
      // ignore: curly_braces_in_flow_control_structures
      _ctrl.animateToPage(
        c - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    else
      // ignore: curly_braces_in_flow_control_structures
      _ctrl.animateToPage(
        c,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
  }

  void _openFull(BuildContext ctx) => Navigator.of(ctx).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => _FullScreenImageViewer(
        imageUrls: widget.imageUrls,
        initialIndex: _page,
      ),
      transitionsBuilder: (_, a, _, c) => FadeTransition(opacity: a, child: c),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: SizedBox(
        height: 150,
        width: double.infinity,
        child: GestureDetector(
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onTap: () => _openFull(context),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PageView.builder(
                controller: _ctrl,
                itemCount: null,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i % urls.length),
                itemBuilder: (_, i) => Image.network(
                  urls[i % urls.length],
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: kCardAlt),
                  loadingBuilder: (_, c, p) => p == null
                      ? c
                      : Container(
                          color: kCardAlt,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: kAccent,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Color(0xCC0A1828)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(top: 8, left: 10, child: _openCloseBadge()),
              if (urls.length > 1)
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      urls.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: i == _page ? 14 : 5,
                        height: 5,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? kAccent
                              : Colors.white.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              if (urls.length > 1)
                Positioned(
                  top: 8,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      '${_page + 1}/${urls.length}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _openCloseBadge() {
    final now = TimeOfDay.now();
    final nowM = now.hour * 60 + now.minute;
    int parse(String t) {
      try {
        final p = t.trim().split(':');
        var h = int.parse(p[0]);
        final rest = p[1].split(' ');
        final period = rest[1].toUpperCase();
        if (period == 'PM' && h != 12) h += 12;
        if (period == 'AM' && h == 12) h = 0;
        return h * 60 + int.parse(rest[0]);
      } catch (_) {
        return 0;
      }
    }

    final isOpen =
        nowM >= parse(widget.club.openTime) &&
        nowM < parse(widget.club.closeTime);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen
              ? Colors.greenAccent.withValues(alpha: 0.7)
              : Colors.redAccent.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOpen ? Colors.greenAccent : Colors.redAccent,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            isOpen ? 'Open' : 'Closed',
            style: TextStyle(
              color: isOpen ? Colors.greenAccent : Colors.redAccent,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── FULL SCREEN VIEWER ───────────────────────────────────────────────────────

class _FullScreenImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  const _FullScreenImageViewer({
    required this.imageUrls,
    required this.initialIndex,
  });
  @override
  State<_FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<_FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  late final PageController _ctrl;
  late int _current;
  late AnimationController _fadeCtrl;
  double _dragY = 0;
  static const int _kBase = 10000;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _ctrl = PageController(initialPage: _kBase + widget.initialIndex);
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _close() => _fadeCtrl.reverse().then((_) => Navigator.of(context).pop());

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    final total = urls.length;
    return FadeTransition(
      opacity: _fadeCtrl,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            GestureDetector(
              onVerticalDragUpdate: (d) =>
                  setState(() => _dragY += d.primaryDelta ?? 0),
              onVerticalDragEnd: (d) {
                if (_dragY.abs() > 100 || (d.primaryVelocity ?? 0).abs() > 800) {
                  _close();
                } else {
                  setState(() => _dragY = 0);
                }
              },
              child: Transform.translate(
                offset: Offset(0, _dragY),
                child: Opacity(
                  opacity: (1 - (_dragY.abs() / 400)).clamp(0.0, 1.0),
                  child: PageView.builder(
                    controller: _ctrl,
                    itemCount: null,
                    onPageChanged: (i) => setState(() => _current = i % total),
                    itemBuilder: (_, i) => InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Center(
                        child: Image.network(
                          urls[i % total],
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              color: Colors.white38,
                              size: 64,
                            ),
                          ),
                          loadingBuilder: (_, c, p) => p == null
                              ? c
                              : Center(
                                  child: CircularProgressIndicator(
                                    value: p.expectedTotalBytes != null
                                        ? p.cumulativeBytesLoaded /
                                              p.expectedTotalBytes!
                                        : null,
                                    color: kAccent,
                                    strokeWidth: 2,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _dragY.abs() > 30 ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black87, Colors.transparent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _close,
                            icon: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Text(
                              '${_current + 1} / $total',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            if (total > 1)
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  opacity: _dragY.abs() > 30 ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      total,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _current ? 20 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: i == _current
                              ? kAccent
                              : Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _dragY.abs() > 10 ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 150),
                child: const Center(
                  child: Text(
                    'Swipe down to close',
                    style: TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── GRID PAINTER ─────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = kAccent.withValues(alpha: 0.06)
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter _) => false;
}
