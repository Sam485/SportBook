// ─── Step 1: Category ─────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/booking_provider.dart';
import '../../../services/data_service.dart';

class StepCategory extends StatelessWidget {
  final VoidCallback onNext;
  const StepCategory({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<BookingProvider>();
    final sports = p.target?.sports ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        const Text('Select Sport', style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text('Choose a sport to book at ${p.target?.name ?? ''}',
            style: AppTheme.tsSub),
        const SizedBox(height: 24),

        ...sports.map((sport) {
          final sel = p.selectedSport == sport;
          return GestureDetector(
            onTap: () {
              p.selectSport(sport);
              Future.delayed(const Duration(milliseconds: 200), onNext);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: sel ? AppTheme.kAccent.withOpacity(0.15) : AppTheme.kCard,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                    color: sel ? AppTheme.kAccent : AppTheme.kBorder,
                    width: sel ? 2 : 1),
                boxShadow: sel ? [BoxShadow(
                    color: AppTheme.kAccent.withOpacity(0.25),
                    blurRadius: 12, offset: const Offset(0, 4))] : null,
              ),
              child: Row(children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: sel
                        ? AppTheme.kAccent.withOpacity(0.2)
                        : AppTheme.kCardAlt,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: sel ? AppTheme.kAccent : AppTheme.kBorder),
                  ),
                  alignment: Alignment.center,
                  child: Text(DataService.emojiFor(sport),
                      style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(sport, style: TextStyle(
                        color: sel ? AppTheme.kAccent : Colors.white,
                        fontSize: 16, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text(_subtitle(sport), style: AppTheme.tsSub),
                  ],
                )),
                Icon(
                  sel
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: sel ? AppTheme.kAccent : AppTheme.kTextSub,
                  size: 22,
                ),
              ]),
            ),
          );
        }),
      ],
    );
  }

  String _subtitle(String sport) {
    switch (sport) {
      case 'Football':   return 'Book a full-size pitch or mini court';
      case 'Badminton':  return 'Indoor court with synthetic surface';
      case 'Tennis':     return 'Hard court or clay surface';
      case 'Basketball': return '3v3 or 5v5 full court';
      case 'Gym':        return 'Book a personal trainer session';
      default:           return 'Book your session';
    }
  }
}
