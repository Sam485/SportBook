import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // ── Palette ──────────────────────────────────────────────────────────────
  static const kBg = Color(0xFF0A1828);
  static const kCard = Color(0xFF0F2440);
  static const kCardAlt = Color(0xFF132D4E);
  static const kBorder = Color(0xFF1E3A5F);
  static const kAccent = Color(0xFF29B6F6);
  static const kTextSub = Color(0xFF6B9BBF);

  // ── ThemeData ─────────────────────────────────────────────────────────────
  static ThemeData get dark => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: kBg,
    colorScheme: const ColorScheme.dark(
      primary: kAccent,
      surface: kCard,
      background: kBg,
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

  // ── Text styles ───────────────────────────────────────────────────────────
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

  // ── Elevated Button Style ────────────────────────────────────────────────────

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

  // ── TextField helpers ────────────────────────────────────────────────────
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
}
