import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportbook/screens/booking_flow/steps/step_payment.dart';
import 'package:sportbook/screens/booking_flow/steps/success.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/booking_provider.dart';
import 'steps/step_category.dart';
import 'steps/step_court.dart';
import 'steps/step_date_time.dart';

class BookingFlowScreen extends StatefulWidget {
  final BookingTarget target;
  const BookingFlowScreen({super.key, required this.target});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  late final PageController _page;
  int _step = 0;
  final _paymentKey = GlobalKey<StepPaymentState>();

  bool get _skipCategory => widget.target.sports.length == 1;
  int get _totalSteps => _skipCategory ? 3 : 4;
  List<String> get _stepLabels => _skipCategory
      ? ['Court', 'Date-Time', 'Payment']
      : ['Category', 'Court', 'Date', 'Payment'];

  @override
  void initState() {
    super.initState();
    _page = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<BookingProvider>();
      p.setTarget(widget.target);
      if (_skipCategory && widget.target.sports.isNotEmpty) {
        p.selectSport(widget.target.sports.first);
      }
    });
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
      _page.animateToPage(
        _step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _back() {
    if (_step > 0) {
      setState(() => _step--);
      _page.animateToPage(
        _step,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pop();
    }
  }

  bool _canNext(BookingProvider p) {
    final stepIndex = _skipCategory ? _step + 1 : _step;
    switch (stepIndex) {
      case 0:
        return p.canProceedFromCategory;
      case 1:
        return p.canProceedFromCourt;
      case 2:
        return p.canProceedFromDate;
      case 3:
        return true;
      default:
        return false;
    }
  }

  void _handleConfirm(BookingProvider p) {
    _paymentKey.currentState?.handleConfirm();
  }

  void _onPaymentConfirmed(BookingProvider p) {
    if (!p.canConfirm) return;
    p.confirmBooking();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PaymentSuccessPage(
          onGoHome: () => Navigator.of(context).popUntil((r) => r.isFirst),
          onViewBooking: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<BookingProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
        appBar: _buildAppBar(provider, isDark),
        body: Column(
          children: [
            _StepIndicator(
              steps: _stepLabels,
              currentStep: _step,
              isDark: isDark,
            ),
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                children: _skipCategory
                    ? [
                        StepCourt(onNext: _next),
                        StepDateAndTime(onConfirm: _next),
                        StepPayment(
                          key: _paymentKey,
                          onConfirm: () => _onPaymentConfirmed(provider),
                        ),
                      ]
                    : [
                        StepCategory(onNext: _next),
                        StepCourt(onNext: _next),
                        StepDateAndTime(onConfirm: _next),
                        StepPayment(
                          key: _paymentKey,
                          onConfirm: () => _onPaymentConfirmed(provider),
                        ),
                      ],
              ),
            ),
            _BottomBar(
              step: _step,
              totalSteps: _totalSteps,
              canProceed: _canNext(provider),
              onBack: _back,
              onNext: _next,
              onConfirm: () => _handleConfirm(provider),
              provider: provider,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BookingProvider p, bool isDark) => AppBar(
    backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
    elevation: 0,
    leading: IconButton(
      onPressed: _back,
      icon: Icon(
        Icons.arrow_back_ios_new_rounded,
        color: isDark ? Colors.white : AppTheme.kLightText,
        size: 20,
      ),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.target.name,
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          widget.target.venue,
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 11.5,
          ),
        ),
      ],
    ),
    actions: [
      Container(
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: widget.target.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.target.color.withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.target.color.withOpacity(0.25),
                border: Border.all(color: widget.target.color, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.target.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

// ── Step Indicator ────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentStep;
  final bool isDark;

  const _StepIndicator({
    required this.steps,
    required this.currentStep,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (i) {
          if (i.isOdd) {
            final done = i ~/ 2 < currentStep;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 2,
                color: done
                    ? AppTheme.kAccent
                    : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
              ),
            );
          }
          final si = i ~/ 2;
          final done = si < currentStep;
          final active = si == currentStep;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? AppTheme.kAccent
                      : active
                      ? AppTheme.kAccent.withOpacity(0.2)
                      : (isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt),
                  border: Border.all(
                    color: done || active
                        ? AppTheme.kAccent
                        : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                    width: 1.5,
                  ),
                ),
                alignment: Alignment.center,
                child: done
                    ? const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 14,
                      )
                    : Text(
                        '${si + 1}',
                        style: TextStyle(
                          color: active
                              ? AppTheme.kAccent
                              : (isDark
                                    ? Colors.white38
                                    : AppTheme.kLightTextSub),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(height: 3),
              Text(
                steps[si],
                style: TextStyle(
                  color: done || active
                      ? (isDark ? Colors.white70 : AppTheme.kLightText)
                      : (isDark ? Colors.white38 : AppTheme.kLightTextSub),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ── Bottom Bar ────────────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int step, totalSteps;
  final bool canProceed;
  final VoidCallback onBack, onNext, onConfirm;
  final BookingProvider provider;
  final bool isDark;

  const _BottomBar({
    required this.step,
    required this.totalSteps,
    required this.canProceed,
    required this.onBack,
    required this.onNext,
    required this.onConfirm,
    required this.provider,
    required this.isDark,
  });

  bool get isLastStep => step == totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0E2038) : AppTheme.kLightCard,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black38 : Colors.black12,
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLastStep && provider.canConfirm) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                ),
              ),
              child: Row(
                children: [
                  if (provider.selectedSport != null) ...[
                    Text(
                      provider.selectedSport!,
                      style: const TextStyle(
                        color: AppTheme.kAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _dot(),
                  ],
                  if (provider.selectedCourt != null) ...[
                    Text(
                      'Court ${provider.selectedCourt}',
                      style: TextStyle(
                        color: isDark ? Colors.white : AppTheme.kLightText,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _dot(),
                  ],
                  if (provider.selectedDate != null) ...[
                    Text(
                      _fmtDate(provider.selectedDate!),
                      style: TextStyle(
                        color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                        fontSize: 12,
                      ),
                    ),
                    _dot(),
                  ],
                  Expanded(
                    child: Text(
                      provider.timeRangeLabel,
                      style: const TextStyle(
                        color: AppTheme.kAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '\$${provider.totalPrice.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppTheme.kLightText,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: isLastStep ? onConfirm : (canProceed ? onNext : null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    decoration: BoxDecoration(
                      color: canProceed
                          ? AppTheme.kAccent
                          : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: canProceed
                          ? [
                              BoxShadow(
                                color: AppTheme.kAccent.withOpacity(0.35),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isLastStep ? 'Confirm Booking' : 'Next',
                          style: TextStyle(
                            color: canProceed
                                ? const Color(0xFF0A1828)
                                : (isDark
                                      ? Colors.white38
                                      : AppTheme.kLightTextSub),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (canProceed) ...[
                          const SizedBox(width: 6),
                          Icon(
                            isLastStep
                                ? Icons.check_rounded
                                : Icons.arrow_forward_rounded,
                            color: const Color(0xFF0A1828),
                            size: 18,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _dot() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Container(
      width: 3,
      height: 3,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
        shape: BoxShape.circle,
      ),
    ),
  );

  String _fmtDate(DateTime d) {
    const m = [
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
    final isToday = DateUtils.isSameDay(d, DateTime.now());
    return isToday ? 'Today' : '${m[d.month - 1]} ${d.day}';
  }
}
