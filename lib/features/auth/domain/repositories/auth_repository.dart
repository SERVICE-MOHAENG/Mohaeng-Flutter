import 'package:mohaeng_app_service/features/auth/domain/entities/auth_tokens.dart';
import 'package:mohaeng_app_service/features/auth/domain/entities/preference_job.dart';

abstract class AuthRepository {
  Future<AuthTokens> login({required String email, required String password});

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  });

  Future<AuthTokens> refreshTokens({required String refreshToken});

  Future<PreferenceJob> submitPreferences({
    required String weather,
    required String travelRange,
    required String travelStyle,
    required List<String> foodPersonality,
    required List<String> mainInterests,
    required String budgetLevel,
  });

  Future<String> getPreferenceJobStatus({required String jobId});

  Future<void> sendEmailOtp({required String email});

  Future<void> verifyEmailOtp({required String email, required String otp});
}
