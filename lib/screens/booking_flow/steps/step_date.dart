import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/booking_provider.dart';

class StepDate extends StatelessWidget {
  final VoidCallback onNext;
  const StepDate({super.key, required this.onNext});

  static final List<DateTime> _dates = List.generate(
    14,
    (i) => DateTime.now().add(Duration(days: i)),
  );

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
  static const _days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        const Text(
          'Select Date',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Choose a date for your booking',
          style: TextStyle(color: AppTheme.kTextSub, fontSize: 13),
        ),
        const SizedBox(height: 24),

        // ── Calendar-style grid (14 days, 7 per row) ───────────────────
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: _dates.length,
          itemBuilder: (_, i) {
            final d = _dates[i];
            final sel =
                p.selectedDate != null &&
                DateUtils.isSameDay(d, p.selectedDate!);
            final isToday = DateUtils.isSameDay(d, DateTime.now());
            final isWeekend =
                d.weekday == DateTime.saturday || d.weekday == DateTime.sunday;

            return GestureDetector(
              onTap: () {
                p.selectDate(d);
                Future.delayed(const Duration(milliseconds: 250), onNext);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                decoration: BoxDecoration(
                  color: sel
                      ? AppTheme.kAccent
                      : isToday
                      ? AppTheme.kAccent.withOpacity(0.15)
                      : AppTheme.kCardAlt,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: sel
                        ? AppTheme.kAccent
                        : isToday
                        ? AppTheme.kAccent.withOpacity(0.5)
                        : AppTheme.kBorder,
                    width: sel ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _days[d.weekday % 7],
                      style: TextStyle(
                        color: sel
                            ? const Color(0xFF0A1828)
                            : isWeekend
                            ? AppTheme.kAccent.withOpacity(0.7)
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
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
