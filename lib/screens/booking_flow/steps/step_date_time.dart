import 'package:flutter/material.dart';
import 'package:sportbook/feature/SportClub/model/sport_club_model.dart';
import '../../../core/theme.dart';
import '../../../translations/app_translations.dart';

class StepDateAndTime extends StatefulWidget {
  final VoidCallback onConfirm;
  final Function(DateTime, TimeOfDay, TimeOfDay) onDateTimeSelected;
  final DateTime? selectedDate;
  final TimeOfDay? selectedStartTime;
  final TimeOfDay? selectedEndTime;
  final int? selectedCourt;
  final String? selectedCategory;
  final SportClubModel? club;

  const StepDateAndTime({
    super.key,
    required this.onConfirm,
    required this.onDateTimeSelected,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.selectedCourt,
    this.selectedCategory,
    this.club,
  });

  @override
  State<StepDateAndTime> createState() => _StepDateAndTimeState();
}

class _StepDateAndTimeState extends State<StepDateAndTime>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Local state
  DateTime? _selectedDate;
  int? _startHour;
  int? _endHour;
  bool _hasAutoConfirmed = false;

  // Selected court slot info
  int _selectedCourtPrice = 0;
  String _selectedCourtName = '';

  static DateTime get _startOfWeek {
    final now = DateTime.now();
    final sub = (now.weekday - DateTime.monday) % 7;
    return DateTime(now.year, now.month, now.day - sub);
  }

  static List<DateTime> get _weekDates {
    final start = _startOfWeek;
    return List.generate(7, (i) => start.add(Duration(days: i)));
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
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String _fmtH(int h) {
    final p = h >= 12 ? 'PM' : 'AM';
    final hr = h % 12 == 0 ? 12 : h % 12;
    return '$hr:00 $p';
  }

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    // Initialize with provided selected date or today
    _selectedDate = widget.selectedDate ?? DateTime.now();

    // Initialize times from widget if provided
    if (widget.selectedStartTime != null) {
      _startHour = widget.selectedStartTime!.hour;
    }
    if (widget.selectedEndTime != null) {
      _endHour = widget.selectedEndTime!.hour;
    }

    // Get selected court info
    _updateSelectedCourtInfo();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animController.forward(from: 0);
      _autoConfirmIfComplete();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updateSelectedCourtInfo() {
    if (widget.club == null || widget.club!.slots == null) return;

    final slots = widget.club!.slots!;
    final courtIndex = (widget.selectedCourt ?? 1) - 1;

    if (courtIndex >= 0 && courtIndex < slots.length) {
      final slot = slots[courtIndex];
      _selectedCourtPrice = slot.price;
      _selectedCourtName = slot.name;
    }
  }

  // Generate available hours based on club opening hours
  List<int> _getAvailableHours() {
    if (widget.club == null) {
      return List.generate(17, (i) => i + 6); // 6 AM to 10 PM
    }

    final openTime = widget.club!.openTime;
    final closeTime = widget.club!.closeTime;

    try {
      final openParts = openTime.split(':');
      final closeParts = closeTime.split(':');

      int openHour = int.parse(openParts[0]);
      int closeHour = int.parse(closeParts[0]);

      // Adjust for overnight hours
      if (closeHour < openHour) {
        closeHour += 24;
      }

      final hours = <int>[];
      for (int h = openHour; h < closeHour; h++) {
        if (h < 24) {
          hours.add(h);
        }
      }

      return hours;
    } catch (_) {
      return List.generate(17, (i) => i + 6);
    }
  }

  List<int> _getAvailableEndHours(int startHour) {
    final allHours = _getAvailableHours();
    return allHours.where((h) => h > startHour).toList();
  }

  int _getPriceForSlot(int startHour, int endHour) {
    // Use the selected court's price
    return _selectedCourtPrice * (endHour - startHour);
  }

  void _autoConfirmIfComplete() {
    if (!_hasAutoConfirmed && _canConfirm) {
      _hasAutoConfirmed = true;
      widget.onConfirm();
    }
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _startHour = null;
      _endHour = null;
      _hasAutoConfirmed = false;
    });
    _animController.forward(from: 0);

    // Notify parent of partial selection
    if (_startHour != null && _endHour != null) {
      final startTime = TimeOfDay(hour: _startHour!, minute: 0);
      final endTime = TimeOfDay(hour: _endHour!, minute: 0);
      widget.onDateTimeSelected(date, startTime, endTime);
    }
  }

  void _onStartHourSelected(int hour) {
    setState(() {
      _startHour = hour;
      _endHour = null;
      _hasAutoConfirmed = false;
    });

    // Notify parent if both times are selected
    if (_selectedDate != null && _endHour != null) {
      final startTime = TimeOfDay(hour: _startHour!, minute: 0);
      final endTime = TimeOfDay(hour: _endHour!, minute: 0);
      widget.onDateTimeSelected(_selectedDate!, startTime, endTime);
    }
  }

  void _onEndHourSelected(int hour) {
    setState(() {
      _endHour = hour;
    });

    // Notify parent
    if (_selectedDate != null && _startHour != null) {
      final startTime = TimeOfDay(hour: _startHour!, minute: 0);
      final endTime = TimeOfDay(hour: _endHour!, minute: 0);
      widget.onDateTimeSelected(_selectedDate!, startTime, endTime);
    }

    // Auto confirm after selection
    if (_canConfirm) {
      _hasAutoConfirmed = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onConfirm();
        }
      });
    }
  }

  bool get _canConfirm {
    return _selectedDate != null && _startHour != null && _endHour != null;
  }

  String get _timeRangeLabel {
    if (_startHour != null && _endHour != null) {
      return '${_fmtH(_startHour!)} - ${_fmtH(_endHour!)}';
    }
    return '';
  }

  int get _durationHours {
    if (_startHour != null && _endHour != null) {
      return _endHour! - _startHour!;
    }
    return 0;
  }

  num get _totalPrice {
    if (_startHour != null && _endHour != null) {
      return _getPriceForSlot(_startHour!, _endHour!);
    }
    return 0.0;
  }

  List<int> get _availableHours {
    return _getAvailableHours();
  }

  List<int> get _toHours {
    if (_startHour == null) return [];
    return _getAvailableEndHours(_startHour!);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final weekDates = _weekDates;
    final dateSelected = _selectedDate != null;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // ── Section: Date ───────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'select_date'.tr(context),
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'choose_date_desc'.tr(context),
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.dark(
                          primary: AppTheme.kAccent,
                          onPrimary: Colors.black,
                          surface: isDark
                              ? const Color(0xFF1A1A2E)
                              : AppTheme.kLightCard,
                          onSurface: isDark
                              ? Colors.white
                              : AppTheme.kLightText,
                        ),
                        dialogBackgroundColor: isDark
                            ? const Color(0xFF1A1A2E)
                            : AppTheme.kLightCard,
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null &&
                    !DateUtils.isSameDay(_selectedDate, picked)) {
                  _onDateSelected(picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
                  ),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: AppTheme.kAccent,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Week label
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'week_of'
                    .tr(context)
                    .replaceAll(
                      '{date}',
                      '${_months[weekDates.first.month - 1]} ${weekDates.first.day}, ${weekDates.first.year}',
                    ),
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.kAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'current_week'.tr(context),
                  style: const TextStyle(
                    color: AppTheme.kAccent,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 7-day grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.70,
          ),
          itemCount: weekDates.length,
          itemBuilder: (_, i) {
            final d = weekDates[i];
            final sel =
                _selectedDate != null && DateUtils.isSameDay(d, _selectedDate!);
            final isToday = DateUtils.isSameDay(d, DateTime.now());
            final isWeekend =
                d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
            final isPast = d.isBefore(DateTime.now()) && !isToday;

            return GestureDetector(
              onTap: isPast ? null : () => _onDateSelected(d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.kAccent
                      : isToday
                      ? AppTheme.kAccent.withOpacity(0.15)
                      : isPast
                      ? (isDark
                            ? AppTheme.kCardAlt.withOpacity(0.5)
                            : AppTheme.kLightCardAlt.withOpacity(0.5))
                      : (isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel
                        ? AppTheme.kAccent
                        : isToday
                        ? AppTheme.kAccent.withOpacity(0.5)
                        : isPast
                        ? Colors.grey.withOpacity(0.3)
                        : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getTranslatedDay(_days[d.weekday - 1], context),
                      style: TextStyle(
                        color: sel
                            ? const Color(0xFF0A1828)
                            : isWeekend && !isPast
                            ? AppTheme.kAccent.withOpacity(0.7)
                            : isPast
                            ? Colors.grey.withOpacity(0.5)
                            : (isDark
                                  ? AppTheme.kTextSub
                                  : AppTheme.kLightTextSub),
                        fontSize: 8.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${d.day}',
                      style: TextStyle(
                        color: sel
                            ? const Color(0xFF0A1828)
                            : isToday
                            ? AppTheme.kAccent
                            : isPast
                            ? Colors.grey.withOpacity(0.5)
                            : (isDark ? Colors.white : AppTheme.kLightText),
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _getTranslatedMonth(
                        _months[d.month - 1],
                        context,
                      ).substring(0, 3),
                      style: TextStyle(
                        color: sel
                            ? const Color(0xFF0A1828).withOpacity(0.7)
                            : isPast
                            ? Colors.grey.withOpacity(0.5)
                            : (isDark
                                  ? AppTheme.kTextSub
                                  : AppTheme.kLightTextSub),
                        fontSize: 8,
                      ),
                    ),
                    if (isToday && !sel)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.kAccent,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // ── Section: Time ─────────────────────────────────────────────────
        if (dateSelected) ...[
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? AppTheme.kBorder
                              : AppTheme.kLightBorder,
                          thickness: 1,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.kCardAlt
                              : AppTheme.kLightCardAlt,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark
                                ? AppTheme.kBorder
                                : AppTheme.kLightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: AppTheme.kAccent,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'select_time'.tr(context),
                              style: TextStyle(
                                color: isDark
                                    ? Colors.white
                                    : AppTheme.kLightText,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Divider(
                          color: isDark
                              ? AppTheme.kBorder
                              : AppTheme.kLightBorder,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.kAccent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.kAccent.withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.event_rounded,
                          color: AppTheme.kAccent,
                          size: 15,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_getTranslatedDay(_days[_selectedDate!.weekday - 1], context)}, '
                          '${_getTranslatedMonth(_months[_selectedDate!.month - 1], context)} ${_selectedDate!.day} ${_selectedDate!.year}',
                          style: const TextStyle(
                            color: AppTheme.kAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _sectionLabel(
                    'from_label'.tr(context).toUpperCase(),
                    Icons.play_arrow_rounded,
                    const Color(0xFF4CAF50),
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _horizontalChips(
                    hours: _availableHours,
                    selected: _startHour,
                    selColor: const Color(0xFF4CAF50),
                    isDark: isDark,
                    onTap: _onStartHourSelected,
                  ),
                  const SizedBox(height: 20),

                  _sectionLabel(
                    'to_label'.tr(context).toUpperCase(),
                    Icons.stop_rounded,
                    Colors.redAccent,
                    isDark,
                  ),
                  const SizedBox(height: 10),
                  _horizontalChips(
                    hours: _toHours,
                    selected: _endHour,
                    selColor: Colors.redAccent,
                    isDark: isDark,
                    emptyMessage: _startHour == null
                        ? 'pick_start_time_first'.tr(context)
                        : 'no_available_end_times'.tr(context),
                    onTap: _onEndHourSelected,
                  ),

                  if (_canConfirm) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.kAccent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.kAccent.withOpacity(0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.timelapse_rounded,
                            color: AppTheme.kAccent,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _timeRangeLabel,
                                  style: const TextStyle(
                                    color: AppTheme.kAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '$_durationHours ${'hours'.tr(context)}',
                                  style: TextStyle(
                                    color: isDark
                                        ? AppTheme.kTextSub
                                        : AppTheme.kLightTextSub,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${_totalPrice.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white
                                      : AppTheme.kLightText,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '\$${_selectedCourtPrice.toStringAsFixed(0)}/hr',
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.kTextSub
                                      : AppTheme.kLightTextSub,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getTranslatedDay(String day, BuildContext context) {
    switch (day) {
      case 'Mon':
        return 'mon'.tr(context);
      case 'Tue':
        return 'tue'.tr(context);
      case 'Wed':
        return 'wed'.tr(context);
      case 'Thu':
        return 'thu'.tr(context);
      case 'Fri':
        return 'fri'.tr(context);
      case 'Sat':
        return 'sat'.tr(context);
      case 'Sun':
        return 'sun'.tr(context);
      default:
        return day;
    }
  }

  String _getTranslatedMonth(String month, BuildContext context) {
    switch (month) {
      case 'Jan':
        return 'jan'.tr(context);
      case 'Feb':
        return 'feb'.tr(context);
      case 'Mar':
        return 'mar'.tr(context);
      case 'Apr':
        return 'apr'.tr(context);
      case 'May':
        return 'may'.tr(context);
      case 'Jun':
        return 'jun'.tr(context);
      case 'Jul':
        return 'jul'.tr(context);
      case 'Aug':
        return 'aug'.tr(context);
      case 'Sep':
        return 'sep'.tr(context);
      case 'Oct':
        return 'oct'.tr(context);
      case 'Nov':
        return 'nov'.tr(context);
      case 'Dec':
        return 'dec'.tr(context);
      default:
        return month;
    }
  }

  Widget _sectionLabel(String label, IconData icon, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _horizontalChips({
    required List<int> hours,
    required int? selected,
    required Color selColor,
    required bool isDark,
    required ValueChanged<int> onTap,
    String emptyMessage = 'No available times',
  }) {
    if (hours.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          emptyMessage,
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 12.5,
          ),
        ),
      );
    }
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: hours.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final h = hours[i];
          final label = _fmtH(h);
          final sel = selected == h;

          return GestureDetector(
            onTap: () => onTap(h),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: sel
                    ? selColor
                    : (isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel
                      ? selColor
                      : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: sel
                      ? Colors.white
                      : (isDark ? Colors.white60 : AppTheme.kLightTextSub),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
