import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sportbook/translations/app_translations.dart';
import '../../../core/theme.dart';
import '../../../providers/theme_provider.dart';

class AppearanceSelector extends StatelessWidget {
  final String currentTheme;

  const AppearanceSelector({super.key, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'appearance'.tr(context),
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildThemeOption(
                  context: context,
                  title: 'light_mode'.tr(context),
                  icon: Icons.light_mode,
                  themeValue: 'light',
                  currentTheme: currentTheme,
                  onTap: () {
                    themeProvider.setTheme('light');
                    Navigator.pop(context, 'light');
                  },
                ),
                _buildThemeOption(
                  context: context,
                  title: 'dark_mode'.tr(context),
                  icon: Icons.dark_mode,
                  themeValue: 'dark',
                  currentTheme: currentTheme,
                  onTap: () {
                    themeProvider.setTheme('dark');
                    Navigator.pop(context, 'dark');
                  },
                ),
                _buildThemeOption(
                  context: context,
                  title: 'system_default'.tr(context),
                  icon: Icons.settings,
                  themeValue: 'system',
                  currentTheme: currentTheme,
                  onTap: () {
                    themeProvider.setTheme('system');
                    Navigator.pop(context, 'system');
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required String title,
    required IconData icon,
    required String themeValue,
    required String currentTheme,
    required VoidCallback onTap,
  }) {
    final isSelected = currentTheme == themeValue;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? AppTheme.kAccent.withOpacity(0.2)
                    : AppTheme.kAccent.withOpacity(0.1))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.kAccent
                : (isDark ? AppTheme.kBorder : AppTheme.kLightBorder),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.kAccent
                  : (isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub),
              size: 28,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  color: isSelected
                      ? AppTheme.kAccent
                      : (isDark ? Colors.white : AppTheme.kLightText),
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.kAccent, size: 24),
          ],
        ),
      ),
    );
  }
}
