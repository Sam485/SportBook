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
