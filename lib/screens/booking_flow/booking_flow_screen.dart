import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme.dart';
import '../../models/models.dart';
import '../../providers/booking_provider.dart';
import 'steps/step_category.dart';
import 'steps/step_court.dart';
import 'steps/step_date.dart';
import 'steps/step_time.dart';

class BookingFlowScreen extends StatefulWidget {
  final BookingTarget target;
  const BookingFlowScreen({super.key, required this.target});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  late final PageController _page;
  int _step = 0; // 0=category, 1=court, 2=date, 3=time

  // When sports.length == 1, skip category step
  bool get _skipCategory => widget.target.sports.length == 1;

  int get _totalSteps => _skipCategory ? 3 : 4;

  List<String> get _stepLabels => _skipCategory
      ? ['Court', 'Date', 'Time']
      : ['Category', 'Court', 'Date', 'Time'];

  @override
  void initState() {
    super.initState();
    _page = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<BookingProvider>();
      p.setTarget(widget.target);
      // auto-select sport when only one
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
        return p.canConfirm;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingProvider>(
      builder: (context, provider, _) => Scaffold(
        backgroundColor: AppTheme.kBg,
        appBar: _buildAppBar(provider),
        body: Column(
          children: [
            // ── Step progress ──────────────────────────────────────────
            _StepIndicator(steps: _stepLabels, currentStep: _step),

            // ── Page content ───────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                children: _skipCategory
                    ? [
                        StepCourt(onNext: _next),
                        StepDate(onNext: _next),
                        StepTime(onConfirm: () => _handleConfirm(provider)),
                      ]
                    : [
                        StepCategory(onNext: _next),
                        StepCourt(onNext: _next),
                        StepDate(onNext: _next),
                        StepTime(onConfirm: () => _handleConfirm(provider)),
                      ],
              ),
            ),

            // ── Bottom action bar ──────────────────────────────────────
            _BottomBar(
              step: _step,
              totalSteps: _totalSteps,
              canProceed: _canNext(provider),
              onBack: _back,
              onNext: _next,
              onConfirm: () => _handleConfirm(provider),
              provider: provider,
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BookingProvider p) => AppBar(
    backgroundColor: AppTheme.kBg,
    elevation: 0,
    leading: IconButton(
      onPressed: _back,
      icon: const Icon(
        Icons.arrow_back_ios_new_rounded,
        color: Colors.white,
        size: 20,
      ),
    ),
    title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.target.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          widget.target.venue,
          style: const TextStyle(color: AppTheme.kTextSub, fontSize: 11.5),
        ),
      ],
    ),
    actions: [
      // Venue header badge
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

  void _handleConfirm(BookingProvider p) {
    if (!p.canConfirm) return;
    p.confirmBooking();
    final sport = p.selectedSport ?? '';
    final court = p.selectedCourt!;
    final date = _fmtDate(p.selectedDate!);
    final time = p.timeRangeLabel;
    final price = p.totalPrice.toStringAsFixed(0);

    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '✅  ${widget.target.name} · $sport · Court $court · $date · $time · \$$price',
          style: TextStyle(color: Colors.white.withOpacity(0.9)),
        ),
        backgroundColor: const Color(0xFF1A3A5C),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static String _fmtDate(DateTime d) {
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

// ── Step Indicator ─────────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  final List<String> steps;
  final int currentStep;

  const _StepIndicator({required this.steps, required this.currentStep});

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
                color: done ? AppTheme.kAccent : AppTheme.kBorder,
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
                      : AppTheme.kCardAlt,
                  border: Border.all(
                    color: done || active ? AppTheme.kAccent : AppTheme.kBorder,
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
                          color: active ? AppTheme.kAccent : Colors.white38,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(height: 3),
              Text(
                steps[si],
                style: TextStyle(
                  color: done || active ? Colors.white70 : Colors.white38,
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

// ── Bottom action bar ──────────────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final int step, totalSteps;
  final bool canProceed;
  final VoidCallback onBack, onNext, onConfirm;
  final BookingProvider provider;

  const _BottomBar({
    required this.step,
    required this.totalSteps,
    required this.canProceed,
    required this.onBack,
    required this.onNext,
    required this.onConfirm,
    required this.provider,
  });

  bool get isLastStep => step == totalSteps - 1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 26),
      decoration: const BoxDecoration(
        color: Color(0xFF0E2038),
        border: Border(top: BorderSide(color: AppTheme.kBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 12,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Summary pill (visible when enough data collected)
          if (isLastStep && provider.canConfirm) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.kCardAlt,
                borderRadius: BorderRadius.circular(12),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    _dot(),
                  ],
                  if (provider.selectedDate != null) ...[
                    Text(
                      _fmtDate(provider.selectedDate!),
                      style: const TextStyle(
                        color: Colors.white70,
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
                    style: const TextStyle(
                      color: Colors.white,
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
              // Back button
              GestureDetector(
                onTap: onBack,
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: BoxDecoration(
                    color: AppTheme.kCardAlt,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: AppTheme.kBorder),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Next / Confirm button
              Expanded(
                child: GestureDetector(
                  onTap: canProceed ? (isLastStep ? onConfirm : onNext) : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    decoration: BoxDecoration(
                      color: canProceed ? AppTheme.kAccent : AppTheme.kBorder,
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
                                : Colors.white38,
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
      decoration: const BoxDecoration(
        color: AppTheme.kTextSub,
        shape: BoxShape.circle,
      ),
    ),
  );

  static String _fmtDate(DateTime d) {
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
