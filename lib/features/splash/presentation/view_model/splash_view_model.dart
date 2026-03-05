import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/auth_repository.dart';

@immutable
class SplashState {
  const SplashState({this.isChecking = false});

  final bool isChecking;

  SplashState copyWith({bool? isChecking}) {
    return SplashState(isChecking: isChecking ?? this.isChecking);
  }
}

class SplashViewModel extends StateNotifier<SplashState> {
  SplashViewModel(this._tokenStorage, this._authRepository)
    : super(const SplashState());

  final AuthTokenStorage _tokenStorage;
  final AuthRepository _authRepository;

  Future<bool> checkAutoLogin() async {
    if (!mounted || state.isChecking) return false;
    state = state.copyWith(isChecking: true);
    try {
      final refreshToken =
          (await _tokenStorage.readRefreshToken())?.trim() ?? '';
      if (refreshToken.isEmpty) {
        await _tokenStorage.clearTokens();
        return false;
      }

      try {
        await _authRepository.refreshTokens(refreshToken: refreshToken);
        return true;
      } catch (_) {
        await _tokenStorage.clearTokens();
        return false;
      }
    } finally {
      if (mounted) {
        state = state.copyWith(isChecking: false);
      }
    }
  }
}
