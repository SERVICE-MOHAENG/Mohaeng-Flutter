import 'package:mohaeng_app_service/features/auth/domain/repositories/auth_repository.dart';

class SendEmailOtpUseCase {
  const SendEmailOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({required String email}) {
    return _repository.sendEmailOtp(email: email);
  }
}
