// screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Auth/service/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = getIt<AuthService>();

  @override
  void initState() {
    super.initState();
    // ✅ Use WidgetsBinding to ensure the widget is built before navigating
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _checkAuthStatus();
      }
    });
  }

  Future<void> _checkAuthStatus() async {
    try {
      if (mounted) {
        await _authService.checkAndRedirectFromSplash(context);
      }
    } catch (e) {
      print('Auth check error: $e');
      // ✅ Don't set state here - just let the error be handled
    }
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
              // App Logo/Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.kAccent,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.kAccent.withOpacity(0.3),
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
