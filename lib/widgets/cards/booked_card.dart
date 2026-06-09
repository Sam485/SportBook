import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  void _onCancel() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Booking',
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Are you sure you want to cancel "${b.title}"?',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Keep',
              style: TextStyle(
                color: AppTheme.kAccent,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.bookedDetailed, arguments: b),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Container(
          width: double.infinity,
          decoration: AppTheme.cardDecorationAdaptive(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _ownerImage(),
                const SizedBox(width: 10),
                _bookingBody(isDark),
                const SizedBox(width: 10),
                _qrButton(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _ownerImage() {
    return Container(
      width: 100,
      height: 50 * (MediaQuery.of(context).size.height / 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: b.ownerColor.withOpacity(0.2),
        border: Border.all(color: b.ownerColor, width: 2),
        borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _bookingBody(bool isDark) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking title
          Text(
            b.title,
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          _badget(b.sportTypes[0], b.ownerColor),
          const SizedBox(height: 6),
          // Open / close time
          _detailRow(
            Icons.calendar_today_outlined,
            AppTheme.kAccent,
            'Booked on  Apr 24',
            isDark,
          ),
          const SizedBox(height: 8),
          _detailRow(
            Icons.timer_outlined,
            AppTheme.kAccent,
            '${b.openTime}  –  ${b.closeTime}',
            isDark,
          ),
          const SizedBox(height: 8),
          _detailRow(
            Icons.location_on_outlined,
            isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            b.venue,
            isDark,
          ),
          const SizedBox(height: 8),
          _badget('\$ 12.00', AppTheme.kAccent),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, Color iconColor, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _badget(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _qrButton(bool isDark) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Icon(
            Icons.qr_code,
            color: isDark ? AppTheme.kAccent : AppTheme.kLightText,
          ),
        ),
      ),
    );
  }
}
