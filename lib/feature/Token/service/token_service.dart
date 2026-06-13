import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sportbook/feature/Token/model/token_model.dart';

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Store tokens
  Future<void> saveTokens(TokenModel token) async {
    await _storage.write(key: 'access_token', value: token.accessToken);
    await _storage.write(key: 'refresh_token', value: token.refreshToken);
    await _storage.write(key: 'token_type', value: token.tokenType);
    await _storage.write(key: 'expired_in', value: token.expiredIn.toString());
  }

  // Async version - recommended
  Future<bool> hasValidTokenAsync() async {
    final tokens = await getTokens();
    if (tokens == null) return false;

    // Check if token is expired
    return tokens.accessToken.isNotEmpty;
  }

  // Get stored tokens (FIXED: corrected 'refresh_token' key typo)
  Future<TokenModel?> getTokens() async {
    final accessToken = await _storage.read(key: 'access_token');
    final refreshToken = await _storage.read(
      key: 'refresh_token',
    ); // Fixed typo
    final tokenType = await _storage.read(key: 'token_type');
    final expiredIn = await _storage.read(key: 'expired_in');

    if (accessToken == null ||
        refreshToken == null ||
        tokenType == null ||
        expiredIn == null) {
      return null;
    }

    return TokenModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiredIn: int.parse(expiredIn),
    );
  }

  // Get just the access token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  // Get just the refresh token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: 'refresh_token');
  }

  // Clear all tokens
  Future<void> clearToken() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'token_type');
    await _storage.delete(key: 'expired_in');
  }

  // Update access token only (useful for token refresh)
  Future<void> updateAccessToken(String newAccessToken) async {
    await _storage.write(key: 'access_token', value: newAccessToken);
  }
}
