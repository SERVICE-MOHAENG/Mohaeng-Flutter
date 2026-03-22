import 'package:dio/dio.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/core/network/dio_logger.dart';
import 'package:mohaeng_app_service/core/network/network_options.dart';
import 'package:mohaeng_app_service/core/network/query_params.dart';

final class ApiClient {
  ApiClient({
    required String baseUrl,
    Dio? dio,
    List<Interceptor> interceptors = const [],
    bool addLoggerInterceptor = true,
    NetworkTimeouts timeouts = const NetworkTimeouts(),
  }) : _dio =
           dio ??
           Dio(
             buildJsonBaseOptions(
               baseUrl: baseUrl,
               headers: const {'Accept': 'application/json'},
               timeouts: timeouts,
             ),
           ) {
    _dio.interceptors.addAll(interceptors);

    if (addLoggerInterceptor &&
        !_dio.interceptors.any(
          (interceptor) => interceptor is DioLoggerInterceptor,
        )) {
      _dio.interceptors.add(DioLoggerInterceptor());
    }
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
}
