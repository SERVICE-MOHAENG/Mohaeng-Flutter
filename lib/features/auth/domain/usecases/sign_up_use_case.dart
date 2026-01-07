import 'package:mohaeng_app_service/features/auth/domain/repositories/auth_repository.dart';

class SignUpUseCase {
  const SignUpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) {
    return _repository.signUp(
      name: name,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
    );
  }
}
