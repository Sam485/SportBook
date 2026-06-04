import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';
import 'package:sportbook/providers/booking_provider.dart';
import 'package:sportbook/screens/booking_flow/booking_flow_screen.dart';
import 'package:sportbook/services/data_service.dart';
import 'package:sportbook/widgets/cards/booking_card.dart';

class ClubDetailed extends StatefulWidget {
  final BookingTarget target;
  const ClubDetailed({super.key, required this.target});

  @override
  State<ClubDetailed> createState() => _ClubDetailedState();
}

class _ClubDetailedState extends State<ClubDetailed> {
  int _page = 0;
  bool _saved = false;

  // ── Open/close helper ──────────────────────────────────────────────────────
  bool get _isOpen {
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

    return nowM >= parse(widget.target.openTime) &&
        nowM < parse(widget.target.closeTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBg,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _header()),
                SliverToBoxAdapter(child: _infoSection()),
                SliverToBoxAdapter(child: _divider('Facilities')),
                SliverToBoxAdapter(child: _facilities()),
                SliverToBoxAdapter(child: _divider('Sports Available')),
                SliverToBoxAdapter(child: _sportsGrid()),
                SliverToBoxAdapter(child: _divider('Pricing')),
                SliverToBoxAdapter(child: _pricing()),
                SliverToBoxAdapter(child: _divider('Location')),
                SliverToBoxAdapter(child: _location()),
                SliverToBoxAdapter(child: _divider('About')),
                SliverToBoxAdapter(child: _about()),
                SliverToBoxAdapter(child: _divider('You Might Also Like')),
                SliverToBoxAdapter(child: _suggestions()),
                // Bottom padding so content clears the nav bar
                const SliverToBoxAdapter(child: SizedBox(height: 80)),
              ],
            ),
            _bottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Header carousel ────────────────────────────────────────────────────────
  Widget _header() => SizedBox(
    height: 260,
    width: double.infinity,
    child: Stack(
      children: [
        if (widget.target.imageUrls.length > 1)
          CarouselSlider(
            options: CarouselOptions(
              height: 260,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayAnimationDuration: const Duration(milliseconds: 800),
              autoPlayCurve: Curves.fastOutSlowIn,
              viewportFraction: 1.0,
              onPageChanged: (i, _) => setState(() => _page = i),
            ),
            items: widget.target.imageUrls
                .map((url) => _netImage(url))
                .toList(),
          )
        else
          _netImage(widget.target.imageUrls.first),

        // Gradient overlay so text reads well
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, AppTheme.kBg.withOpacity(0.85)],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
        ),

        // Dot indicators
        if (widget.target.imageUrls.length > 1)
          Positioned(
            bottom: 12,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.target.imageUrls.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page
                        ? AppTheme.kAccent
                        : Colors.white.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),

        // Back button
        Positioned(
          left: 12,
          top: 10,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),

        // Save button
        Positioned(
          right: 12,
          top: 10,
          child: InkWell(
            onTap: () => setState(() => _saved = !_saved),
            borderRadius: BorderRadius.circular(30),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _saved ? Colors.redAccent : Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    ),
  );

  Widget _netImage(String url) => Image.network(
    url,
    width: double.infinity,
    height: 260,
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => Container(
      color: AppTheme.kCardAlt,
      child: const Icon(
        Icons.image_not_supported,
        color: AppTheme.kTextSub,
        size: 36,
      ),
    ),
    loadingBuilder: (_, child, p) => p == null
        ? child
        : Container(
            color: AppTheme.kCardAlt,
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.kAccent,
                strokeWidth: 2,
              ),
            ),
          ),
  );

  // ── Info section ───────────────────────────────────────────────────────────
  Widget _infoSection() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                widget.target.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _openCloseBadge(),
          ],
        ),
        const SizedBox(height: 10),

        // Hours row
        Row(
          children: [
            const Icon(
              Icons.lock_open_rounded,
              color: AppTheme.kAccent,
              size: 13,
            ),
            const SizedBox(width: 4),
            Text(widget.target.openTime, style: AppTheme.tsAccent),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                '–',
                style: TextStyle(color: Colors.white.withOpacity(0.4)),
              ),
            ),
            const Icon(Icons.lock_rounded, color: AppTheme.kTextSub, size: 13),
            const SizedBox(width: 4),
            Text(
              widget.target.closeTime,
              style: AppTheme.tsAccent.copyWith(color: AppTheme.kTextSub),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Stats row (courts, rating, price)
        Row(
          children: [
            _statPill(
              Icons.grid_view_rounded,
              '${widget.target.sports.length} Courts',
              AppTheme.kAccent,
            ),
            const SizedBox(width: 8),
            _statPill(Icons.star_rounded, '4.8', const Color(0xFFF59E0B)),
            const SizedBox(width: 8),
            _statPill(
              Icons.attach_money_rounded,
              '\$${widget.target.pricePerHour.toStringAsFixed(0)}/hr',
              const Color(0xFF4CAF50),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _statPill(IconData icon, String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 13),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  // ── Section divider ────────────────────────────────────────────────────────
  Widget _divider(String title) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
    child: Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: AppTheme.kAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Divider(color: AppTheme.kBorder, thickness: 1)),
      ],
    ),
  );

  // ── Facilities ─────────────────────────────────────────────────────────────
  Widget _facilities() {
    final items = [
      (Icons.local_parking_rounded, 'Parking'),
      (Icons.shower_rounded, 'Showers'),
      (Icons.emoji_food_beverage_rounded, 'Café'),
      (Icons.wifi_rounded, 'Free Wi-Fi'),
      (Icons.ac_unit_rounded, 'Air-Con'),
      (Icons.sports_rounded, 'Equipment'),
      (Icons.wc_rounded, 'Restrooms'),
      (Icons.medical_services_rounded, 'First Aid'),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: items.map((f) => _facilityChip(f.$1, f.$2)).toList(),
      ),
    );
  }

  Widget _facilityChip(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      color: AppTheme.kCardAlt,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.kBorder),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppTheme.kAccent, size: 14),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  // ── Sports grid ────────────────────────────────────────────────────────────
  Widget _sportsGrid() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.target.sports
          .map(
            (s) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.kAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.kAccent.withOpacity(0.35)),
              ),
              child: Text(
                '${DataService.emojiFor(s)} $s',
                style: const TextStyle(
                  color: AppTheme.kAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
          .toList(),
    ),
  );

  // ── Pricing ────────────────────────────────────────────────────────────────
  Widget _pricing() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.kCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.kBorder),
      ),
      child: Column(
        children: [
          _priceRow(
            'Peak Hours (6–9 AM, 5–9 PM)',
            '\$${(widget.target.pricePerHour * 1.25).toStringAsFixed(0)}/hr',
            const Color(0xFFF59E0B),
          ),
          const Divider(color: Color(0xFF2A2A3A), height: 20),
          _priceRow(
            'Off-Peak Hours',
            '\$${widget.target.pricePerHour.toStringAsFixed(0)}/hr',
            const Color(0xFF4CAF50),
          ),
          const Divider(color: Color(0xFF2A2A3A), height: 20),
          _priceRow(
            'Weekend Surcharge',
            '+\$${(widget.target.pricePerHour * 0.2).toStringAsFixed(0)}/hr',
            Colors.redAccent,
          ),
        ],
      ),
    ),
  );

  Widget _priceRow(String label, String value, Color color) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12.5),
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );

  // ── Location ───────────────────────────────────────────────────────────────
  Widget _location() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.kCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.place_rounded,
                color: AppTheme.kAccent,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.target.venue,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Map placeholder
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 130,
              color: const Color(0xFF1A1A2E),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Fake map grid lines
                  CustomPaint(
                    painter: _MapGridPainter(),
                    size: const Size(double.infinity, 130),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.kAccent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.kAccent.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.location_on_rounded,
                          color: Colors.black,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'View on Map',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
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

  // ── About ──────────────────────────────────────────────────────────────────
  Widget _about() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.kCardAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.kBorder),
      ),
      child: Text(
        '${widget.target.name} is a premium sports facility offering world-class courts '
        'and amenities for athletes of all levels. Whether you\'re a casual player or a '
        'competitive athlete, our professional-grade facilities and expert staff ensure '
        'an exceptional experience every visit.\n\n'
        'We pride ourselves on maintaining top-tier court surfaces, state-of-the-art '
        'equipment, and a welcoming community atmosphere.',
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 13,
          height: 1.65,
        ),
      ),
    ),
  );

  // ── Suggestions ────────────────────────────────────────────────────────────
  Widget _suggestions() {
    // Show other clubs that share at least one sport, excluding the current one.
    // Fall back to any other club if no sport overlap found.
    final currentId = widget.target.id;
    final currentSports = widget.target.sports.toSet();

    var suggestions = DataService.clubs
        .where(
          (c) =>
              c.id != currentId &&
              c.sports.any((s) => currentSports.contains(s)),
        )
        .take(3)
        .toList();

    // Fallback: just show other clubs
    if (suggestions.isEmpty) {
      suggestions = DataService.clubs
          .where((c) => c.id != currentId)
          .take(3)
          .toList();
    }

    if (suggestions.isEmpty) return const SizedBox.shrink();

    // SportClub → SportBooking adapter so BookingCard can render it
    SportBooking clubToBooking(SportClub c) => SportBooking(
      id: c.id,
      title: c.name,
      ownerName: c.name,
      ownerInitials: c.initials,
      ownerColor: c.color,
      sportTypes: c.sports,
      venue: c.venue,
      imageUrls: c.imageUrls,
      openTime: c.openTime,
      closeTime: c.closeTime,
      bookedSlots: 0,
      totalSlots: c.totalCourts,
    );

    return Column(
      children: suggestions
          .map((c) => BookingCard(booking: clubToBooking(c)))
          .toList(),
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────
  Widget _bottomNav() => Positioned(
    bottom: 0,
    left: 0,
    right: 0,
    child: Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: BoxDecoration(
        color: AppTheme.kBg.withOpacity(0.95),
        border: Border(top: BorderSide(color: AppTheme.kBorder, width: 1)),
      ),
      child: Row(
        children: [
          // Chat icon
          _navIconBtn(
            icon: Icons.chat_bubble_outline_rounded,
            label: 'Chat',
            onTap: () {},
          ),
          const SizedBox(width: 10),
          // Save icon
          _navIconBtn(
            icon: _saved
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            label: _saved ? 'Saved' : 'Save',
            color: _saved ? Colors.redAccent : null,
            onTap: () => setState(() => _saved = !_saved),
          ),
          const SizedBox(width: 14),
          // Book Now
          Expanded(
            child: ElevatedButton(
              onPressed: () => _showBookingSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _navIconBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) => GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color ?? Colors.white70, size: 22),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color ?? Colors.white54,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  // ── Open/close badge ───────────────────────────────────────────────────────
  Widget _openCloseBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.black.withOpacity(0.45),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: _isOpen
            ? Colors.greenAccent.withOpacity(0.7)
            : Colors.redAccent.withOpacity(0.7),
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _isOpen ? Colors.greenAccent : Colors.redAccent,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _isOpen ? 'Open Now' : 'Closed',
          style: TextStyle(
            color: _isOpen ? Colors.greenAccent : Colors.redAccent,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );

  // ── Booking bottom sheet ───────────────────────────────────────────────────
  void _showBookingSheet(BuildContext context) {
    // Set the target on the provider before showing the sheet
    context.read<BookingProvider>().setTarget(widget.target);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.92,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppTheme.kBg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(color: AppTheme.kBorder),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: [
                    const Text(
                      'Book Court',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.kCardAlt,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.kBorder),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white60,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0xFF2A2A3A), height: 1),
              // The booking flow
              Expanded(child: BookingFlowScreen(target: widget.target)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Map grid painter (decorative placeholder) ─────────────────────────────────
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2A2A3A)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // A few "road" lines
    final road = Paint()
      ..color = const Color(0xFF3A3A4A)
      ..strokeWidth = 5;
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.4),
      road,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, 0),
      Offset(size.width * 0.35, size.height),
      road,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
