import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/model/dto/slot_dto.dart';
import 'package:sportbook/screens/booking_flow/steps/step_payment.dart';
import 'package:sportbook/screens/booking_flow/steps/success.dart';
import '../../core/theme.dart';
import '../../translations/app_translations.dart';
import 'steps/step_category.dart';
import 'steps/step_court.dart';
import 'steps/step_date_time.dart';

class BookingFlowScreen extends StatefulWidget {
  final SportClubModel target;
  const BookingFlowScreen({super.key, required this.target});

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  late final PageController _page;
  int _step = 0;
  final _paymentKey = GlobalKey<StepPaymentState>();

  late final SportClubService _clubService;

  // State variables
  SportClubModel? _clubWithSlots;
  bool _isLoading = true;
  String? _errorMessage;

  // Local state for booking
  String? _selectedCategory;
  int? _selectedCourtId; // This stores the slot ID
  SlotDto? _selectedSlot; // This stores the full slot object
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _selectedPaymentMethod;

  bool get _skipCategory => (_clubWithSlots?.categories ?? []).length <= 1;
  int get _totalSteps => _skipCategory ? 3 : 4;
  List<String> get _stepLabels => _skipCategory
      ? ['court'.tr(context), 'date_time'.tr(context), 'payment'.tr(context)]
      : [
          'category'.tr(context),
          'court'.tr(context),
          'date'.tr(context),
          'payment'.tr(context),
        ];

  // Check if we can proceed to next step
  bool get _canProceed {
    final stepIndex = _skipCategory ? _step + 1 : _step;
    switch (stepIndex) {
      case 0:
        return _selectedCategory != null;
      case 1:
        return _selectedCourtId != null;
      case 2:
        return _selectedDate != null &&
            _selectedStartTime != null &&
            _selectedEndTime != null;
      case 3:
        return _selectedPaymentMethod != null;
      default:
        return false;
    }
  }

  bool get _canConfirm {
    return _selectedCategory != null &&
        _selectedCourtId != null &&
        _selectedSlot != null &&
        _selectedDate != null &&
        _selectedStartTime != null &&
        _selectedEndTime != null &&
        _selectedPaymentMethod != null;
  }

  int get _totalPrice {
    if (_selectedSlot == null ||
        _selectedStartTime == null ||
        _selectedEndTime == null) {
      return 0;
    }

    final durationInHours = _selectedEndTime!.hour - _selectedStartTime!.hour;
    return _selectedSlot!.price * durationInHours;
  }

  String get _timeRangeLabel {
    if (_selectedStartTime != null && _selectedEndTime != null) {
      return '${_selectedStartTime!.format(context)} - ${_selectedEndTime!.format(context)}';
    }
    return '';
  }

  String get _formattedDate {
    if (_selectedDate != null) {
      final date = _selectedDate!;
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));

