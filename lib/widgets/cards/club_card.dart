import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';

class ClubCard extends StatefulWidget {
  final SportClub club;
  const ClubCard({super.key, required this.club});
  @override
  State<ClubCard> createState() => _ClubCardState();
}

class _ClubCardState extends State<ClubCard> {
  int _page = 0;
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
    if (v < -300)
      _ctrl.animateToPage(
        c + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    else if (v > 300)
      _ctrl.animateToPage(
        c - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    else
      _ctrl.animateToPage(
        c,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.club;
    final urls = c.imageUrls;

    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 14),
      clipBehavior: Clip.hardEdge,
      decoration: AppTheme.cardDecoration(radius: 22),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.clubDetailed,
          arguments: BookingTarget.fromClub(c),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image carousel ──────────────────────────────────────────
            GestureDetector(
              onHorizontalDragUpdate: _onDragUpdate,
              onHorizontalDragEnd: _onDragEnd,
              behavior: HitTestBehavior.opaque,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                child: SizedBox(
                  height: 150,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Pages
                      PageView.builder(
                        controller: _ctrl,
                        itemCount: null,
                        physics: const NeverScrollableScrollPhysics(),
                        onPageChanged: (i) =>
                            setState(() => _page = i % urls.length),
                        itemBuilder: (_, i) => Image.network(
                          urls[i % urls.length],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              Container(color: AppTheme.kCardAlt),
                          loadingBuilder: (_, ch, p) => p == null
                              ? ch
                              : Container(
                                  color: AppTheme.kCardAlt,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: AppTheme.kAccent,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                      // Scrim
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

                      // Open/close badge
                      Positioned(top: 8, left: 10, child: _openCloseBadge()),

                      // Page count badge
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
                              color: Colors.black.withOpacity(0.5),
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

                      // Dot indicators
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                width: i == _page ? 14 : 5,
                                height: 5,
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
                    ],
                  ),
                ),
              ),
            ),

            // ── Details ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name + hours
                  Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.color.withOpacity(0.2),
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
                                  color: AppTheme.kAccent,
                                  size: 11,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  c.openTime,
                                  style: const TextStyle(
                                    color: AppTheme.kAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 3,
                                  height: 3,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.kTextSub,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.lock_outline,
                                  color: AppTheme.kTextSub,
                                  size: 11,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  c.closeTime,
                                  style: const TextStyle(
                                    color: AppTheme.kTextSub,
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
                  Container(height: 1, color: AppTheme.kBorder),
                  const SizedBox(height: 6),

                  // Venue
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        color: AppTheme.kAccent,
                        size: 12,
                      ),
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

                  // Distance + Book button
                  Row(
                    children: [
                      const Icon(
                        Icons.route_outlined,
                        color: AppTheme.kAccent,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${c.distanceKm} km away',
                        style: const TextStyle(
                          color: AppTheme.kTextSub,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.bookingFlow,
                          arguments: BookingTarget.fromClub(c),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.kAccent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.kAccent.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(
                              color: Color(0xFF0A1828),
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
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOpen
              ? Colors.greenAccent.withOpacity(0.7)
              : Colors.redAccent.withOpacity(0.7),
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
