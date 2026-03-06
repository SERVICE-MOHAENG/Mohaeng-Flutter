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

      return _parseResponse(response.data);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw Exception('로그인 실패: ${status ?? '네트워크 오류'}');
    }
  }

  Future<Map<String, dynamic>> loginWithKakao({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/kakao',
        data: {'accessToken': accessToken},
      );

      return _parseResponse(response.data);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw Exception('카카오 로그인 실패: ${status ?? '네트워크 오류'}');
    }
  }

  Future<Map<String, dynamic>> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/signup',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
        },
      );

      return _parseResponse(response.data);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw Exception('회원가입 실패: ${status ?? '네트워크 오류'}');
    }
  }

  Future<Map<String, dynamic>> refreshTokens({
    required String refreshToken,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      return _parseResponse(response.data);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw Exception('토큰 갱신 실패: ${status ?? '네트워크 오류'}');
    }
  }

  Future<Map<String, dynamic>> submitPreferences({
    required String weather,
    required String travelRange,
    required String travelStyle,
    required List<String> foodPersonality,
    required List<String> mainInterests,
    required String budgetLevel,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/preferences',
        data: {
          'weather': weather,
          'travel_range': travelRange,
          'travel_style': travelStyle,
          'food_personality': foodPersonality,
          'main_interests': mainInterests,
          'budget_level': budgetLevel,
        },
      );

      return _parseResponse(response.data);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw Exception('선호도 저장 실패: ${status ?? '네트워크 오류'}');
    }
  }

  Future<Map<String, dynamic>> getPreferenceJobStatus({
    required String jobId,
  }) async {
    try {
      final response = await _dio.get('/api/v1/preferences/jobs/$jobId/status');

      return _parseResponse(response.data);
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw Exception('선호도 작업 상태 조회 실패: ${status ?? '네트워크 오류'}');
    }
  }

  Future<void> sendEmailOtp({required String email}) async {
    try {
      await _dio.post('/api/v1/auth/email/otp/send', data: {'email': email});
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw Exception('이메일 인증번호 전송 실패: ${status ?? '네트워크 오류'}');
    }
  }

  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _dio.post(
        '/api/v1/auth/email/otp/verify',
        data: {'email': email, 'otp': otp},
      );
    } on DioException catch (error) {
      final status = error.response?.statusCode;
      throw Exception('이메일 인증번호 확인 실패: ${status ?? '네트워크 오류'}');
    }
  }

  Map<String, dynamic> _parseResponse(dynamic data) {
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
  }
}
