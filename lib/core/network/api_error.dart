import 'package:dio/dio.dart';

enum ApiErrorKind {
  badRequest,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  server,
  network,
  timeout,
  cancelled,
  unknown,
}

final class ApiError implements Exception {
  const ApiError({
    required this.kind,
    this.statusCode,
    required this.message,
    this.responseData,
    this.dioException,
  });

  final ApiErrorKind kind;
  final int? statusCode;
  final String message;
  final Object? responseData;
  final DioException? dioException;

  factory ApiError.fromResponse(Response<dynamic> response) {
    final status = response.statusCode;
    final kind = _mapStatusToKind(status);
    final message = _messageFromResponse(response) ?? _defaultMessage(kind);

    return ApiError(
      kind: kind,
      statusCode: status,
      message: message,
      responseData: response.data,
    );
  }

  factory ApiError.fromDioException(DioException error) {
    if (error.type == DioExceptionType.cancel) {
      return ApiError(
        kind: ApiErrorKind.cancelled,
        statusCode: error.response?.statusCode,
        message: _defaultMessage(ApiErrorKind.cancelled),
        responseData: error.response?.data,
        dioException: error,
      );
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return ApiError(
        kind: ApiErrorKind.timeout,
        statusCode: error.response?.statusCode,
        message: _defaultMessage(ApiErrorKind.timeout),
        responseData: error.response?.data,
        dioException: error,
      );
    }

    final response = error.response;
    if (response != null) {
      final status = response.statusCode;
      final kind = _mapStatusToKind(status);
      final message = _messageFromResponse(response) ?? _defaultMessage(kind);

      return ApiError(
        kind: kind,
        statusCode: status,
        message: message,
        responseData: response.data,
        dioException: error,
      );
    }

    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.badCertificate) {
      return ApiError(
        kind: ApiErrorKind.network,
        statusCode: null,
        message: _defaultMessage(ApiErrorKind.network),
        responseData: null,
        dioException: error,
      );
    }

    return ApiError(
      kind: ApiErrorKind.unknown,
      statusCode: null,
      message: error.message ?? _defaultMessage(ApiErrorKind.unknown),
      responseData: null,
      dioException: error,
    );
  }

  static ApiErrorKind _mapStatusToKind(int? statusCode) {
    return switch (statusCode) {
      400 => ApiErrorKind.badRequest,
      401 => ApiErrorKind.unauthorized,
      403 => ApiErrorKind.forbidden,
      404 => ApiErrorKind.notFound,
      409 => ApiErrorKind.conflict,
      final code? when code >= 500 => ApiErrorKind.server,
      _ => ApiErrorKind.unknown,
    };
  }

  static String? _messageFromResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['error'] ?? data['detail'];
      if (message is String && message.trim().isNotEmpty) {
        final trimmed = message.trim();
        if (!_looksLikeHtml(trimmed)) {
          return trimmed;
        }
      }

      final nested = data['data'];
      if (nested is Map<String, dynamic>) {
        final nestedMessage =
            nested['message'] ?? nested['error'] ?? nested['detail'];
        if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
          final trimmed = nestedMessage.trim();
          if (!_looksLikeHtml(trimmed)) {
            return trimmed;
          }
        }
      }
    }

    if (data is String && data.trim().isNotEmpty) {
      final trimmed = data.trim();
      if (!_looksLikeHtml(trimmed)) {
        return trimmed;
      }
    }

    return null;
  }

  static String _defaultMessage(ApiErrorKind kind) {
    return switch (kind) {
      ApiErrorKind.badRequest => '잘못된 요청입니다. (400)',
      ApiErrorKind.unauthorized => '인증이 필요합니다. (401)',
      ApiErrorKind.forbidden => '권한이 없습니다. (403)',
      ApiErrorKind.notFound => '요청한 리소스를 찾을 수 없습니다. (404)',
      ApiErrorKind.conflict => '요청이 충돌했습니다. (409)',
      ApiErrorKind.server => '서버 오류가 발생했습니다.',
      ApiErrorKind.network => '네트워크 연결을 확인해 주세요.',
      ApiErrorKind.timeout => '요청 시간이 초과되었습니다.',
      ApiErrorKind.cancelled => '요청이 취소되었습니다.',
      ApiErrorKind.unknown => '알 수 없는 오류가 발생했습니다.',
    };
  }

  @override
  String toString() {
    final statusPart = statusCode == null ? '' : ' (status: $statusCode)';
    return 'ApiError(${kind.name})$statusPart: $message';
  }
}

bool _looksLikeHtml(String value) {
  final lower = value.toLowerCase();
  return lower.contains('<!doctype') ||
      lower.contains('<html') ||
      lower.contains('<head') ||
      lower.contains('<body');
}
