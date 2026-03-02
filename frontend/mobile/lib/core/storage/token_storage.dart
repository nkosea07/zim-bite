import 'dart:convert';
import 'secure_storage.dart';

class TokenStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final SecureStorage _storage;

  TokenStorage(this._storage);

  Future<String?> get accessToken => _storage.read(_accessTokenKey);
  Future<String?> get refreshToken => _storage.read(_refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(_accessTokenKey, accessToken),
      _storage.write(_refreshTokenKey, refreshToken),
    ]);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(_accessTokenKey),
      _storage.delete(_refreshTokenKey),
    ]);
  }

  Future<bool> get hasTokens async => await accessToken != null;

  Future<String?> getRole() async {
    final token = await _storage.read(_accessTokenKey);
    if (token == null) return null;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      String payload = parts[1];
      final mod = payload.length % 4;
      if (mod != 0) payload += '=' * (4 - mod);
      final decoded = utf8.decode(base64Url.decode(payload));
      final json = jsonDecode(decoded) as Map<String, dynamic>;
      return json['role'] as String?;
    } catch (_) {
      return null;
    }
  }
}
