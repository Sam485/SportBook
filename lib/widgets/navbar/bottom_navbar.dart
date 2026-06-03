import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0C1E34),
        border: Border(top: BorderSide(color: AppTheme.kBorder, width: 1)),
        boxShadow: [BoxShadow(
            color: Colors.black38, blurRadius: 20,
            offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: GNav(
            gap: 8,
            activeColor: const Color(0xFF0A1828),
            color: Colors.white38,
            iconSize: 22,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            duration: const Duration(milliseconds: 350),
            tabBackgroundColor: AppTheme.kAccent,
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
            tabs: const [
              GButton(icon: Icons.home_rounded,            text: 'Home'),
              GButton(icon: Icons.search_rounded,          text: 'Explore'),
              GButton(icon: Icons.calendar_month_rounded,  text: 'Bookings'),
              GButton(icon: Icons.group_rounded,           text: 'Players'),
              GButton(icon: Icons.settings_rounded,        text: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
