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
  bool _isChecking = true;
  String _error = '';
  bool _isDisposed = false;
  final AuthService _authService = getIt<AuthService>();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _checkAuthStatus() async {
    // Wait a moment for everything to initialize
    await Future.delayed(const Duration(seconds: 1));

    try {
      if (!_isDisposed && mounted) {
        await _authService.checkAndRedirect(context);
      }
    } catch (e) {
      print('Auth check error: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _error = e.toString();
          _isChecking = false;
        });
      }
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
              if (_isChecking) ...[
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
              ] else if (_error.isNotEmpty) ...[
                Icon(Icons.error_outline_rounded, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading app',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppTheme.kLightText,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _error,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppTheme.kTextSub : AppTheme.kLightTextSub,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _checkAuthStatus,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.kAccent,
                    foregroundColor: const Color(0xFF0A1828),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
