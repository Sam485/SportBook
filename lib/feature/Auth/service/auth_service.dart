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

  // ✅ Initialize app - check auth and navigate accordingly
  Future<void> initializeApp(BuildContext context) async {
    final hasValidToken = await isAuthenticated();

    if (hasValidToken) {
      // User is authenticated, go to home
      // ignore: use_build_context_synchronously
      _navigateToHome(context);
    } else {
      // Try to refresh token
      final refreshToken = await _tokenServiceInstance.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final refreshed = await _tokenServiceInstance.refreshAccessToken();
        if (refreshed) {
          // Token refreshed successfully, go to home
          // ignore: use_build_context_synchronously
          _navigateToHome(context);
          return;
        }
      }

      // No valid token, go to login
      await _tokenServiceInstance.clearToken();
      // ignore: use_build_context_synchronously
      _navigateToLogin(context);
    }
  }

  // ✅ Check auth status and redirect appropriately (for other screens)
  Future<void> checkAndRedirect(BuildContext context) async {
    // Skip if already on login or signup screen
    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == AppRoutes.login || currentRoute == AppRoutes.signup) {
      return;
    }

    final hasValidToken = await isAuthenticated();

    if (hasValidToken) {
      // Already authenticated, go to home if not already there
      if (currentRoute != AppRoutes.home) {
        // ignore: use_build_context_synchronously
        _navigateToHome(context);
      }
    } else {
      // Try to refresh token
      final refreshToken = await _tokenServiceInstance.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        final refreshed = await _tokenServiceInstance.refreshAccessToken();
        if (refreshed) {
          if (currentRoute != AppRoutes.home) {
            // ignore: use_build_context_synchronously
            _navigateToHome(context);
          }
          return;
        }
      }

      // No valid token, go to login
      await _tokenServiceInstance.clearToken();
      if (currentRoute != AppRoutes.login) {
        // ignore: use_build_context_synchronously
        _navigateToLogin(context);
      }
    }
  }

  // Force logout - clear tokens and navigate to login
  Future<void> logout() async {
    try {
      await _tokenServiceInstance.clearToken();
      // ignore: empty_catches
    } catch (e) {}
    _navigateToLoginUsingKey();
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
            _navigateToLoginUsingKey();
          }
        } else {
          await _tokenServiceInstance.clearToken();
          _navigateToLoginUsingKey();
        }
      }
    } catch (e) {
      await _tokenServiceInstance.clearToken();
      _navigateToLoginUsingKey();
    }
  }

  // ✅ Navigate to home (with proper stack clearing)
  void _navigateToHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  // ✅ Navigate to login (with proper stack clearing)
  void _navigateToLogin(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  // ✅ Navigate to login using navigator key (for background tasks)
  void _navigateToLoginUsingKey() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final navState = _navigatorKeyInstance.currentState;
      if (navState == null) return;

      final currentRoute = ModalRoute.of(navState.context)?.settings.name;
      if (currentRoute != AppRoutes.login && currentRoute != AppRoutes.signup) {
        navState.pushNamedAndRemoveUntil(
          AppRoutes.login, // ✅ Navigate to login, not home
          (route) => false,
        );
      }
    });
  }
}
