// feature/Auth/service/auth_service.dart
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';
import 'package:sportbook/routes/app_routes.dart';

class AuthService {
  TokenService? _tokenService;
  GlobalKey<NavigatorState>? _navigatorKey;

  // Lazy initialization to avoid circular dependencies
  TokenService get _tokenServiceInstance {
    _tokenService ??= getIt<TokenService>();
    return _tokenService!;
  }

  GlobalKey<NavigatorState> get _navigatorKeyInstance {
    try {
      _navigatorKey ??= getIt<GlobalKey<NavigatorState>>();
    } catch (e) {
      // If not registered, create a new one
      _navigatorKey = GlobalKey<NavigatorState>();
    }
    return _navigatorKey!;
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      return await _tokenServiceInstance.hasValidTokenAsync();
    } catch (e) {
      return false;
    }
  }

  // ✅ Always go to home screen first, then check auth in background
  Future<void> checkAndRedirectFromSplash(BuildContext context) async {
    // Always navigate to home first
    if (Navigator.canPop(context)) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }

    // ✅ Check auth after a short delay to allow navigation to complete
    Future.delayed(const Duration(milliseconds: 500), () {
      _checkAuthInBackground();
    });
  }

  // ✅ Check auth in background - NO NAVIGATION HERE
  Future<void> _checkAuthInBackground() async {
    try {
      final hasValidToken = await isAuthenticated();

      if (!hasValidToken) {
        // Try to refresh token
        final refreshToken = await _tokenServiceInstance.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshed = await _tokenServiceInstance.refreshAccessToken();
          if (!refreshed) {
            await _tokenServiceInstance.clearToken();
          }
        } else {
          // No token at all - clear everything
          await _tokenServiceInstance.clearToken();
        }
      }
    } catch (e) {
      print('Background auth check error: $e');
    }
  }

  // ✅ Check auth status and redirect appropriately (for other screens)
  Future<void> checkAndRedirect(BuildContext context) async {
    // Skip if already on login or splash screen
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == AppRoutes.login || currentRoute == AppRoutes.splash) {
      return;
    }

    final hasValidToken = await isAuthenticated();

    if (hasValidToken) {
      // Already authenticated, go to home if not already there
      if (currentRoute != AppRoutes.home) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } else {
      // Try to refresh token
      final refreshToken = await _tokenServiceInstance.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final refreshed = await _tokenServiceInstance.refreshAccessToken();
        if (refreshed) {
          if (currentRoute != AppRoutes.home) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
          return;
        }
      }

      // No valid token, go to login
      await _tokenServiceInstance.clearToken();
      if (currentRoute != AppRoutes.login) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  // Force logout - clear tokens and navigate to login
  Future<void> logout() async {
    try {
      await _tokenServiceInstance.clearToken();
    } catch (e) {
      print('Logout error: $e');
    }
    _navigateToLogin();
  }

  // Show session expired dialog and redirect to login
  void showSessionExpiredDialog(BuildContext context) {
    // Check if there's already a dialog showing
    if (ModalRoute.of(context)?.isCurrent != true) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text(
          'Your session has expired. Please login again to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              logout();
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  // Check token on app resume
  Future<void> checkTokenOnResume() async {
    try {
      final hasValidToken = await _tokenServiceInstance.hasValidTokenAsync();

      if (!hasValidToken) {
        final refreshToken = await _tokenServiceInstance.getRefreshToken();
        if (refreshToken != null && refreshToken.isNotEmpty) {
          final refreshed = await _tokenServiceInstance.refreshAccessToken();
          if (!refreshed) {
            await _tokenServiceInstance.clearToken();
            _navigateToLogin();
          }
        } else {
          await _tokenServiceInstance.clearToken();
          _navigateToLogin();
        }
      }
    } catch (e) {
      print('Token check on resume error: $e');
      await _tokenServiceInstance.clearToken();
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navState = _navigatorKeyInstance.currentState;
      if (navState == null) return;

      final currentRoute = ModalRoute.of(navState.context)?.settings.name;
      if (currentRoute != AppRoutes.login && currentRoute != AppRoutes.splash) {
        navState.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      }
    });
  }
}
