import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_endpoints.dart';

/// A [QueuedInterceptor] that attaches the access token to every request and
/// transparently refreshes it on 401 responses.
///
/// Uses a separate [refreshDio] instance for the refresh call so that the
/// refresh request does not re-enter this interceptor and cause a deadlock.
class AuthInterceptor extends QueuedInterceptor {
  final TokenStorage _tokenStorage;
  final Dio _refreshDio;

  AuthInterceptor({
    required TokenStorage tokenStorage,
    required Dio refreshDio,
  })  : _tokenStorage = tokenStorage,
        _refreshDio = refreshDio;

  // ── Attach access token to outgoing requests ──────────────────────────

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ── Handle 401 → refresh → retry ─────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // Avoid refreshing when the failing request is already the refresh call.
    if (err.requestOptions.path == ApiEndpoints.refreshToken) {
      await _tokenStorage.clearTokens();
      return handler.next(err);
    }

    try {
      final refreshToken = await _tokenStorage.refreshToken;
      if (refreshToken == null) {
        await _tokenStorage.clearTokens();
        return handler.next(err);
      }

      final response = await _refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'] as String;
      final newRefreshToken = response.data['refreshToken'] as String;

      await _tokenStorage.saveTokens(
        accessToken: newAccessToken,
        refreshToken: newRefreshToken,
      );

      // Retry the original request with the new access token.
      final options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newAccessToken';

      final retryResponse = await _refreshDio.fetch(options);
      return handler.resolve(retryResponse);
    } on DioException {
      // Refresh failed — clear tokens so the app can redirect to login.
      await _tokenStorage.clearTokens();
      return handler.next(err);
    }
  }
}
