import 'package:flutter/material.dart';
import '../../../core/theme.dart';
import '../../../translations/app_translations.dart';

class StepCategory extends StatelessWidget {
  final VoidCallback onNext;
  final Function(String) onCategorySelected;
  final String? selectedCategory;
  final List<dynamic> categories;

  const StepCategory({
    super.key,
    required this.onNext,
    required this.onCategorySelected,
    this.selectedCategory,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'choose_sport_desc'.tr(context),
          style: TextStyle(
            color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 24),

        ...categories.map((category) {
          final categoryStr = category.toString();
          final sel = selectedCategory == categoryStr;
          return GestureDetector(
            onTap: () {
              onCategorySelected(categoryStr);
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
                      _getEmojiForCategory(categoryStr),
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTranslatedCategoryName(categoryStr, context),
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
                          _subtitle(categoryStr, context),
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

  String _getEmojiForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'football':
      case 'soccer':
        return '⚽';
      case 'badminton':
        return '🏸';
      case 'tennis':
        return '🎾';
      case 'basketball':
        return '🏀';
      case 'gym':
      case 'fitness':
        return '🏋️';
      case 'swimming':
        return '🏊';
      case 'yoga':
        return '🧘';
      case 'boxing':
        return '🥊';
      case 'cycling':
        return '🚴';
      case 'running':
        return '🏃';
      default:
        return '🏅';
    }
  }

  String _getTranslatedCategoryName(String category, BuildContext context) {
    switch (category.toLowerCase()) {
      case 'football':
      case 'soccer':
        return 'sport_football'.tr(context);
      case 'badminton':
        return 'sport_badminton'.tr(context);
      case 'tennis':
        return 'sport_tennis'.tr(context);
      case 'basketball':
        return 'sport_basketball'.tr(context);
      case 'gym':
      case 'fitness':
        return 'sport_gym'.tr(context);
      case 'swimming':
        return 'sport_swimming'.tr(context);
      case 'yoga':
        return 'sport_yoga'.tr(context);
      case 'boxing':
        return 'sport_boxing'.tr(context);
      case 'cycling':
        return 'sport_cycling'.tr(context);
      case 'running':
        return 'sport_running'.tr(context);
      default:
        return category;
    }
  }

  String _subtitle(String category, BuildContext context) {
    switch (category.toLowerCase()) {
      case 'football':
      case 'soccer':
        return 'football_subtitle'.tr(context);
      case 'badminton':
        return 'badminton_subtitle'.tr(context);
      case 'tennis':
        return 'tennis_subtitle'.tr(context);
      case 'basketball':
        return 'basketball_subtitle'.tr(context);
      case 'gym':
      case 'fitness':
        return 'gym_subtitle'.tr(context);
      case 'swimming':
        return 'swimming_subtitle'.tr(context);
      case 'yoga':
        return 'yoga_subtitle'.tr(context);
      case 'boxing':
        return 'boxing_subtitle'.tr(context);
      case 'cycling':
        return 'cycling_subtitle'.tr(context);
      case 'running':
        return 'running_subtitle'.tr(context);
      default:
        return 'book_your_session'.tr(context);
    }
  }
}
