import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';

void main() {
  group('ApiError timeout messages', () {
    test('maps connection timeout to a specific message', () {
      final error = ApiError.fromDioException(
        _buildDioException(DioExceptionType.connectionTimeout),
      );

      expect(error.kind, ApiErrorKind.timeout);
      expect(error.message, '서버 연결 시간이 초과되었습니다.');
    });

    test('maps send timeout to a specific message', () {
      final error = ApiError.fromDioException(
        _buildDioException(DioExceptionType.sendTimeout),
      );

      expect(error.kind, ApiErrorKind.timeout);
      expect(error.message, '요청 전송 시간이 초과되었습니다.');
    });

    test('maps receive timeout to a specific message', () {
      final error = ApiError.fromDioException(
        _buildDioException(DioExceptionType.receiveTimeout),
      );

      expect(error.kind, ApiErrorKind.timeout);
      expect(error.message, '서버 응답 대기 시간이 초과되었습니다.');
    });
  });
}

DioException _buildDioException(DioExceptionType type) {
  return DioException(
    requestOptions: RequestOptions(path: '/api/v1/test'),
    type: type,
  );
}
