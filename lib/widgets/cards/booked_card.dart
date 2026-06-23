import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Booking/model/booking_model.dart';
import 'package:sportbook/feature/Booking/service/booking_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/translations/app_translations.dart';

class BookedCard extends StatefulWidget {
  final BookingModel booking;
  const BookedCard({super.key, required this.booking});

  @override
  State<BookedCard> createState() => _BookedCardState();
}

class _BookedCardState extends State<BookedCard> {
  final BookingService _bookingService = getIt<BookingService>();
  bool _isCancelling = false;

  BookingModel get b => widget.booking;

  // Computed properties
  String get _bookingId => '#BK-${b.id.toString().padLeft(6, '0')}';
  String get _formattedDate => _formatDate(b.bookingDate);
  String get _timeRange => '${b.startTime} - ${b.endTime}';
  String get _status => b.status;
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

  String get _initials {
    final parts = b.sportClub.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return b.sportClub.name.isNotEmpty
        ? b.sportClub.name[0].toUpperCase()
        : '?';
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

  void _onCancel() async {
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
              .replaceAll('{title}', b.slot.name),
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
            onPressed: () async {
              Navigator.pop(context);
              setState(() {
                _isCancelling = true;
              });

              try {
                await _bookingService.cancelBooking(b.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Booking cancelled successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to cancel booking: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() {
                    _isCancelling = false;
                  });
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            child: _isCancelling
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
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
                  data: _buildQrData(),
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
                      b.slot.name,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.kLightText,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      b.sportClub.name,
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
                      '$_formattedDate • $_timeRange',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.kAccent
                            : AppTheme.kLightTextSub,
                        fontSize: 11,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _bookingId,
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.kTextSub
                            : AppTheme.kLightTextSub,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
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

  String _buildQrData() {
    return 'BOOKING:${b.id}\n'
        'SLOT:${b.slot.name}\n'
        'CLUB:${b.sportClub.name}\n'
        'DATE:$_formattedDate\n'
        'TIME:$_timeRange';
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
                _clubImage(),
                const SizedBox(width: 10),
                _bookingBody(isDark),
                const SizedBox(width: 10),
                _actionButtons(isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _clubImage() {
    final color = _clubColor;
    final hasImage = b.slot.imageUrl.isNotEmpty;

    return Container(
      width: 100,
      height: 50 * (MediaQuery.of(context).size.height / 300),
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        color: color.withOpacity(0.2),
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(12),
        image: hasImage
            ? DecorationImage(
                image: NetworkImage(b.slot.imageUrl),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: hasImage
          ? null
          : Text(
              _initials,
              style: TextStyle(
                color: color,
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
          // Slot name
          Row(
            children: [
              Expanded(
                child: Text(
                  b.slot.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _statusBadge(),
            ],
          ),
          const SizedBox(height: 2),
          _badge(b.sportClub.name, _clubColor),
          const SizedBox(height: 6),
          // Date and Time
          _detailRow(
            Icons.calendar_today_outlined,
            AppTheme.kAccent,
            '$_formattedDate • $_timeRange',
            isDark,
          ),
          const SizedBox(height: 4),
          _detailRow(
            Icons.location_on_outlined,
            isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            b.sportClub.location,
            isDark,
          ),
          const SizedBox(height: 6),
          _badge('\$${b.totalAmount.toStringAsFixed(2)}', AppTheme.kAccent),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _status.toUpperCase(),
        style: TextStyle(
          color: _statusColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, Color iconColor, String text, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 14),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _badge(String text, Color color) {
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
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _actionButtons(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // QR Button
        InkWell(
          onTap: _showQrDialog,
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.qr_code,
              color: isDark ? AppTheme.kAccent : AppTheme.kLightText,
              size: 22,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Cancel Button (only if cancellable)
        if (_isCancellable)
          InkWell(
            onTap: _isCancelling ? null : _onCancel,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: _isCancelling
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.red,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.cancel_outlined, color: Colors.red, size: 22),
            ),
          ),
      ],
    );
  }
}
