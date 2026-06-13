import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sportbook/feature/Token/api/token_api.dart';
import 'package:sportbook/feature/Token/model/token_model.dart';

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TokenApi _tokenApi;

  TokenService(this._tokenApi); // Add constructor dependency

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

  Future<bool> hasValidTokenAsync() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  Future<bool> refreshAccessToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) return false;

      final newTokenModel = await _tokenApi.refreshToken(refreshToken);
      await saveTokens(newTokenModel);
      return true;
    } catch (e) {
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
