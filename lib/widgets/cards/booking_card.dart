import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../services/data_service.dart';
import '../../routes/app_routes.dart';
import '../common/image_carousel.dart';

// ─── Booking Card ─────────────────────────────────────────────────────────────
class BookingCard extends StatelessWidget {
  final SportBooking booking;
  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final unique = booking.sportTypes.toSet().toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
      child: Container(
        decoration: AppTheme.cardDecoration(radius: 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image carousel
          ImageCarousel(imageUrls: booking.imageUrls, height: 180),

          // Tappable details
          InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.bookingFlow,
              arguments: BookingTarget.fromBooking(booking),
            ),
            borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(22)),
            splashColor: AppTheme.kAccent.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Owner row
                  Row(children: [
                    _avatar(booking.ownerInitials, booking.ownerColor),
                    const SizedBox(width: 10),
                    Expanded(child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.title, style: const TextStyle(
                              color: Colors.white, fontSize: 15,
                              fontWeight: FontWeight.w800, letterSpacing: -0.2),
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          _timeRow(booking.openTime, booking.closeTime),
                        ])),
                    const Icon(Icons.keyboard_arrow_right_rounded,
                        color: AppTheme.kTextSub, size: 18),
                  ]),
                  const SizedBox(height: 12),
                  Container(height: 1, color: AppTheme.kBorder),
                  const SizedBox(height: 12),

                  // Venue
                  Row(children: [
                    const Icon(Icons.place_outlined,
                        color: AppTheme.kAccent, size: 14),
                    const SizedBox(width: 5),
                    Expanded(child: Text(booking.venue,
                        style: AppTheme.tsBody, overflow: TextOverflow.ellipsis)),
                  ]),
                  const SizedBox(height: 8),

                  // Sport tags
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(Icons.sports_outlined,
                          color: AppTheme.kAccent, size: 13),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Wrap(spacing: 6, runSpacing: 6,
                          children: unique.map((s) => _sportTag(s)).toList()),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _avatar(String initials, Color color) => Container(
    width: 38, height: 38,
    decoration: BoxDecoration(shape: BoxShape.circle,
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 1.8)),
    alignment: Alignment.center,
    child: Text(initials, style: const TextStyle(
        color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
  );

  Widget _timeRow(String open, String close) => Row(children: [
    const Icon(Icons.lock_open_outlined, color: AppTheme.kAccent, size: 12),
    const SizedBox(width: 3),
    Text(open, style: const TextStyle(color: AppTheme.kAccent,
        fontSize: 11.5, fontWeight: FontWeight.w600)),
    const SizedBox(width: 8),
    Container(width: 3, height: 3,
        decoration: const BoxDecoration(
            color: AppTheme.kTextSub, shape: BoxShape.circle)),
    const SizedBox(width: 8),
    const Icon(Icons.lock_outline, color: AppTheme.kTextSub, size: 12),
    const SizedBox(width: 3),
    Text(close, style: const TextStyle(color: AppTheme.kTextSub, fontSize: 11.5)),
  ]);

  Widget _sportTag(String s) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: AppTheme.kAccent.withOpacity(0.10),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppTheme.kAccent.withOpacity(0.35)),
    ),
    child: Text('${DataService.emojiFor(s)} $s',
        style: const TextStyle(color: AppTheme.kAccent,
            fontSize: 11, fontWeight: FontWeight.w700)),
  );
}