import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/booking_provider.dart';

class PaymentSuccessPage extends StatefulWidget {
  final VoidCallback onGoHome;
  final VoidCallback onViewBooking;

  const PaymentSuccessPage({
    super.key,
    required this.onGoHome,
    required this.onViewBooking,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage>
    with TickerProviderStateMixin {
  // ── Animation controllers ─────────────────────────────────────────────────
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

  @override
  void initState() {
    super.initState();
    HapticFeedback.heavyImpact();

    // Check icon pop
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

    // Ripple rings
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

    // Content slide up
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

    // Buttons entrance
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

    // Sequence the animations
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
  }

  @override
  void dispose() {
    _checkController.dispose();
    _rippleController.dispose();
    _contentController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();

    return Scaffold(
      backgroundColor: AppTheme.kBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Success animation ──────────────────────────────────────────
              _SuccessAnimation(
                checkScale: _checkScale,
                checkOpacity: _checkOpacity,
                ripple1: _ripple1,
                ripple2: _ripple2,
                ripple3: _ripple3,
                rippleController: _rippleController,
              ),

              const SizedBox(height: 36),

              // ── Title + subtitle ───────────────────────────────────────────
              FadeTransition(
                opacity: _contentFade,
                child: SlideTransition(
                  position: _contentSlide,
                  child: Column(
                    children: [
                      const Text(
                        'Payment Successful!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Your court has been reserved.\nSee you on the court!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // ── Booking summary pill card ──────────────────────────
                      _BookingPillCard(p: p),
                    ],
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // ── Buttons ────────────────────────────────────────────────────
              FadeTransition(
                opacity: _buttonFade,
                child: SlideTransition(
                  position: _buttonSlide,
                  child: Column(
                    children: [
                      // Primary: View Booking
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: widget.onViewBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.kAccent,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_long_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'View My Booking',
                                style: TextStyle(
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

                      // Secondary: Return Home
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: widget.onGoHome,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white70,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.15),
                              width: 1.5,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.home_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Return to Home',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
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

// ── Success animation: check + ripple rings ───────────────────────────────────
class _SuccessAnimation extends StatelessWidget {
  final Animation<double> checkScale;
  final Animation<double> checkOpacity;
  final Animation<double> ripple1;
  final Animation<double> ripple2;
  final Animation<double> ripple3;
  final AnimationController rippleController;

  const _SuccessAnimation({
    required this.checkScale,
    required this.checkOpacity,
    required this.ripple1,
    required this.ripple2,
    required this.ripple3,
    required this.rippleController,
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
              // Ripple ring 3 (outermost)
              _RippleRing(
                progress: ripple3.value,
                maxRadius: 80,
                color: AppTheme.kAccent,
                strokeWidth: 1.2,
              ),
              // Ripple ring 2
              _RippleRing(
                progress: ripple2.value,
                maxRadius: 68,
                color: AppTheme.kAccent,
                strokeWidth: 1.8,
              ),
              // Ripple ring 1 (innermost)
              _RippleRing(
                progress: ripple1.value,
                maxRadius: 56,
                color: AppTheme.kAccent,
                strokeWidth: 2.5,
              ),

              // Glow circle
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.kAccent.withOpacity(0.12),
                ),
              ),

              // Main circle
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

              // Check icon
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

// ── Booking pill summary card ─────────────────────────────────────────────────
class _BookingPillCard extends StatelessWidget {
  final BookingProvider p;
  const _BookingPillCard({required this.p});

  static String _fmtH(int h) {
    final period = h >= 12 ? 'PM' : 'AM';
    final hr = h % 12 == 0 ? 12 : h % 12;
    return '$hr:00 $period';
  }

  static const _months = [
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
  static const _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  Widget build(BuildContext context) {
    final date = p.selectedDate;
    final dateStr = date != null
        ? '${_weekdays[date.weekday - 1]}, ${_months[date.month - 1]} ${date.day}'
        : '—';
    final timeStr = (p.startHour != null && p.endHour != null)
        ? '${_fmtH(p.startHour!)} – ${_fmtH(p.endHour!)}'
        : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.kCardAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.kBorder),
      ),
      child: Column(
        children: [
          // Confirmation ID row
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
                const Icon(
                  Icons.tag_rounded,
                  color: AppTheme.kAccent,
                  size: 13,
                ),
                const SizedBox(width: 6),
                Text(
                  'Booking #${_generateId()}',
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

          // Details grid
          _DetailRow(
            icon: Icons.sports_rounded,
            label: p.selectedSport ?? '—',
            sub: 'Sport',
          ),
          const _CardDivider(),
          _DetailRow(
            icon: Icons.grid_view_rounded,
            label: p.target?.name ?? '—',
            sub: 'Court',
          ),
          const _CardDivider(),
          _DetailRow(
            icon: Icons.calendar_month_rounded,
            label: dateStr,
            sub: 'Date',
          ),
          const _CardDivider(),
          _DetailRow(
            icon: Icons.access_time_filled_rounded,
            label: timeStr,
            sub: 'Time',
          ),
          const _CardDivider(),
          _DetailRow(
            icon: Icons.payments_rounded,
            label: '\$${p.totalPrice.toStringAsFixed(2)}',
            sub: 'Total Paid',
            valueColor: AppTheme.kAccent,
          ),
        ],
      ),
    );
  }

  // Generate a simple pseudo booking ID from current time
  String _generateId() {
    final now = DateTime.now();
    return '${now.year.toString().substring(2)}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch.toString().substring(7)}';
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.sub,
    this.valueColor,
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
                color: valueColor ?? Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              color: AppTheme.kTextSub,
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
  const _CardDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(color: Color(0xFF2A2A3A), thickness: 1, height: 0);
  }
}
