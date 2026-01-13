import 'package:mohaeng_app_service/features/auth/domain/entities/google_login_result.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/google_login_repository.dart';

class GoogleLoginUseCase {
  const GoogleLoginUseCase(this._repository);

  final GoogleLoginRepository _repository;

  Future<GoogleLoginResult> call() {
    return _repository.login();
  }
}
