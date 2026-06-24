import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/Auth/service/auth_service.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';

class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
  _pendingRequests = [];

  // Lazy initialization to avoid circular dependencies
  AuthService? _authService;
  TokenService? _tokenService;

  AuthService get _authServiceInstance {
    _authService ??= getIt<AuthService>();
    return _authService!;
  }

  TokenService get _tokenServiceInstance {
    _tokenService ??= getIt<TokenService>();
    return _tokenService!;
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip adding token for auth endpoints
    if (_isAuthEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    try {
      // Check if token exists and is valid
      final token = await _tokenServiceInstance.getAccessToken();
      if (token != null && token.isNotEmpty) {
        // Check if token is expired
        final isValid = await _tokenServiceInstance.hasValidTokenAsync();
        if (!isValid) {
          // Token expired - try to refresh
          final refreshed = await _tokenServiceInstance.refreshAccessToken();
          if (!refreshed) {
            // Refresh failed - redirect to login
            _authServiceInstance.logout();
            handler.next(options);
            return;
          }
        }
        // Get the token after potential refresh
        final accessToken = await _tokenServiceInstance.getAccessToken();
        if (accessToken != null && accessToken.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
      }
    } catch (e) {
      print('Error adding auth token: $e');
      // Don't call logout here to avoid recursion
    }

    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle token expiration (401)
    if (err.response?.statusCode == 401 &&
        !_isAuthEndpoint(err.requestOptions.path)) {
      // Prevent recursive refresh attempts
      if (_isRefreshing) {
        _pendingRequests.add((options: err.requestOptions, handler: handler));
        return;
      }

      try {
        _isRefreshing = true;

        // Try to refresh the token
        final refreshed = await _tokenServiceInstance.refreshAccessToken();

        if (refreshed) {
          // Get new token
          final newToken = await _tokenServiceInstance.getAccessToken();
          if (newToken != null && newToken.isNotEmpty) {
            // Update the original request with new token
            err.requestOptions.headers['Authorization'] = 'Bearer $newToken';

            // Retry the original request
            final dio = getIt<Dio>();
            final response = await dio.fetch(err.requestOptions);

            // Process pending requests
            _isRefreshing = false;
            for (final pending in _pendingRequests) {
              pending.options.headers['Authorization'] = 'Bearer $newToken';
              try {
                final resp = await dio.fetch(pending.options);
                pending.handler.resolve(resp);
              } catch (e) {
                pending.handler.reject(e as DioException);
              }
            }
            _pendingRequests.clear();

            handler.resolve(response);
            return;
          }
        }

        // Refresh failed - clear tokens and redirect to login
        _isRefreshing = false;
        _pendingRequests.clear();

        // Use AuthService to handle logout
        _authServiceInstance.logout();

        handler.next(err);
      } catch (e) {
        print('Token refresh error: $e');
        _isRefreshing = false;
        _pendingRequests.clear();
        // Don't call logout here to avoid recursion
        handler.next(err);
      }
      return;
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/logout') ||
        path.contains('/auth/verify');
  }
}
