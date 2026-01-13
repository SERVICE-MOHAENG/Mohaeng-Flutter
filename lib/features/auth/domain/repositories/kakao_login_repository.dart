import 'package:mohaeng_app_service/features/auth/domain/entities/kakao_login_result.dart';

abstract class KakaoLoginRepository {
  Future<KakaoLoginResult> login();
}
