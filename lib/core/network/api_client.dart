import 'package:dio/dio.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/core/network/query_params.dart';

final class ApiClient {
  ApiClient({
    required String baseUrl,
    Dio? dio,
    List<Interceptor> interceptors = const [],
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 10),
  }) : _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: _normalizeBaseUrl(baseUrl),
               contentType: Headers.jsonContentType,
               responseType: ResponseType.json,
               headers: const {'Accept': 'application/json'},
               connectTimeout: connectTimeout,
               receiveTimeout: receiveTimeout,
             ),
           ) {
    _dio.interceptors.addAll(interceptors);
  }

  final Dio _dio;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(
    String path, {
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: removeNullQueryParams(queryParameters),
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: removeNullQueryParams(queryParameters),
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: removeNullQueryParams(queryParameters),
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<Response<T>> patch<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: removeNullQueryParams(queryParameters),
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, Object?>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: removeNullQueryParams(queryParameters),
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw ApiError.fromDioException(error);
    }
  }

  static String _normalizeBaseUrl(String baseUrl) {
    final trimmed = baseUrl.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('baseUrl is empty.');
    }
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
