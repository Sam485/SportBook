// booking_flow_screen.dart - WITH AUTHENTICATION VALIDATION & FIXES
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import 'package:sportbook/feature/SportClub/Service/sport_club_service.dart';
import 'package:sportbook/feature/SportClub/model/dto/slot_dto.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/routes/app_routes.dart';
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

  // Authentication state
  bool _isAuthenticated = false;
  bool _isAuthLoading = true;

  // State variables
  SportClubModel? _clubWithSlots;
  bool _isLoading = true;
  String? _errorMessage;

  // Local state for booking
  String? _selectedCategory;
  int? _selectedCourtId;
  SlotDto? _selectedSlot;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _selectedPaymentMethod;

  // Navigation debounce flag
  bool _isNavigating = false;

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

  // Get the actual step index considering skipCategory
  int get _actualStepIndex {
    return _skipCategory ? _step + 1 : _step;
  }

  // Check if we can proceed to next step
  bool get _canProceed {
    final stepIndex = _actualStepIndex;

    switch (stepIndex) {
      case 0:
        // Category step - if skipped, automatically true
        return _skipCategory ? true : _selectedCategory != null;
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

  // Can confirm booking
  bool get _canConfirm {
    final hasCategory = _skipCategory ? true : _selectedCategory != null;

    return hasCategory &&
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
    return _selectedSlot?.name ?? 'Court $_selectedCourtId';
  }

  int get _pricePerHour {
    return _selectedSlot?.price ?? 0;
  }

  @override
  void initState() {
    super.initState();
    _page = PageController();
    _clubService = getIt<SportClubService>();

    // Check authentication status on init
    _checkAuthentication();

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
    _isNavigating = false;
    super.dispose();
  }

  // Enhanced authentication check
  Future<void> _checkAuthentication() async {
    setState(() {
      _isAuthLoading = true;
    });

    try {
      final tokenService = getIt<TokenService>();
      final hasValidToken = await tokenService.hasValidTokenAsync();

      if (hasValidToken) {
        _isAuthenticated = true;
      } else {
        // Try to refresh token
        final refreshToken = await tokenService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshed = await tokenService.refreshAccessToken();
          _isAuthenticated = refreshed;
        } else {
          _isAuthenticated = false;
        }
      }
    } catch (e) {
      _isAuthenticated = false;
    }

    setState(() {
      _isAuthLoading = false;
    });
  }

  // Show login required dialog
  void _showLoginRequiredDialog(BuildContext context, {String? message}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'login_required'.tr(context),
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message ?? 'login_to_complete_booking'.tr(context),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? Colors.white70 : AppTheme.kLightTextSub,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.kAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.kAccent.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: AppTheme.kAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'you_need_account_to_book'.tr(context),
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        color: isDark ? Colors.white70 : AppTheme.kLightText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'cancel'.tr(context),
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login with return route
              Navigator.pushNamed(
                context,
                AppRoutes.login,
                arguments: {
                  'returnTo': AppRoutes.bookingFlow,
                  'club': widget.target,
                },
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.kAccent,
              foregroundColor: Colors.black,
              textStyle: const TextStyle(fontFamily: AppTheme.fontFamily),
            ),
            child: Text('login'.tr(context)),
          ),
        ],
      ),
    );
  }

  // Handle booking confirmation with auth check
  void _handleConfirm() async {
    // If not authenticated, show login dialog
    if (!_isAuthenticated) {
      _showLoginRequiredDialog(context);
      return;
    }

    // User is authenticated, proceed with booking
    _paymentKey.currentState?.handleConfirm();
  }

  Future<void> _fetchClubWithSlots() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final clubData = await _clubService.getClubByIdWithSlots(
        widget.target.id,
      );

      if (!mounted) return;

      if (clubData.slots == null || clubData.slots!.isEmpty) {
        setState(() {
          _clubWithSlots = widget.target;
          _isLoading = false;

          // Auto-select the first category if there's only one
          if (_skipCategory && (_clubWithSlots?.categories ?? []).isNotEmpty) {
            _selectedCategory = _clubWithSlots!.categories.first.name;
          }
        });
        return;
      }

      setState(() {
        _clubWithSlots = clubData;
        _isLoading = false;

        // Auto-select the first category if there's only one
        if (_skipCategory && (_clubWithSlots?.categories ?? []).isNotEmpty) {
          _selectedCategory = _clubWithSlots!.categories.first.name;
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _clubWithSlots = widget.target;
        _isLoading = false;
        _errorMessage = null;

        // Auto-select the first category if there's only one
        if (_skipCategory && (_clubWithSlots?.categories ?? []).isNotEmpty) {
          _selectedCategory = _clubWithSlots!.categories.first.name;
        }
      });
    }
  }

  // FIXED: Back button with debounce
  void _back() {
    // Prevent multiple rapid calls
    if (_isNavigating) return;

    if (_step > 0) {
      _isNavigating = true;
      setState(() => _step--);
      _page
          .animateToPage(
            _step,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          )
          .then((_) {
            if (mounted) {
              _isNavigating = false;
            }
          });
    } else {
      _isNavigating = true;
      Navigator.of(context).pop(false);
      // Since pop() is synchronous, use a short delay to prevent rapid taps
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _isNavigating = false;
        }
      });
    }
  }

  // FIXED: Next button with debounce
  void _next() {
    // Prevent multiple rapid calls
    if (_isNavigating) return;

    if (_step < _totalSteps - 1 && _canProceed) {
      _isNavigating = true;
      setState(() => _step++);
      _page
          .animateToPage(
            _step,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
          )
          .then((_) {
            if (mounted) {
              _isNavigating = false;
            }
          });
    }
  }

  void _onPaymentConfirmed() {
    if (!mounted) return;

    // Double check authentication before proceeding
    if (!_isAuthenticated) {
      _showLoginRequiredDialog(context);
      return;
    }

    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a valid court',
            style: const TextStyle(fontFamily: AppTheme.fontFamily),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Format times in 24-hour format for API
    final startTimeStr = _selectedStartTime != null
        ? '${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}'
        : '00:00';
    final endTimeStr = _selectedEndTime != null
        ? '${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}'
        : '00:00';

    // Get payment method in API format
    String paymentMethodApi = 'qr_code';
    switch (_selectedPaymentMethod?.toLowerCase()) {
      case 'khqr':
        paymentMethodApi = 'qr_code';
        break;
      case 'cash':
        paymentMethodApi = 'cash';
        break;
      case 'aba':
        paymentMethodApi = 'aba';
        break;
      case 'wing':
        paymentMethodApi = 'wing';
        break;
      case 'pi_pay':
        paymentMethodApi = 'pi_pay';
        break;
      case 'true_money':
        paymentMethodApi = 'true_money';
        break;
      default:
        paymentMethodApi = 'qr_code';
    }

    final bookingData = {
      'club': _clubWithSlots ?? widget.target,
      'category': _selectedCategory,
      'court': _selectedSlot!.id,
      'courtName': _courtName,
      'slot': _selectedSlot,
      'date': _selectedDate,
      'startTime': startTimeStr,
      'endTime': endTimeStr,
      'startTimeOfDay': _selectedStartTime,
      'endTimeOfDay': _selectedEndTime,
      'paymentMethod': paymentMethodApi,
      'totalPrice': _totalPrice,
      'pricePerHour': _pricePerHour,
    };

    // Navigate to success page with auth status
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentSuccessPage(
          bookingData: bookingData,
          isAuthenticated: _isAuthenticated,
          onGoHome: () {
            Navigator.of(context).popUntil((route) {
              return route.settings.name == AppRoutes.home;
            });
          },
          onViewBooking: () {
            Navigator.of(context).pushNamedAndRemoveUntil(
              AppRoutes.allbookings,
              (route) => false,
              arguments: true,
            );
          },
          onLoginRequired: () {
            // Return to booking flow if login needed
            _showLoginRequiredDialog(context);
          },
        ),
      ),
    );
  }

  // Callbacks from steps
  void _onCategorySelected(String category) {
    if (!mounted) return;

    // Only set state if category is not skipped
    // If skipped, the category is already auto-selected
    if (!_skipCategory) {
      setState(() {
        _selectedCategory = category;
      });
    }
  }

  void _onCourtSelected(int courtId) {
    if (!mounted) return;

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
    if (!mounted) return;
    setState(() {
      _selectedDate = date;
      _selectedStartTime = start;
      _selectedEndTime = end;
    });
  }

  void _onPaymentMethodSelected(String method) {
    if (!mounted) return;
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
      body: _isLoading || _isAuthLoading
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
            _isAuthLoading
                ? 'checking_account'.tr(context)
                : 'loading_courts'.tr(context),
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
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
                fontFamily: AppTheme.fontFamily,
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
                fontFamily: AppTheme.fontFamily,
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
                textStyle: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text('retry'.tr(context)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'go_back'.tr(context),
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
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
                  fontFamily: AppTheme.fontFamily,
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
                  fontFamily: AppTheme.fontFamily,
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
          isAuthenticated: _isAuthenticated,
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
            fontFamily: AppTheme.fontFamily,
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          widget.target.location,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
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
          color: widget.target.color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: widget.target.color.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.target.color.withValues(alpha: 0.25),
                border: Border.all(color: widget.target.color, width: 1.5),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.target.initials,
                style: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
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
                      ? AppTheme.kAccent.withValues(alpha: 0.2)
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
                          fontFamily: AppTheme.fontFamily,
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
                  fontFamily: AppTheme.fontFamily,
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
  final bool isAuthenticated;

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
    this.isAuthenticated = false,
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
          Row(
            children: [
              // Back button
              GestureDetector(
                onTap: onBack,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? Colors.white70 : AppTheme.kLightText,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Next/Confirm button
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
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: (isLastStep ? canConfirm : canProceed)
                          ? [
                              BoxShadow(
                                color: AppTheme.kAccent.withValues(alpha: 0.35),
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
                            fontFamily: AppTheme.fontFamily,
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
          // Show authentication status info
          if (isLastStep && !isAuthenticated) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.orange,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'login_to_complete_booking'.tr(context),
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      color: Colors.orange,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
