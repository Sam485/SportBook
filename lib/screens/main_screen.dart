import 'package:flutter/material.dart';
import 'package:sportbook/screens/bookings/bookings_screen.dart';
import 'package:sportbook/screens/explore/explore_screen.dart';
import 'package:sportbook/screens/settings/settings_screen.dart';
import '../widgets/navbar/bottom_navbar.dart';
import 'home/home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  static const _screens = [
    HomeScreen(),
    ExploreScreen(),
    BookingsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: AppBottomNavBar(
        selectedIndex: _index,
        onTabChange: (i) => setState(() => _index = i),
      ),
    );
  }
}
