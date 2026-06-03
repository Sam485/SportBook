import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/booking_provider.dart';

class StepTime extends StatelessWidget {
  final VoidCallback onConfirm;
  const StepTime({super.key, required this.onConfirm});

  static String _fmtH(int h) {
    final p  = h >= 12 ? 'PM' : 'AM';
    final hr = h % 12 == 0 ? 12 : h % 12;
    return '$hr:00 $p';
  }

  // ── All 24 hours ────────────────────────────────────────────────────────────
  static final List<int> _allHours = List.generate(24, (i) => i);

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();

    // Filter start hours: hide any hour already booked for this court+date+sport
    final sport = p.selectedSport ?? '';
    final court = p.selectedCourt ?? 0;
    final date  = p.selectedDate ?? DateTime.now();

    List<int> startHours = _allHours.where((h) {
      for (final r in p.bookedRanges(court, date, sport)) {
        if (h >= r[0] && h < r[1]) return false;
      }
      return true;
    }).toList();

    List<int> endHours = _allHours.where((h) {
      if (p.startHour == null) return false;
      if (h <= p.startHour!) return false;
      return !p.rangeConflicts(court, date, sport, p.startHour!, h);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        const Text('Select Time Range', style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Pick a start and end time for your session',
            style: TextStyle(color: AppTheme.kTextSub, fontSize: 13)),
        const SizedBox(height: 20),

        // ── Already booked indicator ─────────────────────────────────────
        _bookedSlotsInfo(p, court, date, sport),

        // ── Start time ───────────────────────────────────────────────────
        _rowLabel('Start Time', Icons.play_arrow_rounded,
            const Color(0xFF4CAF50), p.startHour),
        const SizedBox(height: 10),
        _hourChips(
          hours: startHours,
          selected: p.startHour,
          inRangeCheck: (h) => p.startHour != null && p.endHour != null
              && h > p.startHour! && h < p.endHour!,
          selColor: const Color(0xFF4CAF50),
          onTap: (h) => p.selectStartHour(h),
        ),
        const SizedBox(height: 20),

        // ── End time ─────────────────────────────────────────────────────
        _rowLabel('End Time', Icons.stop_rounded,
            Colors.redAccent, p.endHour),
        const SizedBox(height: 10),
        _hourChips(
          hours: endHours,
          selected: p.endHour,
          inRangeCheck: (h) => p.startHour != null && p.endHour != null
              && h > p.startHour! && h < p.endHour!,
          selColor: Colors.redAccent,
          onTap: (h) => p.selectEndHour(h),
          emptyMessage: p.startHour == null
              ? 'Pick a start time first' : 'No available end times',
        ),

        // ── Live summary chip ─────────────────────────────────────────────
        if (p.canConfirm) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.kAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.kAccent.withOpacity(0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.timelapse_rounded, color: AppTheme.kAccent, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(p.timeRangeLabel, style: const TextStyle(
                      color: AppTheme.kAccent,
                      fontSize: 14, fontWeight: FontWeight.w800)),
                  Text('${p.durationHours} hour${p.durationHours != 1 ? 's' : ''}',
                      style: AppTheme.tsSub),
                ]),
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('\$${p.totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(color: Colors.white,
                        fontSize: 18, fontWeight: FontWeight.w800)),
                Text('\$${p.target?.pricePerHour.toStringAsFixed(0) ?? '0'}/hr',
                    style: AppTheme.tsSub),
              ]),
            ]),
          ),
        ],
      ],
    );
  }

  // ── Already booked info ───────────────────────────────────────────────────
  Widget _bookedSlotsInfo(BookingProvider p, int court, DateTime date, String sport) {
    final ranges = p.bookedRanges(court, date, sport);
    if (ranges.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.kCardAlt,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Row(children: [
          Icon(Icons.event_busy_rounded, color: Colors.redAccent, size: 13),
          SizedBox(width: 6),
          Text('Already booked on this court',
              style: TextStyle(color: Colors.white60,
                  fontSize: 12, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        Wrap(spacing: 6, runSpacing: 4,
          children: ranges.map((r) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.redAccent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.redAccent.withOpacity(0.4)),
            ),
            child: Text('${_fmtH(r[0])} – ${_fmtH(r[1])}',
                style: const TextStyle(color: Colors.redAccent,
                    fontSize: 11, fontWeight: FontWeight.w600)),
          )).toList()),
      ]),
    );
  }

  // ── Row label ─────────────────────────────────────────────────────────────
  Widget _rowLabel(String label, IconData icon, Color color, int? selected) =>
      Row(children: [
        Container(width: 4, height: 14,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 6),
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(color: color,
            fontSize: 13, fontWeight: FontWeight.w700)),
        if (selected != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Text(_fmtH(selected), style: TextStyle(
                color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ],
      ]);

  // ── Hour chips ────────────────────────────────────────────────────────────
  Widget _hourChips({
    required List<int> hours,
    required int? selected,
    required bool Function(int) inRangeCheck,
    required Color selColor,
    required ValueChanged<int> onTap,
    String emptyMessage = 'No available times',
  }) {
    if (hours.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Text(emptyMessage,
            style: const TextStyle(color: AppTheme.kTextSub, fontSize: 12.5)),
      );
    }
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: hours.map((h) {
        final sel   = selected == h;
        final inRng = inRangeCheck(h);
        return GestureDetector(
          onTap: () => onTap(h),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: sel   ? selColor
                  : inRng ? AppTheme.kAccent.withOpacity(0.12)
                           : AppTheme.kCardAlt,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: sel   ? selColor
                    : inRng ? AppTheme.kAccent.withOpacity(0.4)
                             : AppTheme.kBorder,
              ),
            ),
            child: Text(_fmtH(h), style: TextStyle(
              color: sel   ? Colors.white
                  : inRng ? AppTheme.kAccent
                           : Colors.white60,
              fontSize: 12, fontWeight: FontWeight.w700,
            )),
          ),
        );
      }).toList(),
    );
  }
}
