import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:sportbook/providers/theme_provider.dart';
import 'package:sportbook/translations/app_translations.dart';
import '../../core/theme.dart';

class AppBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const AppBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C1E34) : AppTheme.kLightCard,
          border: Border(
            top: BorderSide(
              color: isDark ? AppTheme.kBorder : AppTheme.kLightBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black38 : Colors.black12,
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: GNav(
              gap: 8,
              activeColor: isDark
                  ? const Color(0xFF0A1828)
                  : AppTheme.kLightText,
              color: isDark ? Colors.white38 : AppTheme.kLightTextSub,
              iconSize: 22,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              duration: const Duration(milliseconds: 350),
              tabBackgroundColor: AppTheme.kAccent, // Keep accent color same
              selectedIndex: selectedIndex,
              onTabChange: onTabChange,
              tabs: [
                GButton(icon: Icons.home_rounded, text: 'home'.tr(context)),
                GButton(
                  icon: Icons.search_rounded,
                  text: 'explore'.tr(context),
                ),
                GButton(
                  icon: Icons.calendar_month_rounded,
                  text: 'bookings'.tr(context),
                ),
                GButton(
                  icon: Icons.settings_rounded,
                  text: 'settings'.tr(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
