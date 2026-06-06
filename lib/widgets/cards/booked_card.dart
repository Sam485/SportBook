import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';
import 'package:sportbook/routes/app_routes.dart';

class BookedCard extends StatefulWidget {
  final SportBooking booking;
  const BookedCard({super.key, required this.booking});

  @override
  State<BookedCard> createState() => _BookedCardState();
}

class _BookedCardState extends State<BookedCard> {
  SportBooking get b => widget.booking;

  /// Returns how long until the booking starts.
  /// Returns null if the start time can't be parsed or is already past.
  Duration? _timeUntilStart() {
    try {
      final now = TimeOfDay.now();
      final parts = b.openTime.split(' '); // e.g. ['08:00', 'AM']
      final hm = parts[0].split(':');
      int hour = int.parse(hm[0]);
      final int minute = int.parse(hm[1]);
      final bool isPm = parts[1].toUpperCase() == 'PM';
      if (isPm && hour != 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      final nowMinutes = now.hour * 60 + now.minute;
      final startMinutes = hour * 60 + minute;
      final diff = startMinutes - nowMinutes;

      return diff > 0 ? Duration(minutes: diff) : null;
    } catch (_) {
      return null;
    }
  }

  // String _formatCountdown(Duration d) {
  //   final h = d.inHours;
  //   final m = d.inMinutes % 60;
  //   if (h > 0 && m > 0) return '${h}h ${m}m';
  //   if (h > 0) return '${h}h';
  //   return '${m}m';
  // }

  void _onCancel() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.kCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Booking',
          style: AppTheme.tsTitle.copyWith(fontSize: 18),
        ),
        content: Text(
          'Are you sure you want to cancel "${b.title}"?',
          style: AppTheme.tsBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep', style: AppTheme.tsAccent),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: call your cancel booking service here
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text(
              'Cancel Booking',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final countdown = _timeUntilStart();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Container(
        width: double.infinity,
        decoration: AppTheme.cardDecoration(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ownerRow(),
              const SizedBox(height: 10),
              _divider(),
              const SizedBox(height: 10),
              _bookingDetails(),
              const SizedBox(height: 10),
              _divider(),
              const SizedBox(height: 10),
              _bottomRow(countdown),
            ],
          ),
        ),
      ),
    );
  }

  // ── Owner / Club Row ───────────────────────────────────────────────────────
  Widget _ownerRow() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.bookedDetailed),
      child: Row(
        children: [
          // Avatar circle with initials
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: b.ownerColor.withOpacity(0.2),
              border: Border.all(color: b.ownerColor, width: 2),
            ),
            alignment: Alignment.center,
            child: Text(
              b.ownerInitials,
              style: TextStyle(
                color: b.ownerColor,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking title
                Text(
                  b.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // Owner name
                Text(
                  b.ownerName,
                  style: TextStyle(color: AppTheme.kTextSub, fontSize: 13),
                ),
                const SizedBox(height: 6),
                // Open / close time
                Row(
                  children: [
                    const Icon(
                      Icons.lock_open_outlined,
                      color: AppTheme.kAccent,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      b.openTime,
                      style: const TextStyle(
                        color: AppTheme.kAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppTheme.kTextSub,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.lock_outline,
                      color: AppTheme.kTextSub,
                      size: 14,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      b.closeTime,
                      style: const TextStyle(
                        color: AppTheme.kTextSub,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Sport emoji badges
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: b.sportTypes
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: b.ownerColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        s,
                        style: TextStyle(
                          color: b.ownerColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ── Booking Details ────────────────────────────────────────────────────────
  Widget _bookingDetails() {
    return Column(
      children: [
        _detailRow(
          Icons.calendar_today_outlined,
          AppTheme.kAccent,
          'Booked on  Apr 24',
        ),
        const SizedBox(height: 8),
        _detailRow(
          Icons.timer_outlined,
          AppTheme.kAccent,
          '${b.openTime}  –  ${b.closeTime}',
        ),
        const SizedBox(height: 8),
        _detailRow(Icons.location_on_outlined, AppTheme.kTextSub, b.venue),
      ],
    );
  }

  Widget _detailRow(IconData icon, Color iconColor, String text) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: AppTheme.tsBody.copyWith(fontSize: 13)),
        ),
      ],
    );
  }

  // ── Bottom Row: countdown + cancel ─────────────────────────────────────────
  Widget _bottomRow(Duration? countdown) {
    return Row(
      children: [
        // Countdown or "In Progress"
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              //countdown != null ?
              'Upcoming',
              //: 'In Progress',
              style: AppTheme.tsBody.copyWith(fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              //countdown != null ? _formatCountdown(countdown) : '🟢 Now',
              '3h 43mn',
              style:
                  //countdown != null ?
                  AppTheme.tsLabel.copyWith(fontSize: 22),
              // const TextStyle(
              //     color: Colors.greenAccent,
              //     fontSize: 18,
              //     fontWeight: FontWeight.w800,
              //   ),
            ),
          ],
        ),
        const Spacer(),
        // Cancel button — only show if not yet started
        //if (countdown != null)
        ElevatedButton(
          onPressed: _onCancel,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent.withOpacity(0.15),
            foregroundColor: Colors.redAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
          child: const Text(
            'Cancel',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        // else
        //   Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        //     decoration: BoxDecoration(
        //       color: Colors.greenAccent.withOpacity(0.12),
        //       borderRadius: BorderRadius.circular(10),
        //       border: Border.all(color: Colors.greenAccent, width: 1),
        //     ),
        //     child: const Text(
        //       'Active',
        //       style: TextStyle(
        //         color: Colors.greenAccent,
        //         fontWeight: FontWeight.w700,
        //         fontSize: 14,
        //       ),
        //     ),
        //   ),
      ],
    );
  }

  Widget _divider() => Divider(thickness: 0.4, color: AppTheme.kTextSub);
}
