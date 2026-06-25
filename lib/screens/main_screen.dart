// main_screen.dart
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

  // ✅ Use late initialization with proper keys
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    // ✅ Initialize screens once with proper keys
    _screens = [
      const HomeScreen(key: ValueKey('home_screen')),
      const ExploreScreen(key: ValueKey('explore_screen')),
      BookingsScreen(isView: false, key: const ValueKey('bookings_screen')),
      const SettingsScreen(key: ValueKey('settings_screen')),
    ];
  }

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
