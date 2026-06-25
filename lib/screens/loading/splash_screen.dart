// screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/screens/main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isNavigated) {
        _isNavigated = true;
        _navigateToMain();
      }
    });
  }

  void _navigateToMain() {
    // ✅ Navigate to MainScreen and clear the stack
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
      (route) => false, // Remove all previous routes
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppTheme.kBg, AppTheme.kCard]
                : [AppTheme.kLightBg, AppTheme.kLightCard],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.kAccent,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.kAccent.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(Icons.sports, color: Colors.white, size: 50),
              ),
              const SizedBox(height: 24),
              Text(
                'SportMate',
                style: TextStyle(
                  color: isDark ? Colors.white : AppTheme.kLightText,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Book Your Game Today!',
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 40),
              const CircularProgressIndicator(
                color: AppTheme.kAccent,
                strokeWidth: 3,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(
                  color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
