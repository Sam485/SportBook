import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Booking/model/create_booking_model.dart';
import 'package:sportbook/feature/Booking/service/booking_service.dart';
import 'package:sportbook/routes/app_routes.dart';
import 'package:sportbook/translations/app_translations.dart';

class PaymentSuccessPage extends StatefulWidget {
  final VoidCallback onGoHome;
  final VoidCallback onViewBooking;
  final Map<String, dynamic>? bookingData;

  const PaymentSuccessPage({
    super.key,
    required this.onGoHome,
    required this.onViewBooking,
    this.bookingData,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  final BookingService _bookingService = getIt<BookingService>();

  late AnimationController _checkController;
  late AnimationController _rippleController;
  late AnimationController _contentController;
  late AnimationController _buttonController;

  late Animation<double> _checkScale;
  late Animation<double> _checkOpacity;
  late Animation<double> _ripple1;
  late Animation<double> _ripple2;
  late Animation<double> _ripple3;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;

  // Booking data
  late String _sportName;
  late String _courtName;
  late String _date;
  late String _timeRange;
  late double _totalPrice;
  late int _slotId;
  late int _clubId;
  late DateTime _selectedDate;
  late String _startTime;
  late String _endTime;
  late String _paymentMethod;
  late String _bookingId;

  bool _isCreatingBooking = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    // Extract booking data
    final data = widget.bookingData ?? {};
    _sportName = data['category'] ?? '—';
    _courtName = data['courtName'] ?? '—';
    _totalPrice = (data['totalPrice'] ?? 0.0).toDouble();
    _slotId = data['court'] ?? 0;
    _clubId = (data['club'] as dynamic)?.id ?? 0;
    _paymentMethod = data['paymentMethod'] ?? 'qr_code';

    // Get date
    final date = data['date'] as DateTime?;
    if (date != null) {
      _selectedDate = date;
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
      final weekdays = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday',
      ];
      _date =
          '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}';
    } else {
      _selectedDate = DateTime.now();
      _date = '—';
    }

    // Get time - use the String format from bookingData (already in 24-hour format)
    _startTime = data['startTime'] as String? ?? '00:00';
    _endTime = data['endTime'] as String? ?? '00:00';

    // Format time range for display (convert to 12-hour for display)
    _timeRange =
        '${_formatTimeForDisplay(_startTime)} – ${_formatTimeForDisplay(_endTime)}';

    _bookingId = _generateId();

    // Setup animations
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.25,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.25,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_checkController);
    _checkOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _checkController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _ripple1 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _ripple2 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOut),
      ),
    );
    _ripple3 = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _rippleController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
        );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _buttonFade = CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOut,
    );
    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _buttonController, curve: Curves.easeOut),
        );

    // Start animations
    _checkController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _rippleController.forward();
    });
    Future.delayed(const Duration(milliseconds: 450), () {
      if (mounted) _contentController.forward();
    });
    Future.delayed(const Duration(milliseconds: 650), () {
      if (mounted) _buttonController.forward();
    });

    // Create the booking after animations start
    _createBooking();
  }

  @override
  void dispose() {
    _checkController.dispose();
    _rippleController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  String _formatTimeForDisplay(String time24) {
    try {
      final parts = time24.split(':');
      int hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour % 12 == 0 ? 12 : hour % 12;
      return '$hour12:$minute $period';
    } catch (_) {
      return time24;
    }
  }

  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _generateId() {
    final now = DateTime.now();
    return '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(7)}';
  }

  // ============================================================
  // _createBooking() method
  // ============================================================
  Future<void> _createBooking() async {
    // Check if already creating or widget is unmounted
    if (_isCreatingBooking || !mounted) return;

    // Validate slot ID
    if (_slotId == 0) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Invalid slot selected';
          _isCreatingBooking = false;
        });
      }
      return;
    }

    // Validate club ID
    if (_clubId == 0) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Invalid club selected';
          _isCreatingBooking = false;
        });
      }
      return;
    }

    setState(() {
      _isCreatingBooking = true;
      _errorMessage = null;
    });

    try {
      // Generate transaction ID
      final transactionId = CreateBookingModel.generateTransactionId();

      // Use the String times directly (already in 24-hour format)
      final booking = CreateBookingModel(
        slotId: _slotId,
        sportClubId: _clubId,
        bookingDate: _selectedDate,
        startTime:
            _startTime, // Already in 24-hour format from BookingFlowScreen
        endTime: _endTime, // Already in 24-hour format from BookingFlowScreen
        note: 'Booking from app',
        paymentMethod: _paymentMethod,
        transactionRef: transactionId,
      );

      // Print the request for debugging
      print('Creating booking with data: ${booking.toJson()}');

      final result = await _bookingService.createBooking(booking);

      // Check if widget is still mounted after async operation
      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
          // Store the created booking ID
          _bookingId = '#BK-${result.id.toString().padLeft(6, '0')}';
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Check if widget is still mounted before showing error
      if (mounted) {
        setState(() {
          _isCreatingBooking = false;
          _errorMessage = e.toString();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking creation failed: ${e.toString()}'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              _SuccessAnimation(
                checkScale: _checkScale,
                checkOpacity: _checkOpacity,
                ripple1: _ripple1,
                ripple2: _ripple2,
                ripple3: _ripple3,
                rippleController: _rippleController,
                isDark: isDark,
              ),

              const SizedBox(height: 36),

              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      Text(
                        'payment_success_title'.tr(context),
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.kLightText,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage != null
                            ? 'booking_created_with_issues'.tr(context)
                            : 'payment_success_desc'.tr(context),
                        style: TextStyle(
                          color: (isDark ? Colors.white : AppTheme.kLightText)
                              .withOpacity(0.5),
                          fontSize: 14,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.orange, fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      const SizedBox(height: 32),

                      _BookingPillCard(
                        bookingId: _bookingId,
                        sportName: _sportName,
                        courtName: _courtName,
                        date: _date,
                        timeRange: _timeRange,
                        totalPrice: _totalPrice,
                        isDark: isDark,
                        isLoading: _isCreatingBooking,
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              FadeTransition(
                opacity: _buttonFade,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isCreatingBooking
                              ? null
                              : widget.onViewBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.kAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isCreatingBooking
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.black,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.receipt_long_rounded,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'view_my_booking'.tr(context),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _isCreatingBooking
                              ? null
                              : widget.onGoHome,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark
                                ? Colors.white70
                                : AppTheme.kLightText,
                            side: BorderSide(
                              color:
                                  (isDark ? Colors.white : AppTheme.kLightText)
                                      .withOpacity(0.15),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_rounded,
                                size: 18,
                                color: isDark
                                    ? Colors.white70
                                    : AppTheme.kLightText,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'return_to_home'.tr(context),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                  color: isDark
                                      ? Colors.white70
                                      : AppTheme.kLightText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Success Animation ────────────────────────────────────────────────────────
class _SuccessAnimation extends StatelessWidget {
  final Animation<double> checkScale;
  final Animation<double> checkOpacity;
  final Animation<double> ripple1;
  final Animation<double> ripple2;
  final Animation<double> ripple3;
  final AnimationController rippleController;
  final bool isDark;

  const _SuccessAnimation({
    required this.checkScale,
    required this.checkOpacity,
    required this.ripple1,
    required this.ripple2,
    required this.ripple3,
    required this.rippleController,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: AnimatedBuilder(
        animation: rippleController,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              _RippleRing(
                progress: ripple3.value,
                maxRadius: 80,
                color: AppTheme.kAccent,
                strokeWidth: 1.2,
              ),
              _RippleRing(
                progress: ripple2.value,
                maxRadius: 68,
                color: AppTheme.kAccent,
                strokeWidth: 1.8,
              ),
              _RippleRing(
                progress: ripple1.value,
                maxRadius: 56,
                color: AppTheme.kAccent,
                strokeWidth: 2.5,
              ),

              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.kAccent.withOpacity(0.12),
                ),
              ),

              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.kAccent,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.kAccent.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),

              AnimatedBuilder(
                animation: checkScale,
                builder: (_, __) => Opacity(
                  opacity: checkOpacity.value,
                  child: Transform.scale(
                    scale: checkScale.value,
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.black,
                      size: 42,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RippleRing extends StatelessWidget {
  final double progress;
  final double maxRadius;
  final Color color;
  final double strokeWidth;

  const _RippleRing({
    required this.progress,
    required this.maxRadius,
    required this.color,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: (1.0 - progress).clamp(0.0, 1.0),
      child: Container(
        width: maxRadius * 2 * progress,
        height: maxRadius * 2 * progress,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: strokeWidth),
        ),
      ),
    );
  }
}

// ── Booking Pill Card ──────────────────────────────────────────────────────
class _BookingPillCard extends StatelessWidget {
  final String bookingId;
  final String sportName;
  final String courtName;
  final String date;
  final String timeRange;
  final double totalPrice;
  final bool isDark;
  final bool isLoading;

  const _BookingPillCard({
    required this.bookingId,
    required this.sportName,
    required this.courtName,
    required this.date,
    required this.timeRange,
    required this.totalPrice,
    required this.isDark,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.kAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppTheme.kAccent.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      color: AppTheme.kAccent,
                      strokeWidth: 2,
                    ),
                  ),
                if (isLoading) const SizedBox(width: 6),
                Icon(
                  isLoading ? Icons.hourglass_empty : Icons.tag_rounded,
                  color: AppTheme.kAccent,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  isLoading
                      ? 'processing_booking'.tr(context)
                      : '${'booking'.tr(context)} #$bookingId',
                  style: const TextStyle(
                    color: AppTheme.kAccent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          _DetailRow(
            icon: Icons.sports_rounded,
            label: sportName,
            sub: 'sport'.tr(context),
            isDark: isDark,
          ),
          _CardDivider(isDark: isDark),
          _DetailRow(
            icon: Icons.grid_view_rounded,
            label: courtName,
            sub: 'court'.tr(context),
            isDark: isDark,
          ),
          _CardDivider(isDark: isDark),
          _DetailRow(
            icon: Icons.calendar_month_rounded,
            label: date,
            sub: 'date'.tr(context),
            isDark: isDark,
          ),
          _CardDivider(isDark: isDark),
          _DetailRow(
            icon: Icons.access_time_filled_rounded,
            label: timeRange,
            sub: 'time'.tr(context),
            isDark: isDark,
          ),
          _CardDivider(isDark: isDark),
          _DetailRow(
            icon: Icons.payments_rounded,
            label: '\$${totalPrice.toStringAsFixed(2)}',
            sub: 'total_paid'.tr(context),
            valueColor: AppTheme.kAccent,
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color? valueColor;
  final bool isDark;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.sub,
    this.valueColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppTheme.kAccent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.kAccent, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color:
                    valueColor ?? (isDark ? Colors.white : AppTheme.kLightText),
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            sub,
            style: TextStyle(
              color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  final bool isDark;

  const _CardDivider({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: isDark ? const Color(0xFF2A2A3A) : Colors.grey[300],
      thickness: 1,
      height: 0,
    );
  }
}
