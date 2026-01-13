import 'package:mohaeng_app_service/features/auth/domain/repositories/auth_repository.dart';

class VerifyEmailOtpUseCase {
  const VerifyEmailOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call({
    required String email,
    required String otp,
  }) {
    return _repository.verifyEmailOtp(email: email, otp: otp);
  }
}
