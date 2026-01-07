import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:mohaeng_app_service/features/auth/domain/entities/kakao_login_result.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/kakao_login_repository.dart';

class KakaoLoginRepositoryImpl implements KakaoLoginRepository {
  @override
  Future<KakaoLoginResult> login() async {
    try {
      kakao.OAuthToken token;
      final kakaoTalkInstalled = await kakao.isKakaoTalkInstalled();

      if (kakaoTalkInstalled) {
        try {
          token = await kakao.UserApi.instance.loginWithKakaoTalk();
        } on kakao.KakaoClientException catch (error) {
          if (error.reason == kakao.ClientErrorCause.cancelled) {
            return KakaoLoginResult.cancelled();
          }
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        } on PlatformException catch (error) {
          if (error.code == 'CANCELED') {
            return KakaoLoginResult.cancelled();
          }
          token = await kakao.UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      return KakaoLoginResult.success(token.accessToken, token.expiresAt);
    } on kakao.KakaoAuthException catch (error) {
      final message = error.errorDescription ?? '카카오 로그인에 실패했어요.';
      return KakaoLoginResult.failure(message);
    } on kakao.KakaoClientException catch (error) {
      if (error.reason == kakao.ClientErrorCause.cancelled) {
        return KakaoLoginResult.cancelled();
      }
      return KakaoLoginResult.failure(
        '카카오 로그인 실패: ${error.message ?? error.msg}',
      );
    } catch (error) {
      return KakaoLoginResult.failure('카카오 로그인 실패: $error');
    }
  }
}
