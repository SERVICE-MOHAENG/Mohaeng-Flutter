import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/main/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/main/domain/usecase/get_main_blogs.dart';

@immutable
class MainBlogsState {
  const MainBlogsState({
    this.isLoading = false,
    this.errorMessage,
    this.blogs = const <BlogResponse>[],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<BlogResponse> blogs;

  MainBlogsState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<BlogResponse>? blogs,
  }) {
    return MainBlogsState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      blogs: blogs ?? this.blogs,
    );
  }
}

class MainBlogsViewModel extends StateNotifier<MainBlogsState> {
  MainBlogsViewModel(this._getMainBlogsUsecase) : super(const MainBlogsState());

  final GetMainBlogsUsecase _getMainBlogsUsecase;

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _getMainBlogsUsecase(page: 1, limit: 6);

      state = state.copyWith(
        isLoading: false,
        blogs: response.blogs,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '블로그를 불러오지 못했어요.',
        },
      );
    }
  }
}
