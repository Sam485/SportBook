import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // ── Dark Palette ──────────────────────────────────────────────────────────
  static const kBg = Color(0xFF0A1828);
  static const kCard = Color(0xFF0F2440);
  static const kCardAlt = Color(0xFF132D4E);
  static const kBorder = Color(0xFF1E3A5F);
  static const kAccent = Color(0xFF29B6F6);
  static const kTextSub = Color(0xFF6B9BBF);

  // ── Light Palette ─────────────────────────────────────────────────────────
  static const kLightBg = Color(0xFFF0F6FF);
  static const kLightCard = Color(0xFFFFFFFF);
  static const kLightCardAlt = Color(0xFFE8F2FF);
  static const kLightBorder = Color(0xFFCCDFF5);
  static const kLightTextSub = Color(0xFF5A7FA8);
  static const kLightText = Color(0xFF0D2137);

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    colorScheme: const ColorScheme.dark(
      primary: kAccent,
      surface: kCard,
      background: kBg,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kAccent : Colors.grey,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? kAccent.withOpacity(0.4)
            : Colors.grey.withOpacity(0.3),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kBg,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  static ThemeData get light => ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: kLightBg,
    colorScheme: const ColorScheme.light(
      primary: kAccent,
      surface: kLightCard,
      background: kLightBg,
      onBackground: kLightText,
      onSurface: kLightText,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? kAccent : Colors.grey,
      ),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected)
            ? kAccent.withOpacity(0.4)
            : Colors.grey.withOpacity(0.3),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: kLightBg,
      elevation: 0,
      iconTheme: IconThemeData(color: kLightText),
      titleTextStyle: TextStyle(
        color: kLightText,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );

  // ── Adaptive helpers (use these in widgets instead of hardcoded colors) ───

  /// Background color
  static Color bg(BuildContext context) => _isDark(context) ? kBg : kLightBg;

  /// Card color
  static Color card(BuildContext context) =>
      _isDark(context) ? kCard : kLightCard;

  /// Alt card color
  static Color cardAlt(BuildContext context) =>
      _isDark(context) ? kCardAlt : kLightCardAlt;

  /// Border color
  static Color border(BuildContext context) =>
      _isDark(context) ? kBorder : kLightBorder;

  /// Sub text color
  static Color textSub(BuildContext context) =>
      _isDark(context) ? kTextSub : kLightTextSub;

  /// Primary text color
  static Color textPrimary(BuildContext context) =>
      _isDark(context) ? Colors.white : kLightText;

  /// Secondary text color (white70 equivalent)
  static Color textSecondary(BuildContext context) =>
      _isDark(context) ? Colors.white70 : kLightText.withOpacity(0.75);

  static bool _isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Text styles ───────────────────────────────────────────────────────────
  // Static styles kept for backward compat — use adaptive() versions in new widgets
  static const tsTitle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static const tsBody = TextStyle(color: Colors.white70, fontSize: 13);
  static const tsSub = TextStyle(color: kTextSub, fontSize: 11.5);
  static const tsAccent = TextStyle(
    color: kAccent,
    fontSize: 13,
    fontWeight: FontWeight.w700,
  );
  static const tsLabel = TextStyle(fontSize: 16, color: Colors.white);
  static const tsButtonLabel = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  // Adaptive text styles
  static TextStyle tsTitleAdaptive(BuildContext context) => TextStyle(
    color: textPrimary(context),
    fontSize: 18,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.3,
  );

  static TextStyle tsBodyAdaptive(BuildContext context) =>
      TextStyle(color: textSecondary(context), fontSize: 13);

  static TextStyle tsSubAdaptive(BuildContext context) =>
      TextStyle(color: textSub(context), fontSize: 11.5);

  static TextStyle tsLabelAdaptive(BuildContext context) =>
      TextStyle(fontSize: 16, color: textPrimary(context));

  // ── Button Styles ─────────────────────────────────────────────────────────
  static ButtonStyle elevatedButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? kAccent,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  static ButtonStyle outlineButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    return OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFF2E3548), width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  // ── TextField helpers ─────────────────────────────────────────────────────
  static InputDecoration textFieldDecoration(
    IconData icon,
    String label, {
    double radius = 20,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: 'Enter your $label',
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: AppTheme.kAccent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // ── Decoration helpers ────────────────────────────────────────────────────
  static BoxDecoration cardDecoration({double radius = 20}) => BoxDecoration(
    color: kCard,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: kBorder),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 12,
        offset: const Offset(0, 5),
      ),
    ],
  );

  /// Adaptive card decoration — use this in new widgets
  static BoxDecoration cardDecorationAdaptive(
    BuildContext context, {
    double radius = 20,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDark ? kCard : kLightCard,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: isDark ? kBorder : kLightBorder),
      boxShadow: [
        BoxShadow(
          color: isDark
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // Add this helper method to AppTheme
  static Color accent(BuildContext context) => kAccent; // Accent stays the same
}
