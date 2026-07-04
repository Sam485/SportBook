import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/service/booking_service.dart';
import 'package:sportbook/translations/app_translations.dart';

class BookedDetailed extends StatefulWidget {
  final BookingModel booking;

  const BookedDetailed({super.key, required this.booking});

  @override
  State<BookedDetailed> createState() => _BookedDetailedState();
}

class _BookedDetailedState extends State<BookedDetailed> {
  final BookingService _bookingService = getIt<BookingService>();
  bool _isCancelling = false;
  BookingModel? _currentBooking;

  // Computed properties - use _currentBooking if available, otherwise widget.booking
  BookingModel get b => _currentBooking ?? widget.booking;

  String get _bookingId => '#BK-${b.id.toString().padLeft(6, '0')}';
  String get _formattedDate => _formatDate(b.bookingDate);
  String get _timeRange => '${b.startTime} - ${b.endTime}';
  String get _status => b.status;
  String get _paymentStatus => b.paymentStatus;
  double get _totalAmount => b.totalAmount.toDouble();

  bool get _isCancellable =>
      _status.toLowerCase() == 'pending' ||
      _status.toLowerCase() == 'confirmed';

  Color get _statusColor {
    switch (_status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color get _clubColor {
    final colors = [
      const Color(0xFFE74C3C),
      const Color(0xFF2ECC71),
      const Color(0xFFF39C12),
      const Color(0xFF9B59B6),
      const Color(0xFF1ABC9C),
      const Color(0xFF3498DB),
      const Color(0xFFE67E22),
      const Color(0xFF2C3E50),
      const Color(0xFF16A085),
      const Color(0xFF8E44AD),
    ];
    return colors[b.sportClub.id % colors.length];
  }

  String _formatDate(DateTime date) {
    final months = [
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final months = [
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
    final day = date.day;
    final month = months[date.month - 1];
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$month $day, $year at $hour:$minute';
  }

  Future<void> _refreshBooking() async {
    try {
      final updatedBooking = await _bookingService.getBookingById(b.id);
      if (mounted) {
        setState(() {
          _currentBooking = updatedBooking;
        });
      }
      // ignore: empty_catches
    } catch (e) {}
  }

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
            if (_isCancellable) SliverToBoxAdapter(child: _buttons(context)),
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
    final color = _clubColor;
    final hasImage = b.slot.imageUrl.isNotEmpty;

    return Stack(
      children: [
        // Background Image Container
        Container(
          height: 320,
          width: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: hasImage
                  ? NetworkImage(b.slot.imageUrl) as ImageProvider
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
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                  Colors.black.withValues(alpha: 0.9),
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
            onTap: () => Navigator.pop(context, true),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(12),
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
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                Icons.share_outlined,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                _shareBooking(context);
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
                // Status Badges
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _status.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        b.slot.name.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _paymentStatus.toLowerCase() == 'paid'
                            ? Colors.green.withValues(alpha: 0.9)
                            : Colors.orange.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _paymentStatus.toUpperCase(),
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  b.slot.name,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  b.sportClub.name,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
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
                        b.sportClub.location,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
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
                      _formattedDate,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
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
                      _timeRange,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Booking ID
                Row(
                  children: [
                    const Icon(Icons.tag, color: Colors.white70, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      _bookingId,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
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
    final slotPrice = b.slot.price;
    final total = _totalAmount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'payment_summary'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
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
                  'slot_booking'.tr(context),
                  '\$${slotPrice.toStringAsFixed(2)}',
                  false,
                ),
                _divider(context),
                _buildPaymentRow(
                  context,
                  'service_fee'.tr(context),
                  '\$0.00',
                  false,
                ),
                _divider(context),
                _buildPaymentRow(
                  context,
                  'total'.tr(context),
                  '\$${total.toStringAsFixed(2)}',
                  true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bookingDetailed(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final payment = b.payment;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'booking_details'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
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
                  _bookingId,
                  false,
                ),
                _divider(context),
                _buildPaymentRow(
                  context,
                  'status'.tr(context),
                  _buildStatusBadge(_status, _statusColor),
                  false,
                ),
                _divider(context),
                _buildPaymentRow(
                  context,
                  'payment_status'.tr(context),
                  _buildStatusBadge(
                    _paymentStatus,
                    _paymentStatus.toLowerCase() == 'paid'
                        ? Colors.green
                        : Colors.orange,
                  ),
                  false,
                ),
                if (payment != null) ...[
                  _divider(context),
                  _buildPaymentRow(
                    context,
                    'payment_method'.tr(context),
                    payment.method.toUpperCase(),
                    false,
                  ),
                  _divider(context),
                  _buildPaymentRow(
                    context,
                    'transaction_ref'.tr(context),
                    payment.transactionRef,
                    false,
                  ),
                ],
                _divider(context),
                _buildPaymentRow(
                  context,
                  'booked_on'.tr(context),
                  _formatDateTime(b.createdAt),
                  false,
                ),
                if (b.note.isNotEmpty) ...[
                  _divider(context),
                  _buildPaymentRow(context, 'note'.tr(context), b.note, false),
                ],
                if (b.cancelledAt != null) ...[
                  _divider(context),
                  _buildPaymentRow(
                    context,
                    'cancelled_at'.tr(context),
                    _formatDateTime(b.cancelledAt!),
                    false,
                  ),
                ],
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
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
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
              fontFamily: AppTheme.fontFamily,
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
              fontFamily: AppTheme.fontFamily,
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
                    data: _buildQrData(),
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
                          fontFamily: AppTheme.fontFamily,
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
                          fontFamily: AppTheme.fontFamily,
                          color: isDark
                              ? Colors.white70
                              : AppTheme.kLightTextSub,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _badge(context, _bookingId, AppTheme.kAccent),
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

  String _buildQrData() {
    return 'BOOKING:${b.id}\n'
        'SLOT:${b.slot.name}\n'
        'CLUB:${b.sportClub.name}\n'
        'DATE:$_formattedDate\n'
        'TIME:$_timeRange\n'
        'TOTAL:\$${_totalAmount.toStringAsFixed(2)}';
  }

  Widget _badge(BuildContext context, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
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
              fontFamily: AppTheme.fontFamily,
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
              color: color.withValues(alpha: 0.2),
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
                    fontFamily: AppTheme.fontFamily,
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
                    fontFamily: AppTheme.fontFamily,
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
                    fontFamily: AppTheme.fontFamily,
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  )
                : TextStyle(
                    fontFamily: AppTheme.fontFamily,
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
                          fontFamily: AppTheme.fontFamily,
                          color: AppTheme.kAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        )
                      : TextStyle(
                          fontFamily: AppTheme.fontFamily,
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
              onPressed: _isCancelling
                  ? null
                  : () => _showCancelDialog(context),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
              ),
              child: _isCancelling
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    )
                  : Text('cancel_booking'.tr(context)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'reschedule_coming_soon'.tr(context),
                      style: const TextStyle(fontFamily: AppTheme.fontFamily),
                    ),
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
                textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
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
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
          ),
        ),
        content: Text(
          'cancel_booking_confirmation'
              .tr(context)
              .replaceAll('{title}', b.slot.name),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'no_keep_it'.tr(context),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _cancelBooking(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            child: Text('yes_cancel'.tr(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(BuildContext context) async {
    if (_isCancelling) return;

    setState(() {
      _isCancelling = true;
    });

    try {
      await _bookingService.cancelBooking(b.id);

      if (mounted) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context);

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking cancelled successfully',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        await _refreshBooking();

        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            // ignore: use_build_context_synchronously
            Navigator.pop(context, true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        if (Navigator.canPop(context)) {
          // ignore: use_build_context_synchronously
          Navigator.pop(context);
        }

        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to cancel booking: ${e.toString()}',
              style: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );

        setState(() {
          _isCancelling = false;
        });
      }
    }
  }

  void _shareBooking(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'share_coming_soon'.tr(context),
          style: const TextStyle(fontFamily: AppTheme.fontFamily),
        ),
      ),
    );
  }
}
