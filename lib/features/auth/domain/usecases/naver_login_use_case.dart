import 'package:mohaeng_app_service/features/auth/domain/entities/naver_login_result.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/naver_login_repository.dart';

class NaverLoginUseCase {
  const NaverLoginUseCase(this._repository);

  final NaverLoginRepository _repository;

  Future<NaverLoginResult> call() {
    return _repository.login();
  }
}
