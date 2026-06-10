// ─── Step 1: Category ─────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/booking_provider.dart';
import '../../../services/data_service.dart';
import '../../../translations/app_translations.dart';

class StepCategory extends StatelessWidget {
  final VoidCallback onNext;
  const StepCategory({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = context.watch<BookingProvider>();
    final sports = p.target?.sports ?? [];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      children: [
        Text(
          'select_sport'.tr(context),
          style: TextStyle(
            color: isDark ? Colors.white : AppTheme.kLightText,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'choose_sport_at'
              .tr(context)
              .replaceAll('{name}', p.target?.name ?? ''),
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
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
                color: sel
                    ? AppTheme.kAccent.withOpacity(0.15)
                    : (isDark ? AppTheme.kCard : AppTheme.kLightCard),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: sel
                      ? AppTheme.kAccent
                      : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
                  width: sel ? 2 : 1,
                ),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: AppTheme.kAccent.withOpacity(0.25),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: sel
                          ? AppTheme.kAccent.withOpacity(0.2)
                          : (isDark
                                ? AppTheme.kCardAlt
                                : AppTheme.kLightCardAlt),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: sel
                            ? AppTheme.kAccent
                            : (isDark
                                  ? AppTheme.kBorder
                                  : AppTheme.kLightBorder),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      DataService.emojiFor(sport),
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTranslatedSportName(sport, context),
                          style: TextStyle(
                            color: sel
                                ? AppTheme.kAccent
                                : (isDark ? Colors.white : AppTheme.kLightText),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          _subtitle(sport, context),
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
                  Icon(
                    sel
                        ? Icons.check_circle_rounded
                        : Icons.chevron_right_rounded,
                    color: sel
                        ? AppTheme.kAccent
                        : (isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub),
                    size: 22,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ],
    );
  }

  String _getTranslatedSportName(String sport, BuildContext context) {
    switch (sport.toLowerCase()) {
      case 'football':
        return 'sport_football'.tr(context);
      case 'badminton':
        return 'sport_badminton'.tr(context);
      case 'tennis':
        return 'sport_tennis'.tr(context);
      case 'basketball':
        return 'sport_basketball'.tr(context);
      case 'gym':
        return 'sport_gym'.tr(context);
      default:
        return sport;
    }
  }

  String _subtitle(String sport, BuildContext context) {
    switch (sport.toLowerCase()) {
      case 'football':
        return 'football_subtitle'.tr(context);
      case 'badminton':
        return 'badminton_subtitle'.tr(context);
      case 'tennis':
        return 'tennis_subtitle'.tr(context);
      case 'basketball':
        return 'basketball_subtitle'.tr(context);
      case 'gym':
        return 'gym_subtitle'.tr(context);
      default:
        return 'book_your_session'.tr(context);
    }
  }
}
