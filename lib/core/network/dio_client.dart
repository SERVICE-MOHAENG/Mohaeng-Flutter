import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';

class DioClient {
  DioClient({AuthTokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? AuthTokenStorage(),
        _dio = Dio(_buildOptions()),
        _refreshDio = Dio(_buildOptions()) {
    _dio.interceptors.add(
      _AuthInterceptor(
        dio: _dio,
        refreshDio: _refreshDio,
        tokenStorage: _tokenStorage,
      ),
    );
  }

  final Dio _dio;
  final Dio _refreshDio;
  final AuthTokenStorage _tokenStorage;

  Dio get dio => _dio;

  static BaseOptions _buildOptions() {
    final baseUrl = dotenv.env['BASE_URL']?.trim() ?? '';
    if (baseUrl.isEmpty) {
      throw const FormatException('BASE_URL is not set.');
    }

    return BaseOptions(
      baseUrl: baseUrl,
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    );
  }
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor({
    required Dio dio,
    required Dio refreshDio,
    required AuthTokenStorage tokenStorage,
  })  : _dio = dio,
        _refreshDio = refreshDio,
        _tokenStorage = tokenStorage;

  final Dio _dio;
  final Dio _refreshDio;
  final AuthTokenStorage _tokenStorage;

  Completer<String?>? _refreshCompleter;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await _tokenStorage.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final requestOptions = err.requestOptions;

    if (status != 401 ||
        requestOptions.extra['retried'] == true ||
        _isAuthEndpoint(requestOptions.path)) {
      handler.next(err);
      return;
    }

    final newAccessToken = await _refreshAccessToken();
    if (newAccessToken == null || newAccessToken.isEmpty) {
      await _tokenStorage.clearTokens();
      handler.next(err);
      return;
    }

    requestOptions.extra['retried'] = true;
    requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

    try {
      final response = await _dio.fetch(requestOptions);
      handler.resolve(response);
    } catch (error) {
      if (error is DioException) {
        handler.next(error);
      } else {
        handler.next(err);
      }
    }
  }

  static const String _loginPath = '/api/v1/auth/login';
  static const String _refreshPath = '/api/v1/auth/refresh';

  bool _isAuthEndpoint(String path) {
    return path.contains(_loginPath) || path.contains(_refreshPath);
  }

  Future<String?> _refreshAccessToken() async {
    if (_refreshCompleter != null) {
      return _refreshCompleter!.future;
    }

    final completer = Completer<String?>();
    _refreshCompleter = completer;

    try {
      final refreshToken = await _tokenStorage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        completer.complete(null);
        return completer.future;
      }

      final response = await _refreshDio.post(
        _refreshPath,
        data: {'refreshToken': refreshToken},
      );

      final payload = _extractTokenPayload(response.data);
      final accessToken = payload['accessToken'];
      final nextRefreshToken = payload['refreshToken'];

      if (accessToken is! String || accessToken.isEmpty) {
        completer.complete(null);
        return completer.future;
      }

      final refreshToStore =
          nextRefreshToken is String && nextRefreshToken.isNotEmpty
              ? nextRefreshToken
              : refreshToken;

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToStore,
      );

      completer.complete(accessToken);
      return completer.future;
    } catch (_) {
      completer.complete(null);
      return completer.future;
    } finally {
      _refreshCompleter = null;
    }
  }

  Map<String, dynamic> _extractTokenPayload(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        return nested;
      }
      return data;
    }

    if (data is String && data.isNotEmpty) {
      final decoded = jsonDecode(data);
      if (decoded is Map<String, dynamic>) {
        final nested = decoded['data'];
        if (nested is Map<String, dynamic>) {
          return nested;
        }
        return decoded;
      }
    }

    return const <String, dynamic>{};
  }
}
