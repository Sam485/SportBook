// In your splash screen or main.dart
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/core/theme.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Wait a moment for everything to initialize
    await Future.delayed(const Duration(seconds: 1));

    try {
      final tokenService = getIt<TokenService>();

      // Check if token exists and is valid
      final hasValidToken = await tokenService.hasValidTokenAsync();

      if (!mounted) return;

      if (hasValidToken) {
        // Navigate to home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // Check if we have a refresh token to try
        final refreshToken = await tokenService.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          // Try to refresh
          final refreshed = await tokenService.refreshAccessToken();
          if (refreshed && mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
            return;
          }
        }

        // No valid token, go to login
        if (mounted) {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    } catch (e) {
      print('Auth check error: $e');
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppTheme.kAccent),
            const SizedBox(height: 16),
            Text(
              'Loading...',
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
