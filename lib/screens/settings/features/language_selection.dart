import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme.dart';
import '../../../providers/language_provider.dart';
import '../../../translations/app_translations.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final languageProvider = Provider.of<LanguageProvider>(
      context,
      listen: false,
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.kCard : AppTheme.kLightCard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'select_language'.tr(context),
              style: TextStyle(
                color: isDark ? Colors.white : AppTheme.kLightText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildLanguageOption(
            context: context,
            language: 'English',
            code: 'en',
            icon: Icons.language,
            isDark: isDark,
            isSelected: _selectedLanguage == 'en',
            onTap: () async {
              setState(() => _selectedLanguage = 'en');
              await languageProvider.setLanguage('en');
              Navigator.pop(context, 'en');
            },
          ),
          _buildLanguageOption(
            context: context,
            language: 'ភាសាខ្មែរ',
            code: 'km',
            icon: Icons.translate,
            isDark: isDark,
            isSelected: _selectedLanguage == 'km',
            onTap: () async {
              setState(() => _selectedLanguage = 'km');
              await languageProvider.setLanguage('km');
              Navigator.pop(context, 'km');
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String language,
    required String code,
    required IconData icon,
    required bool isDark,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.kAccent.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppTheme.kAccent, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.kAccent.withOpacity(0.2)
                    : (isDark ? AppTheme.kCardAlt : AppTheme.kLightCardAlt),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppTheme.kAccent
                    : (isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: TextStyle(
                      color: isSelected
                          ? AppTheme.kAccent
                          : (isDark ? Colors.white : AppTheme.kLightText),
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    code == 'en' ? 'English (US)' : 'ភាសាខ្មែរ',
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
            if (isSelected)
              Icon(Icons.check_circle, color: AppTheme.kAccent, size: 24),
          ],
        ),
      ),
    );
  }
}
