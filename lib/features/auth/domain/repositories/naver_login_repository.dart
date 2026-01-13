import 'package:mohaeng_app_service/features/auth/domain/entities/naver_login_result.dart';

abstract class NaverLoginRepository {
  Future<NaverLoginResult> login();
}
