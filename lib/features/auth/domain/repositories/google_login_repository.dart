import 'package:mohaeng_app_service/features/auth/domain/entities/google_login_result.dart';

abstract class GoogleLoginRepository {
  Future<GoogleLoginResult> login();
}
