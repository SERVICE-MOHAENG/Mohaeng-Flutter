import 'package:mohaeng_app_service/features/auth/data/auth_api.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/auth/domain/entities/auth_tokens.dart';
import 'package:mohaeng_app_service/features/auth/domain/entities/preference_job.dart';
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
    final response = await _authApi.signUp(
      name: name,
      email: email,
      password: password,
      passwordConfirm: passwordConfirm,
    );
    final payload = _extractTokenPayload(response);
    final accessToken = payload['accessToken'];
    final refreshToken = payload['refreshToken'];

    if (accessToken is! String || refreshToken is! String) {
      throw const FormatException('회원가입 응답에 토큰이 없습니다.');
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  @override
  Future<AuthTokens> refreshTokens({required String refreshToken}) async {
    final response = await _authApi.refreshTokens(refreshToken: refreshToken);
    final payload = _extractTokenPayload(response);
    final accessToken = payload['accessToken'];
    final nextRefreshToken = payload['refreshToken'];

    if (accessToken is! String || nextRefreshToken is! String) {
      throw const FormatException('토큰 갱신 응답에 토큰이 없습니다.');
    }

    await _tokenStorage.saveTokens(
      accessToken: accessToken,
      refreshToken: nextRefreshToken,
    );

    return AuthTokens(accessToken: accessToken, refreshToken: nextRefreshToken);
  }

  @override
  Future<PreferenceJob> submitPreferences({
    required String weather,
    required String travelRange,
    required String travelStyle,
    required List<String> foodPersonality,
    required List<String> mainInterests,
    required String budgetLevel,
  }) async {
    final response = await _authApi.submitPreferences(
      weather: weather,
      travelRange: travelRange,
      travelStyle: travelStyle,
      foodPersonality: foodPersonality,
      mainInterests: mainInterests,
      budgetLevel: budgetLevel,
    );
    final payload = _extractPayload(response);
    final jobId = _readString(payload, keys: const ['jobId', 'job_id']) ?? '';
    final status = _readString(payload, keys: const ['status']) ?? 'PENDING';

    if (jobId.isEmpty) {
      throw const FormatException('jobId is missing in preference response.');
    }

    return PreferenceJob(jobId: jobId, status: status);
  }

  @override
  Future<String> getPreferenceJobStatus({required String jobId}) async {
    final response = await _authApi.getPreferenceJobStatus(jobId: jobId);
    final payload = _extractPayload(response);
    final status = _readString(payload, keys: const ['status']) ?? '';

    if (status.isEmpty) {
      throw const FormatException(
        'status is missing in preference job status response.',
      );
    }

    return status;
  }

  @override
  Future<void> sendEmailOtp({required String email}) {
    return _authApi.sendEmailOtp(email: email);
  }

  @override
  Future<void> verifyEmailOtp({required String email, required String otp}) {
    return _authApi.verifyEmailOtp(email: email, otp: otp);
  }

  Map<String, dynamic> _extractTokenPayload(Map<String, dynamic> response) {
    return _extractPayload(response);
  }

  Map<String, dynamic> _extractPayload(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), value));
    }
    return response;
  }

  String? _readString(
    Map<String, dynamic> source, {
    required List<String> keys,
  }) {
    for (final key in keys) {
      final value = source[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
