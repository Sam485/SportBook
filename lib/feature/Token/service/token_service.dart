import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sportbook/feature/Token/api/token_api.dart';
import 'package:sportbook/feature/Token/model/token_model.dart';

class TokenService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TokenApi _tokenApi;

  TokenService(this._tokenApi);

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenTypeKey = 'token_type';
  static const String _expiredInKey = 'expired_in';
  static const String _tokenReceivedTimeKey = 'token_received_time';

  Future<void> saveTokens(TokenModel token) async {
    await _storage.write(key: _accessTokenKey, value: token.accessToken);
    await _storage.write(key: _refreshTokenKey, value: token.refreshToken);
    await _storage.write(key: _tokenTypeKey, value: token.tokenType);
    await _storage.write(key: _expiredInKey, value: token.expiredIn.toString());
    await _storage.write(
      key: _tokenReceivedTimeKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  Future<TokenModel?> getTokens() async {
    final accessToken = await _storage.read(key: _accessTokenKey);
    final refreshToken = await _storage.read(key: _refreshTokenKey);
    final tokenType = await _storage.read(key: _tokenTypeKey);
    final expiredInStr = await _storage.read(key: _expiredInKey);

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
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
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
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _tokenTypeKey);
    await _storage.delete(key: _expiredInKey);
    await _storage.delete(key: _tokenReceivedTimeKey);
  }
}
