import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/models/models.dart';

class BookedDetailed extends StatelessWidget {
  final SportBooking booking;

  const BookedDetailed({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.kBg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _header(context)),
            SliverToBoxAdapter(child: _paymentSummary()),
            SliverToBoxAdapter(child: _bookingDetailed()),
            SliverToBoxAdapter(child: _policy()),
            SliverToBoxAdapter(child: _entryPass()),
            SliverToBoxAdapter(child: _buttons(context)),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _divider() {
    return const Divider(color: AppTheme.kBorder, thickness: 0.5, height: 16);
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
              child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
            ),
          ),
        ),

        // Share/Options Button (optional)
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
                // Share booking details
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Share feature coming soon')),
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
                          'Hosted by ${booking.ownerName ?? "Organizer"}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Response rate: 98%',
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

  Widget _paymentSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Payment Summary', style: AppTheme.tsTitle),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: AppTheme.cardDecoration(),
            child: Column(
              children: [
                _buildPaymentRow('Field Booking', '\$15.00'),
                _divider(),
                _buildPaymentRow('Service Fee', '\$2.50'),
                _divider(),
                _buildPaymentRow('Total', '\$17.50', isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingDetailed() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Booking details', style: AppTheme.tsTitle),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: AppTheme.cardDecoration(),
            child: Column(
              children: [
                _buildPaymentRow('Booking ID', '#SPB-20482'),
                _divider(),
                _buildPaymentRow(
                  'Status',
                  _buildStatusBadge('Confirmed', Colors.green),
                ),
                _divider(),
                _buildPaymentRow('Payment method', 'ABA'),
                _divider(),
                _buildPaymentRow('Booked on', 'Jun 4, 2026'),
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

  Widget _policy() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Cancellation policy', style: AppTheme.tsTitle),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: AppTheme.cardDecoration(),
            child: Column(
              children: [
                _buildPolicyRow(
                  Icons.check_circle,
                  Colors.green,
                  'Free cancellation',
                  'Cancel up to 24 hrs before your slots for a full refund.',
                ),
                _divider(),
                _buildPolicyRow(
                  Icons.warning_amber,
                  Colors.orange,
                  'Late cancellation',
                  'Within 24 hrs - 50% of booking cost is charged.',
                ),
                _divider(),
                _buildPolicyRow(
                  Icons.cancel,
                  Colors.red,
                  'No-show',
                  'Full charge applies. Contact support if you have an emergency.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryPass() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Entry pass', style: AppTheme.tsTitle),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: AppTheme.cardDecoration(),
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
                      Text('Scan at the gate', style: AppTheme.tsTitle),
                      const SizedBox(height: 8),
                      Text(
                        'Show this QR code to the staff on arrival. Valid only for your booked slot on Jun 7, 2026',
                        style: AppTheme.tsBody,
                      ),
                      const SizedBox(height: 8),
                      _badge(
                        'Expires in 3 days',
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

  Widget _badge(String text, Color color) {
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
            style: AppTheme.tsTitle.copyWith(
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
    IconData icon,
    Color color,
    String title,
    String description,
  ) {
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
                Text(title, style: AppTheme.tsTitle),
                const SizedBox(height: 4),
                Text(description, style: AppTheme.tsBody, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, dynamic value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(
            label,
            style: isTotal
                ? const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  )
                : AppTheme.tsLabel,
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
                      : AppTheme.tsLabel,
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
              child: const Text('Cancel Booking'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Navigate to reschedule screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reschedule feature coming soon'),
                  ),
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
              child: const Text('Reschedule'),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.kCard,
        title: const Text(
          'Cancel Booking?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to cancel this booking? '
          'Cancellation fees may apply.',
          style: TextStyle(color: AppTheme.kTextSub),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'No, Keep It',
              style: TextStyle(color: AppTheme.kTextSub),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle cancellation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Booking cancelled')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
