import 'package:dio/dio.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';

class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<({RequestOptions options, ErrorInterceptorHandler handler})>
  _pendingRequests = [];

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
      final tokenService = getIt<TokenService>();

      // Check if token is valid and not expired
      final isValid = await tokenService.hasValidTokenAsync();

      if (!isValid) {
        // Try to refresh token
        final refreshed = await tokenService.refreshAccessToken();
        if (!refreshed) {
          // If refresh fails, continue without token (will get 401)
          handler.next(options);
          return;
        }
      }

      // Get the token after potential refresh
      final accessToken = await tokenService.getAccessToken();
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    } catch (e) {
      print('Error adding auth token: $e');
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
      try {
        final tokenService = getIt<TokenService>();

        // If already refreshing, add to queue
        if (_isRefreshing) {
          _pendingRequests.add((options: err.requestOptions, handler: handler));
          return;
        }

        _isRefreshing = true;

        // Try to refresh the token
        final refreshed = await tokenService.refreshAccessToken();

        if (refreshed) {
          // Get new token
          final newToken = await tokenService.getAccessToken();
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
        await tokenService.clearToken();

        // You might want to emit a logout event here
        handler.next(err);
      } catch (e) {
        print('Token refresh error: $e');
        _isRefreshing = false;
        _pendingRequests.clear();
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
