import 'package:mohaeng_app_service/features/auth/data/auth_api.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/auth/domain/entities/auth_tokens.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl._(this._authApi, this._tokenStorage);

  factory AuthRepositoryImpl({
    AuthApi? authApi,
    AuthTokenStorage? tokenStorage,
  }) {
    final storage = tokenStorage ?? AuthTokenStorage();
    final api = authApi ?? AuthApi(tokenStorage: storage);
    return AuthRepositoryImpl._(api, storage);
  }

  final AuthApi _authApi;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<AuthTokens> login({
    required String email,
    required String password,
  }) async {
    final response = await _authApi.login(email: email, password: password);
    final payload = _extractTokenPayload(response);
    final accessToken = payload['accessToken'];
    final refreshToken = payload['refreshToken'];

    if (accessToken is! String || refreshToken is! String) {
      throw const FormatException('토큰이 없습니다.');
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> signUp({
    required String name,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    await _authApi.signUp(
      name: name,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
    );
  }

  @override
  Future<void> sendEmailOtp({required String email}) {
    return _authApi.sendEmailOtp(email: email);
  }

  @override
  Future<void> verifyEmailOtp({
    required String email,
    required String otp,
  }) {
    return _authApi.verifyEmailOtp(email: email, otp: otp);
  }

  Map<String, dynamic> _extractTokenPayload(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return response;
  }
}
