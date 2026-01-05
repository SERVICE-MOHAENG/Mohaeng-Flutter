import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:mohaeng_app_service/core/network/dio_client.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';

class AuthApi {
  AuthApi({Dio? dio, AuthTokenStorage? tokenStorage})
      : _dio = dio ?? DioClient(tokenStorage: tokenStorage).dio;

  final Dio _dio;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );

      final data = response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      if (data is String) {
        final decoded = jsonDecode(data);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      throw const FormatException('응답 형식이 올바르지 않습니다.');
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw Exception('로그인 실패: ${status ?? '네트워크 오류'}');
    }
  }
}
