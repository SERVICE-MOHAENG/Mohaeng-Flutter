import 'package:mohaeng_app_service/features/auth/domain/entities/kakao_login_result.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/kakao_login_repository.dart';

class KakaoLoginUseCase {
  const KakaoLoginUseCase(this._repository);

  final KakaoLoginRepository _repository;

  Future<KakaoLoginResult> call() {
    return _repository.login();
  }
}
