import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sportbook/feature/Token/api/token_api.dart';
import 'package:sportbook/feature/Token/model/token_model.dart';

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TokenApi _tokenApi;

  TokenService(this._tokenApi);

  // Token expiry buffer (refresh 5 minutes before actual expiry)
  static const int _expiryBufferSeconds = 300; // 5 minutes

  Future<void> saveTokens(TokenModel token) async {
    await _storage.write(key: 'access_token', value: token.accessToken);
    await _storage.write(key: 'refresh_token', value: token.refreshToken);
    await _storage.write(key: 'token_type', value: token.tokenType);
    await _storage.write(key: 'expired_in', value: token.expiredIn.toString());
    await _storage.write(
      key: 'token_received_time',
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<TokenModel?> getTokens() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(key: 'refresh_token');
    final tokenType = await _storage.read(key: 'token_type');
    final expiredInStr = await _storage.read(key: 'expired_in');

    if (accessToken == null ||
        refreshToken == null ||
        tokenType == null ||
        expiredInStr == null) {
      return null;
    }

    return TokenModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiredIn: int.parse(expiredInStr),
    );
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // Check if token exists and is still valid
  Future<bool> hasValidTokenAsync() async {
    final token = await getAccessToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // Check if token is expired
    final isExpired = await isTokenExpired();
    if (isExpired) {
      // Try to refresh
      return await refreshAccessToken();
    }

    return true;
  }

  // Check if token is expired or about to expire
  Future<bool> isTokenExpired() async {
    final receivedTimeStr = await _storage.read(key: 'token_received_time');
    final expiredInStr = await _storage.read(key: 'expired_in');

    if (receivedTimeStr == null || expiredInStr == null) {
      return true;
    }

    try {
      final receivedTime = DateTime.parse(receivedTimeStr);
      final expiredIn = int.parse(expiredInStr);

      // Calculate when token will expire
      final expiryTime = receivedTime.add(Duration(seconds: expiredIn));

      // Check if token is expired or will expire within buffer time
      final timeUntilExpiry = expiryTime.difference(DateTime.now());
      return timeUntilExpiry.inSeconds <= _expiryBufferSeconds;
    } catch (e) {
      // If there's any error parsing, consider token expired
      return true;
    }
  }

  // Get remaining time until token expires
  Future<int?> getRemainingExpiryTime() async {
    final receivedTimeStr = await _storage.read(key: 'token_received_time');
    final expiredInStr = await _storage.read(key: 'expired_in');

    if (receivedTimeStr == null || expiredInStr == null) {
      return null;
    }

    try {
      final receivedTime = DateTime.parse(receivedTimeStr);
      final expiredIn = int.parse(expiredInStr);
      final expiryTime = receivedTime.add(Duration(seconds: expiredIn));

      return expiryTime.difference(DateTime.now()).inSeconds;
    } catch (e) {
      return null;
    }
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await clearToken();
        return false;
      }

      final newTokenModel = await _tokenApi.refreshToken(refreshToken);
      if (newTokenModel.accessToken.isNotEmpty) {
        await saveTokens(newTokenModel);
        return true;
      }

      await clearToken();
      return false;
    } catch (e) {
      print('Refresh token failed: $e');
      await clearToken();
      return false;
    }
  }

  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'token_type');
    await _storage.delete(key: 'expired_in');
    await _storage.delete(key: 'token_received_time');
  }
}
