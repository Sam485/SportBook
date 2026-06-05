import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/booking_provider.dart';

class StepDateAndTime extends StatefulWidget {
  final VoidCallback onConfirm;
  const StepDateAndTime({super.key, required this.onConfirm});

  @override
  State<StepDateAndTime> createState() => _StepDateAndTimeState();
}

class _StepDateAndTimeState extends State<StepDateAndTime>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // ── Date helpers ────────────────────────────────────────────────────────────
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

  // ── Time helpers ────────────────────────────────────────────────────────────
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

    // Auto-select today's date after the first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoSelectTodayDate();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // Auto-select today's date when screen loads
  void _autoSelectTodayDate() {
    final p = context.read<BookingProvider>();
    final today = DateTime.now();

    // Only auto-select if no date is already selected
    if (p.selectedDate == null) {
      p.selectDate(today);
      // Trigger animation for time section
      _animController.forward(from: 0);
    }
  }

  void _onDateSelected(BookingProvider p, DateTime date) {
    p.selectDate(date);
    // Reset time selection when date changes
    p.clearTimeSelection();
    // Trigger animation for time section
    _animController.forward(from: 0);
  }

  // Check if the selected time range is already booked
  bool _isTimeRangeBooked(
    BookingProvider p,
    int court,
    DateTime date,
    String sport,
    int startHour,
    int endHour,
  ) {
    final bookedRanges = p.bookedRanges(court, date, sport);
    for (final range in bookedRanges) {
      // Check if the selected range overlaps with any booked range
      if (startHour < range[1] && endHour > range[0]) {
        return true;
      }
    }
    return false;
  }

  // Show alert dialog for already booked time
  void _showTimeBookedAlert(BuildContext context, int startHour, int endHour) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: const [
              Icon(Icons.event_busy_rounded, color: Colors.redAccent, size: 28),
              SizedBox(width: 12),
              Text(
                'Time Already Booked',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'The selected time slot is no longer available.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time_rounded,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_fmtH(startHour)} - ${_fmtH(endHour)}',
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Please select a different time slot.',
                style: TextStyle(fontSize: 13, color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK', style: TextStyle(fontSize: 16)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          elevation: 24,
        );
      },
    );
  }

  // Handle confirm with validation
  void _handleConfirm(BookingProvider p) {
    if (!p.canConfirm) return;

    final sport = p.selectedSport ?? '';
    final court = p.selectedCourt ?? 0;
    final date = p.selectedDate!;
    final startHour = p.startHour!;
    final endHour = p.endHour!;

    // Check if the selected time is already booked
    if (_isTimeRangeBooked(p, court, date, sport, startHour, endHour)) {
      _showTimeBookedAlert(context, startHour, endHour);
      // Clear the invalid time selection
      p.clearTimeSelection();
      return;
    }

    // If validation passes, proceed with confirmation
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();
    final weekDates = _weekDates;
    final dateSelected = p.selectedDate != null;

    final sport = p.selectedSport ?? '';
    final court = p.selectedCourt ?? 0;
    final date = p.selectedDate ?? DateTime.now();

    // Compute blocked ranges
    final bookedRanges = dateSelected
        ? p.bookedRanges(court, date, sport)
        : <List<int>>[];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        // ── Section: Date ───────────────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Date',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose a date for your booking',
                  style: TextStyle(color: AppTheme.kTextSub, fontSize: 13),
                ),
              ],
            ),
            // Calendar picker for future dates
            GestureDetector(
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: p.selectedDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.dark(
                          primary: AppTheme.kAccent,
                          onPrimary: Colors.black,
                          surface: Color(0xFF1A1A2E),
                          onSurface: Colors.white,
                        ),
                        dialogBackgroundColor: const Color(0xFF1A1A2E),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null &&
                    !DateUtils.isSameDay(picked, p.selectedDate)) {
                  _onDateSelected(p, picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.kCardAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.kBorder),
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
            color: AppTheme.kCardAlt,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week of ${_months[weekDates.first.month - 1]} ${weekDates.first.day}, ${weekDates.first.year}',
                style: const TextStyle(
                  color: AppTheme.kTextSub,
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
                child: const Text(
                  'Current Week',
                  style: TextStyle(
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
            childAspectRatio: 0.75,
          ),
          itemCount: weekDates.length,
          itemBuilder: (_, i) {
            final d = weekDates[i];
            final sel =
                p.selectedDate != null &&
                DateUtils.isSameDay(d, p.selectedDate!);
            final isToday = DateUtils.isSameDay(d, DateTime.now());
            final isWeekend =
                d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;
            final isPast = d.isBefore(DateTime.now()) && !isToday;

            return GestureDetector(
              onTap: isPast ? null : () => _onDateSelected(p, d),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.kAccent
                      : isToday
                      ? AppTheme.kAccent.withOpacity(0.15)
                      : isPast
                      ? AppTheme.kCardAlt.withOpacity(0.5)
                      : AppTheme.kCardAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel
                        ? AppTheme.kAccent
                        : isToday
                        ? AppTheme.kAccent.withOpacity(0.5)
                        : isPast
                        ? Colors.grey.withOpacity(0.3)
                        : AppTheme.kBorder,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _days[d.weekday - 1],
                      style: TextStyle(
                        color: sel
                            ? const Color(0xFF0A1828)
                            : isWeekend && !isPast
                            ? AppTheme.kAccent.withOpacity(0.7)
                            : isPast
                            ? Colors.grey.withOpacity(0.5)
                            : AppTheme.kTextSub,
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
                            : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      _months[d.month - 1].substring(0, 3),
                      style: TextStyle(
                        color: sel
                            ? const Color(0xFF0A1828).withOpacity(0.7)
                            : isPast
                            ? Colors.grey.withOpacity(0.5)
                            : AppTheme.kTextSub,
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
                    if (isPast && !sel)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),

        // ── Section: Time (animated reveal after date pick) ─────────────────
        if (dateSelected) ...[
          FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Divider with label
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: AppTheme.kBorder, thickness: 1),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.kCardAlt,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.kBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              color: AppTheme.kAccent,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Select Time',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Divider(color: AppTheme.kBorder, thickness: 1),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Selected date chip
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
                          '${_days[p.selectedDate!.weekday - 1]}, '
                          '${_months[p.selectedDate!.month - 1]} ${p.selectedDate!.day} ${p.selectedDate!.year}',
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

                  // Already booked indicator
                  if (bookedRanges.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.kCardAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(
                                Icons.event_busy_rounded,
                                color: Colors.redAccent,
                                size: 13,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Already booked on this court',
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: bookedRanges
                                .map(
                                  (r) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.redAccent.withOpacity(
                                          0.4,
                                        ),
                                      ),
                                    ),
                                    child: Text(
                                      '${_fmtH(r[0])} – ${_fmtH(r[1])}',
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── FROM chips ───────────────────────────────────────────
                  _sectionLabel(
                    'FROM',
                    Icons.play_arrow_rounded,
                    const Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 10),
                  _horizontalChips(
                    hours: _fromHours(p, court, date, sport),
                    selected: p.startHour,
                    selColor: const Color(0xFF4CAF50),
                    onTap: (h) {
                      p.selectStartHour(h);
                      p.clearEndHour();
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── TO chips ─────────────────────────────────────────────
                  _sectionLabel('TO', Icons.stop_rounded, Colors.redAccent),
                  const SizedBox(height: 10),
                  _horizontalChips(
                    hours: _toHours(p, court, date, sport),
                    selected: p.endHour,
                    selColor: Colors.redAccent,
                    emptyMessage: p.startHour == null
                        ? 'Pick a start time first'
                        : 'No available end times',
                    onTap: (h) => p.selectEndHour(h),
                  ),

                  // ── Live summary with confirm button ─────────────────────────
                  if (p.canConfirm) ...[
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
                                  p.timeRangeLabel,
                                  style: const TextStyle(
                                    color: AppTheme.kAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '${p.durationHours} hour${p.durationHours != 1 ? 's' : ''}',
                                  style: AppTheme.tsSub,
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '\$${p.totalPrice.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '\$${p.target?.pricePerHour.toStringAsFixed(0) ?? '0'}/hr',
                                style: AppTheme.tsSub,
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

  // ── From slots: whole hours 0–22, exclude booked ────────────────────────
  List<int> _fromHours(
    BookingProvider p,
    int court,
    DateTime date,
    String sport,
  ) {
    return List.generate(23, (i) => i).where((h) {
      for (final r in p.bookedRanges(court, date, sport)) {
        if (h >= r[0] && h < r[1]) return false;
      }
      return true;
    }).toList();
  }

  // ── To slots: whole hours after startHour, no conflict ──────────────────
  List<int> _toHours(
    BookingProvider p,
    int court,
    DateTime date,
    String sport,
  ) {
    if (p.startHour == null) return [];
    return List.generate(24, (i) => i).where((h) {
      if (h <= p.startHour!) return false;
      return !p.rangeConflicts(court, date, sport, p.startHour!, h);
    }).toList();
  }

  // ── Section label ────────────────────────────────────────────────────────
  Widget _sectionLabel(String label, IconData icon, Color color) {
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

  // ── Horizontal scrollable chips ──────────────────────────────────────────
  Widget _horizontalChips({
    required List<int> hours,
    required int? selected,
    required Color selColor,
    required ValueChanged<int> onTap,
    String emptyMessage = 'No available times',
  }) {
    if (hours.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          emptyMessage,
          style: const TextStyle(color: AppTheme.kTextSub, fontSize: 12.5),
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
                color: sel ? selColor : AppTheme.kCardAlt,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: sel ? selColor : AppTheme.kBorder,
                  width: sel ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: sel ? Colors.white : Colors.white60,
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
