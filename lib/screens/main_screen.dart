import 'package:flutter/material.dart';
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
    _PlaceholderScreen(icon: Icons.search_rounded,          label: 'Explore'),
    _PlaceholderScreen(icon: Icons.calendar_month_rounded,  label: 'Bookings'),
    _PlaceholderScreen(icon: Icons.group_rounded,           label: 'Players'),
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

class _PlaceholderScreen extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PlaceholderScreen({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Column(
      mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: Colors.white38, size: 48),
        const SizedBox(height: 12),
        Text(label, style: const TextStyle(color: Colors.white38, fontSize: 18)),
      ],
    )),
  );
}
