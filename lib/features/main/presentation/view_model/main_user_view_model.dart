import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/main/data/model/user_models.dart';
import 'package:mohaeng_app_service/features/main/domain/usecase/get_main_user_me.dart';

@immutable
class MainUserState {
  const MainUserState({this.isLoading = false, this.errorMessage, this.user});

  final bool isLoading;
  final String? errorMessage;
  final MainUserResponse? user;

  MainUserState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    MainUserResponse? user,
    bool keepUser = true,
  }) {
    return MainUserState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      user: keepUser ? (user ?? this.user) : user,
    );
  }
}

class MainUserViewModel extends StateNotifier<MainUserState> {
  MainUserViewModel(this._getMainUserMeUsecase) : super(const MainUserState());

  final GetMainUserMeUsecase _getMainUserMeUsecase;

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final user = await _getMainUserMeUsecase();
      state = state.copyWith(isLoading: false, user: user, clearError: true);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '사용자 정보를 불러오지 못했어요.',
        },
      );
    }
  }
}
