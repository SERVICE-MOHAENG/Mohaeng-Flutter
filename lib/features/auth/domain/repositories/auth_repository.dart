import 'package:mohaeng_app_service/features/auth/domain/entities/auth_tokens.dart';

abstract class AuthRepository {
  Future<AuthTokens> login({
    required String email,
    required String password,
  });

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  });
}
