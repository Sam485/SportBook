import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';
import 'package:sportbook/translations/app_translations.dart';

class BookedDetailed extends StatelessWidget {
  final SportBooking booking;

  const BookedDetailed({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            SliverToBoxAdapter(child: _paymentSummary(context)),
            SliverToBoxAdapter(child: _bookingDetailed(context)),
            SliverToBoxAdapter(child: _policy(context)),
            SliverToBoxAdapter(child: _entryPass(context)),
            SliverToBoxAdapter(child: _buttons(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Divider(
      color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
      thickness: 0.5,
      height: 16,
    );
  }

  Widget _header(BuildContext context) {
    return Stack(
      children: [
        // Background Image Container
        Container(
          height: 320,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: booking.imageUrls.isNotEmpty
                  ? NetworkImage(booking.imageUrls.first) as ImageProvider
                  : const AssetImage('assets/images/default_club.jpg'),
              fit: BoxFit.cover,
            ),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(24),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.3),
                  Colors.black.withOpacity(0.7),
                  Colors.black.withOpacity(0.9),
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
        ),

        // Back Button
        Positioned(
          top: 16,
          left: 16,
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.fromLTRB(15, 10, 10, 10),
              child: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),

        // Share/Options Button
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('share_coming_soon'.tr(context))),
                );
              },
              padding: const EdgeInsets.all(8),
            ),
          ),
        ),

        // Card Info at Bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sport Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: booking.ownerColor.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.sportTypes.first.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  booking.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Venue
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        booking.venue,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Date and Time
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.formattedBookingDate,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.access_time,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      booking.formattedTimeRange,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Owner Info
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: booking.ownerColor.withOpacity(0.3),
                        border: Border.all(color: booking.ownerColor, width: 1),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        booking.ownerInitials,
                        style: TextStyle(
                          color: booking.ownerColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'hosted_by'
                              .tr(context)
                              .replaceAll('{name}', booking.ownerName),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'response_rate'.tr(context),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _paymentSummary(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment_summary'.tr(context),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: AppTheme.cardDecorationAdaptive(context),
            child: Column(
              children: [
                _buildPaymentRow(
                  context,
                  'field_booking'.tr(context),
                  '\$15.00',
                  false,
                ),
                _divider(context),
                _buildPaymentRow(
                  context,
                  'service_fee'.tr(context),
                  '\$2.50',
                  false,
                ),
                _divider(context),
                _buildPaymentRow(context, 'total'.tr(context), '\$17.50', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingDetailed(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'booking_details'.tr(context),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: AppTheme.cardDecorationAdaptive(context),
            child: Column(
              children: [
                _buildPaymentRow(
                  context,
                  'booking_id'.tr(context),
                  '#SPB-20482',
                  false,
                ),
                _divider(context),
                _buildPaymentRow(
                  context,
                  'status'.tr(context),
                  _buildStatusBadge('confirmed'.tr(context), Colors.green),
                  false,
                ),
                _divider(context),
                _buildPaymentRow(
                  context,
                  'payment_method'.tr(context),
                  'ABA',
                  false,
                ),
                _divider(context),
                _buildPaymentRow(
                  context,
                  'booked_on_date'.tr(context),
                  'Jun 4, 2026',
                  false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _policy(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'cancellation_policy'.tr(context),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: AppTheme.cardDecorationAdaptive(context),
            child: Column(
              children: [
                _buildPolicyRow(
                  context,
                  Icons.check_circle,
                  Colors.green,
                  'free_cancellation'.tr(context),
                  'free_cancellation_desc'.tr(context),
                ),
                _divider(context),
                _buildPolicyRow(
                  context,
                  Icons.warning_amber,
                  Colors.orange,
                  'late_cancellation'.tr(context),
                  'late_cancellation_desc'.tr(context),
                ),
                _divider(context),
                _buildPolicyRow(
                  context,
                  Icons.cancel,
                  Colors.red,
                  'no_show'.tr(context),
                  'no_show_desc'.tr(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryPass(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'entry_pass'.tr(context),
            style: TextStyle(
              color: isDark ? Colors.white : AppTheme.kLightText,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: AppTheme.cardDecorationAdaptive(context),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: QrImageView(
                    data: '#SPB-20482',
                    version: QrVersions.auto,
                    size: 100.0,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'scan_at_gate'.tr(context),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.kLightText,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'qr_instruction_detailed'.tr(context),
                        style: TextStyle(
                          color: isDark
                              ? Colors.white70
                              : AppTheme.kLightTextSub,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _badge(
                        context,
                        'expires_in_days'.tr(context),
                        const Color.fromARGB(255, 255, 193, 7),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 6, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicyRow(
    BuildContext context,
    IconData icon,
    Color color,
    String title,
    String description,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                    fontSize: 13,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(
    BuildContext context,
    String label,
    dynamic value,
    bool isTotal,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: isTotal
                ? TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )
                : TextStyle(
                    color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                    fontSize: 14,
                  ),
          ),
          const Spacer(),
          value is Widget
              ? value
              : Text(
                  value.toString(),
                  style: isTotal
                      ? const TextStyle(
                          color: AppTheme.kAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      : TextStyle(
                          color: isDark
                              ? Colors.white70
                              : AppTheme.kLightTextSub,
                          fontSize: 14,
                        ),
                ),
        ],
      ),
    );
  }

  Widget _buttons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                _showCancelDialog(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('cancel_booking'.tr(context)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('reschedule_coming_soon'.tr(context))),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('reschedule'.tr(context)),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        title: Text(
          'cancel_booking'.tr(context),
          style: TextStyle(color: isDark ? Colors.white : AppTheme.kLightText),
        ),
        content: Text(
          'cancel_booking_warning'.tr(context),
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'no_keep_it'.tr(context),
              style: TextStyle(
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('yes_cancel'.tr(context)),
          ),
        ],
      ),
    );
  }
}
