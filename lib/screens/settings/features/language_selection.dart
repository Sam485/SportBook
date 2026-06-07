import 'package:flutter/material.dart';
import '../../../core/theme.dart';

class LanguageSelector extends StatefulWidget {
  final String currentLanguage;

  const LanguageSelector({super.key, required this.currentLanguage});

  @override
  State<LanguageSelector> createState() => _LanguageSelectorState();
}

class _LanguageSelectorState extends State<LanguageSelector> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLanguage;
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
              'Select Language',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _languageOption('English', 'EN', Icons.language),
          _languageOption('Khmer', 'KM', Icons.translate),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _languageOption(String language, String code, IconData icon) {
    final isSelected = _selectedLanguage == code;
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
        language,
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
          _selectedLanguage = code;
        });
        // Return selected language
        Navigator.pop(context, code);
      },
    );
  }
}