      if (DateUtils.isSameDay(date, now)) {
        return 'today'.tr(context);
      } else if (DateUtils.isSameDay(date, tomorrow)) {
        return 'tomorrow'.tr(context);
      } else {
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
    }
    return '';
  }

  String get _courtName {
    return _selectedSlot?.name ?? 'Court ${_selectedCourtId}';
  }

  int get _pricePerHour {
    return _selectedSlot?.price ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _page = PageController();
    _clubService = getIt<SportClubService>();

    // Check if we already have slots from the passed data
    if (widget.target.slots != null && widget.target.slots!.isNotEmpty) {
      setState(() {
        _clubWithSlots = widget.target;
        _isLoading = false;

        if (_skipCategory && (_clubWithSlots?.categories ?? []).isNotEmpty) {
          _selectedCategory = _clubWithSlots!.categories.first.name;
        }
      });
    } else {
      _fetchClubWithSlots();
    }
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  Future<void> _fetchClubWithSlots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final clubData = await _clubService.getClubById(widget.target.id);

      if (clubData?.slots == null || clubData!.slots!.isEmpty) {
        setState(() {
          _clubWithSlots = widget.target;
          _isLoading = false;

          if (_skipCategory && (_clubWithSlots?.categories ?? []).isNotEmpty) {
            _selectedCategory = _clubWithSlots!.categories.first.name;
          }
        });
        return;
      }

      setState(() {
        _clubWithSlots = clubData;
        _isLoading = false;

        if (_skipCategory && (_clubWithSlots?.categories ?? []).isNotEmpty) {
          _selectedCategory = _clubWithSlots!.categories.first.name;
        }
      });
    } catch (e) {
      setState(() {
        _clubWithSlots = widget.target;
        _isLoading = false;
        _errorMessage = null;

        if (_skipCategory && (_clubWithSlots?.categories ?? []).isNotEmpty) {
          _selectedCategory = _clubWithSlots!.categories.first.name;
        }
      });
    }
  }

  void _next() {
    if (_step < _totalSteps - 1 && _canProceed) {
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

  void _handleConfirm() {
    _paymentKey.currentState?.handleConfirm();
  }

  void _onPaymentConfirmed() {
    final bookingData = {
      'club': _clubWithSlots ?? widget.target,
      'category': _selectedCategory,
      'court': _selectedCourtId,
      'courtName': _courtName,
      'slot': _selectedSlot,
      'date': _selectedDate,
      'startTime': _selectedStartTime,
      'endTime': _selectedEndTime,
      'paymentMethod': _selectedPaymentMethod,
      'totalPrice': _totalPrice,
      'pricePerHour': _pricePerHour,
    };

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentSuccessPage(
          bookingData: bookingData,
          onGoHome: () => Navigator.of(context).popUntil((r) => r.isFirst),
          onViewBooking: () {
            Navigator.of(context).popUntil((r) => r.isFirst);
          },
        ),
      ),
    );
  }

  // Callbacks from steps
  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  void _onCourtSelected(int courtId) {
    // Find the full slot object
    final slot = _clubWithSlots?.slots?.firstWhere(
      (s) => s.id == courtId,
      orElse: () => _clubWithSlots!.slots!.first,
    );

    setState(() {
      _selectedCourtId = courtId;
      _selectedSlot = slot;
    });
  }

  void _onDateTimeSelected(DateTime date, TimeOfDay start, TimeOfDay end) {
    setState(() {
      _selectedDate = date;
      _selectedStartTime = start;
      _selectedEndTime = end;
    });
  }

  void _onPaymentMethodSelected(String method) {
    setState(() {
      _selectedPaymentMethod = method;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.kBg : AppTheme.kLightBg,
      appBar: _buildAppBar(isDark),
      body: _isLoading
          ? _buildLoadingState(isDark)
          : _errorMessage != null
          ? _buildErrorState(isDark)
          : _buildContent(isDark),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.kAccent,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'loading_courts'.tr(context),
            style: TextStyle(
              color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.redAccent,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'failed_to_load_courts'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'unknown_error'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchClubWithSlots,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.kAccent,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'retry'.tr(context),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'go_back'.tr(context),
                style: TextStyle(
                  color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    final hasSlots =
        _clubWithSlots?.slots != null && _clubWithSlots!.slots!.isNotEmpty;

    if (!hasSlots) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.sports,
                color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'no_courts_available'.tr(context),
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'please_check_back_later'.tr(context),
                style: TextStyle(
                  color: isDark ? Colors.white54 : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        _StepIndicator(steps: _stepLabels, currentStep: _step, isDark: isDark),
        Expanded(
          child: PageView(
            controller: _page,
            physics: const NeverScrollableScrollPhysics(),
            children: _skipCategory
                ? [
                    StepCourt(
                      onNext: _next,
                      onCourtSelected: _onCourtSelected,
                      selectedCourt: _selectedCourtId,
                      club: _clubWithSlots,
                      selectedCategory: _selectedCategory,
                    ),
                    StepDateAndTime(
                      onConfirm: _next,
                      onDateTimeSelected: _onDateTimeSelected,
                      selectedDate: _selectedDate,
                      selectedStartTime: _selectedStartTime,
                      selectedEndTime: _selectedEndTime,
                      selectedCourt: _selectedCourtId,
                      selectedCategory: _selectedCategory,
                      club: _clubWithSlots,
                    ),
                    StepPayment(
                      key: _paymentKey,
                      onConfirm: _onPaymentConfirmed,
                      onPaymentMethodSelected: _onPaymentMethodSelected,
                      selectedPaymentMethod: _selectedPaymentMethod,
                      totalPrice: _totalPrice,
                      selectedSport: _selectedCategory,
                      courtName: _courtName,
                      date: _formattedDate,
                      timeRange: _timeRangeLabel,
                    ),
                  ]
                : [
                    StepCategory(
                      onNext: _next,
                      onCategorySelected: _onCategorySelected,
                      selectedCategory: _selectedCategory,
                      categories: _clubWithSlots?.categories ?? [],
                    ),
                    StepCourt(
                      onNext: _next,
                      onCourtSelected: _onCourtSelected,
                      selectedCourt: _selectedCourtId,
                      club: _clubWithSlots,
                      selectedCategory: _selectedCategory,
                    ),
                    StepDateAndTime(
                      onConfirm: _next,
                      onDateTimeSelected: _onDateTimeSelected,
                      selectedDate: _selectedDate,
                      selectedStartTime: _selectedStartTime,
                      selectedEndTime: _selectedEndTime,
                      selectedCourt: _selectedCourtId,
                      selectedCategory: _selectedCategory,
                      club: _clubWithSlots,
                    ),
                    StepPayment(
                      key: _paymentKey,
                      onConfirm: _onPaymentConfirmed,
                      onPaymentMethodSelected: _onPaymentMethodSelected,
                      selectedPaymentMethod: _selectedPaymentMethod,
                      totalPrice: _totalPrice,
                      selectedSport: _selectedCategory,
                      courtName: _courtName,
                      date: _formattedDate,
                      timeRange: _timeRangeLabel,
                    ),
                  ],
          ),
        ),
        _BottomBar(
          step: _step,
          totalSteps: _totalSteps,
          canProceed: _canProceed,
          onBack: _back,
          onNext: _next,
          onConfirm: _handleConfirm,
          selectedCategory: _selectedCategory,
          selectedCourt: _selectedCourtId,
          selectedDate: _selectedDate,
          timeRangeLabel: _timeRangeLabel,
          totalPrice: _totalPrice,
          isDark: isDark,
          canConfirm: _canConfirm,
          courtName: _courtName,
        ),
      ],
    );
  }

  AppBar _buildAppBar(bool isDark) => AppBar(
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
          widget.target.location,
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
  final String? selectedCategory;
  final int? selectedCourt;
  final DateTime? selectedDate;
  final String timeRangeLabel;
  final int totalPrice;
  final bool isDark;
  final bool canConfirm;
  final String? courtName;

  const _BottomBar({
    required this.step,
    required this.totalSteps,
    required this.canProceed,
    required this.onBack,
    required this.onNext,
    required this.onConfirm,
    required this.selectedCategory,
    required this.selectedCourt,
    required this.selectedDate,
    required this.timeRangeLabel,
    required this.totalPrice,
    required this.isDark,
    required this.canConfirm,
    this.courtName,
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
          if (isLastStep && canConfirm) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      if (selectedCategory != null) ...[
                        Text(
                          selectedCategory!,
                          style: const TextStyle(
                            color: AppTheme.kAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _dot(),
                      ],
                      if (courtName != null && courtName!.isNotEmpty) ...[
                        Text(
                          courtName!,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppTheme.kLightText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _dot(),
                      ] else if (selectedCourt != null) ...[
                        Text(
                          'Court ${selectedCourt}',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppTheme.kLightText,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _dot(),
                      ],
                      if (selectedDate != null) ...[
                        Text(
                          _formatDate(selectedDate!, context),
                          style: TextStyle(
                            color: isDark
                                ? Colors.white70
                                : AppTheme.kLightTextSub,
                            fontSize: 12,
                          ),
                        ),
                        _dot(),
                      ],
                      Expanded(
                        child: Text(
                          timeRangeLabel,
                          style: const TextStyle(
                            color: AppTheme.kAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '\$${totalPrice.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppTheme.kLightText,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (selectedDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${totalPrice.toStringAsFixed(2)} ${"usd".tr(context)}',
                            style: TextStyle(
                              color: isDark
                                  ? Colors.white54
                                  : AppTheme.kLightTextSub,
                              fontSize: 10,
                            ),
                          ),
                        ],
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
                      color: (isLastStep ? canConfirm : canProceed)
                          ? AppTheme.kAccent
                          : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: (isLastStep ? canConfirm : canProceed)
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
                          isLastStep
                              ? 'confirm_booking'.tr(context)
                              : 'next'.tr(context),
                          style: TextStyle(
                            color: (isLastStep ? canConfirm : canProceed)
                                ? const Color(0xFF0A1828)
                                : (isDark
                                      ? Colors.white38
                                      : AppTheme.kLightTextSub),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (isLastStep ? canConfirm : canProceed) ...[
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

  String _formatDate(DateTime d, BuildContext context) {
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    if (DateUtils.isSameDay(d, now)) {
      return 'today'.tr(context);
    } else if (DateUtils.isSameDay(d, tomorrow)) {
      return 'tomorrow'.tr(context);
    } else {
      const months = [
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
      return '${months[d.month - 1]} ${d.day}';
    }
  }
}
