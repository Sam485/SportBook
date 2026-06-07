import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class AppearanceSelector extends StatefulWidget {
  final String currentTheme;

  const AppearanceSelector({super.key, required this.currentTheme});

  @override
  State<AppearanceSelector> createState() => _AppearanceSelectorState();
}

class _AppearanceSelectorState extends State<AppearanceSelector> {
  late String _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedTheme = widget.currentTheme;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.kCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Select Theme',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _themeOption('Dark Mode', 'dark', Icons.dark_mode),
          _themeOption('Light Mode', 'light', Icons.light_mode),
          _themeOption('System Default', 'system', Icons.settings),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _themeOption(String title, String value, IconData icon) {
    final isSelected = _selectedTheme == value;
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.kAccent.withOpacity(0.2)
              : AppTheme.kCardAlt,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: isSelected ? AppTheme.kAccent : Colors.white70,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.kAccent : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppTheme.kAccent)
          : null,
      onTap: () {
        setState(() {
          _selectedTheme = value;
        });
        Navigator.pop(context, value);
      },
    );
  }
}
