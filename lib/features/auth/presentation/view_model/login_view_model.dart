import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/auth/domain/entities/google_login_result.dart';
import 'package:mohaeng_app_service/features/auth/domain/entities/kakao_login_result.dart';
import 'package:mohaeng_app_service/features/auth/domain/entities/naver_login_result.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/google_login_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/kakao_login_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/login_use_case.dart';
import 'package:mohaeng_app_service/features/auth/domain/usecases/naver_login_use_case.dart';

@immutable
class LoginViewState {
  const LoginViewState({
    this.keepLogin = false,
    this.isLoading = false,
    this.isOauthLoading = false,
  });

  final bool keepLogin;
  final bool isLoading;
  final bool isOauthLoading;

  LoginViewState copyWith({
    bool? keepLogin,
    bool? isLoading,
    bool? isOauthLoading,
  }) {
    return LoginViewState(
      keepLogin: keepLogin ?? this.keepLogin,
      isLoading: isLoading ?? this.isLoading,
      isOauthLoading: isOauthLoading ?? this.isOauthLoading,
    );
  }
}

enum LoginActionType { success, failure, cancelled }

@immutable
class LoginActionResult {
  const LoginActionResult({required this.type, this.message});

  final LoginActionType type;
  final String? message;

  bool get isSuccess => type == LoginActionType.success;
  bool get isFailure => type == LoginActionType.failure;
  bool get isCancelled => type == LoginActionType.cancelled;
}

class LoginViewModel extends StateNotifier<LoginViewState> {
  LoginViewModel({
    required LoginUseCase loginUseCase,
    required GoogleLoginUseCase googleLoginUseCase,
    required KakaoLoginUseCase kakaoLoginUseCase,
    required NaverLoginUseCase naverLoginUseCase,
  }) : _loginUseCase = loginUseCase,
       _googleLoginUseCase = googleLoginUseCase,
       _kakaoLoginUseCase = kakaoLoginUseCase,
       _naverLoginUseCase = naverLoginUseCase,
       super(const LoginViewState());

  final LoginUseCase _loginUseCase;
  final GoogleLoginUseCase _googleLoginUseCase;
  final KakaoLoginUseCase _kakaoLoginUseCase;
  final NaverLoginUseCase _naverLoginUseCase;

  void setKeepLogin(bool value) {
    state = state.copyWith(keepLogin: value);
  }

  Future<LoginActionResult> login({
    required String email,
    required String password,
  }) async {
    if (state.isLoading) {
      return const LoginActionResult(type: LoginActionType.cancelled);
    }

    state = state.copyWith(isLoading: true);
    try {
      await _loginUseCase(email: email, password: password);
      return const LoginActionResult(type: LoginActionType.success);
    } catch (error) {
      return LoginActionResult(
        type: LoginActionType.failure,
        message: '로그인 실패: $error',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<LoginActionResult> loginWithGoogle() async {
    if (state.isOauthLoading) {
      return const LoginActionResult(type: LoginActionType.cancelled);
    }

    state = state.copyWith(isOauthLoading: true);
    try {
      final result = await _googleLoginUseCase();

      if (result.status == GoogleLoginStatus.cancelled) {
        return const LoginActionResult(type: LoginActionType.cancelled);
      }
      if (result.status == GoogleLoginStatus.failure) {
        return LoginActionResult(
          type: LoginActionType.failure,
          message: result.message ?? '구글 로그인에 실패했어요.',
        );
      }
      return const LoginActionResult(
        type: LoginActionType.success,
        message: '구글 로그인 성공',
      );
    } finally {
      state = state.copyWith(isOauthLoading: false);
    }
  }

  Future<LoginActionResult> loginWithKakao() async {
    if (state.isOauthLoading) {
      return const LoginActionResult(type: LoginActionType.cancelled);
    }

    state = state.copyWith(isOauthLoading: true);
    try {
      final result = await _kakaoLoginUseCase();

      if (result.status == KakaoLoginStatus.cancelled) {
        return const LoginActionResult(type: LoginActionType.cancelled);
      }
      if (result.status == KakaoLoginStatus.failure) {
        return LoginActionResult(
          type: LoginActionType.failure,
          message: result.message ?? '카카오 로그인에 실패했어요.',
        );
      }
      return const LoginActionResult(
        type: LoginActionType.success,
        message: '카카오 로그인 성공',
      );
    } finally {
      state = state.copyWith(isOauthLoading: false);
    }
  }

  Future<LoginActionResult> loginWithNaver() async {
    if (state.isOauthLoading) {
      return const LoginActionResult(type: LoginActionType.cancelled);
    }

    state = state.copyWith(isOauthLoading: true);
    try {
      final result = await _naverLoginUseCase();

      if (result.status == NaverLoginStatus.cancelled) {
        return const LoginActionResult(type: LoginActionType.cancelled);
      }
      if (result.status == NaverLoginStatus.failure) {
        return LoginActionResult(
          type: LoginActionType.failure,
          message: result.message ?? '네이버 로그인에 실패했어요.',
        );
      }
      return const LoginActionResult(
        type: LoginActionType.success,
        message: '네이버 로그인 성공',
      );
    } finally {
      state = state.copyWith(isOauthLoading: false);
    }
  }
}
