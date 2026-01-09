import 'package:flutter_naver_login/flutter_naver_login.dart' as naver;
import 'package:flutter_naver_login/interface/types/naver_login_status.dart'
    as naver_types;
import 'package:mohaeng_app_service/features/auth/domain/entities/naver_login_result.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/naver_login_repository.dart';

class NaverLoginRepositoryImpl implements NaverLoginRepository {
  @override
  Future<NaverLoginResult> login() async {
    try {
      final response = await naver.FlutterNaverLogin.logIn();

      switch (response.status) {
        case naver_types.NaverLoginStatus.loggedIn:
          final token = response.accessToken;
          if (token == null || token.accessToken.isEmpty) {
            return NaverLoginResult.failure('네이버 토큰이 없습니다.');
          }
          return NaverLoginResult.success(token.accessToken, token.expiresAt);
        case naver_types.NaverLoginStatus.loggedOut:
          return NaverLoginResult.cancelled();
        case naver_types.NaverLoginStatus.error:
          final message = response.errorMessage;
          if (_isCancelledMessage(message)) {
            return NaverLoginResult.cancelled();
          }
          return NaverLoginResult.failure(
            message ?? '네이버 로그인에 실패했어요.',
          );
      }
    } catch (error) {
      if (_isCancelledMessage(error.toString())) {
        return NaverLoginResult.cancelled();
      }
      return NaverLoginResult.failure('네이버 로그인 실패: $error');
    }
  }

  bool _isCancelledMessage(String? message) {
    if (message == null || message.isEmpty) return false;
    final lower = message.toLowerCase();
    return lower.contains('cancel') ||
        lower.contains('canceled') ||
        lower.contains('cancelled') ||
        message.contains('취소');
  }
}
