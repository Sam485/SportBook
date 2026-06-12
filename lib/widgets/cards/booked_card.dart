import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/models/models.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/translations/app_translations.dart';

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
          'cancel_booking'.tr(context),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'cancel_booking_confirmation'
              .tr(context)
              .replaceAll('{title}', b.title),
          style: TextStyle(
            color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'keep'.tr(context),
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
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('booking_cancelled'.tr(context))),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: Text(
              'cancel_booking'.tr(context),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showQrDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.kAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.qr_code,
                      color: AppTheme.kAccent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'entry_pass'.tr(context),
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.kLightText,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppTheme.kCardAlt
                            : AppTheme.kLightCardAlt,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // QR Code
              Container(
                width: 200,
                height: 200,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: QrImageView(
                  data:
                      'BOOKING:${b.id}\nTITLE:${b.title}\nVENUE:${b.venue}\nDATE:${b.formattedBookingDate}',
                  version: QrVersions.auto,
                  size: 168,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // Booking Details
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      b.title,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.kLightText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      b.venue,
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${b.formattedBookingDate} • ${b.openTime} - ${b.closeTime}',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.kAccent
                            : AppTheme.kLightTextSub,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Instruction
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.kAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: AppTheme.kAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'qr_instruction'.tr(context),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : AppTheme.kLightTextSub,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.kAccent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'close'.tr(context),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
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
          // Booked date
          _detailRow(
            Icons.calendar_today_outlined,
            AppTheme.kAccent,
            '${'booked_on'.tr(context)} ${_formatBookingDate()}',
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

  String _formatBookingDate() {
    // You can format the date properly here
    // For now using a sample date
    return 'Apr 24';
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
      onTap: _showQrDialog,
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
            size: 24,
          ),
        ),
      ),
    );
  }
}
