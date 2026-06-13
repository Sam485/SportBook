import 'package:dio/dio.dart';
import 'package:sportbook/core/di/service_locator.dart';
import 'package:sportbook/feature/Token/service/token_service.dart';

class AuthInterceptor extends Interceptor {
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
    // Handle token expiration
    if (err.response?.statusCode == 401) {
      try {
        final tokenService = getIt<TokenService>();
        final refreshed = await tokenService.refreshAccessToken();

        if (refreshed) {
          // Get Dio instance from GetIt
          final dio = getIt<Dio>();

          // Retry the original request with new token
          final newToken = await tokenService.getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await dio.fetch(err.requestOptions);
          handler.resolve(response);
          return;
        }
      } catch (e) {
        print('Token refresh failed: $e');
        // Refresh failed, continue with error
      }
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    return path.contains('/auth/login') ||
        path.contains('/auth/register') ||
        path.contains('/auth/refresh');
  }
}
