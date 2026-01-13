import 'package:mohaeng_app_service/features/auth/domain/entities/auth_tokens.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthTokens> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
