import 'package:dio/dio.dart';

/// Provides an access token (or `null`) for authenticated requests.
///
/// Intended usage:
/// `AuthInterceptor(accessTokenProvider: () => authRepository.getAccessToken())`
typedef AccessTokenProvider = Future<String?> Function();

final class AuthInterceptor extends Interceptor {
  AuthInterceptor({required AccessTokenProvider accessTokenProvider})
    : _accessTokenProvider = accessTokenProvider;

  final AccessTokenProvider _accessTokenProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = (await _accessTokenProvider())?.trim();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Ignore token lookup failures; request proceeds unauthenticated.
    }

    handler.next(options);
  }
}
