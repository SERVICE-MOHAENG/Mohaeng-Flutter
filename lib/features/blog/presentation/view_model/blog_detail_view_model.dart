import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/blog/data/model/blog_detail_models.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/add_blog_like.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/get_blog_detail.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/remove_blog_like.dart';

@immutable
class BlogDetailState {
  const BlogDetailState({
    this.isLoading = false,
    this.isLiking = false,
    this.errorMessage,
    this.blog,
  });

  final bool isLoading;
  final bool isLiking;
  final String? errorMessage;
  final BlogDetailResponse? blog;

  BlogDetailState copyWith({
    bool? isLoading,
    bool? isLiking,
    String? errorMessage,
    bool clearError = false,
    BlogDetailResponse? blog,
  }) {
    return BlogDetailState(
      isLoading: isLoading ?? this.isLoading,
      isLiking: isLiking ?? this.isLiking,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      blog: blog ?? this.blog,
    );
  }
}

class BlogDetailViewModel extends StateNotifier<BlogDetailState> {
  BlogDetailViewModel(
    this._getBlogDetailUsecase,
    this._addBlogLikeUsecase,
    this._removeBlogLikeUsecase,
    this._blogId,
  ) : super(const BlogDetailState()) {
    load();
  }

  final GetBlogDetailUsecase _getBlogDetailUsecase;
  final AddBlogLikeUsecase _addBlogLikeUsecase;
  final RemoveBlogLikeUsecase _removeBlogLikeUsecase;
  final String _blogId;

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final blog = await _getBlogDetailUsecase(id: _blogId);
      state = state.copyWith(isLoading: false, blog: blog, clearError: true);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '블로그 상세를 불러오지 못했어요.',
        },
      );
    }
  }

  Future<void> toggleLike() async {
    final blog = state.blog;
    if (blog == null || state.isLiking) return;

    state = state.copyWith(isLiking: true, clearError: true);

    try {
      final isLiked = blog.isLiked ?? false;
      if (isLiked) {
        await _removeBlogLikeUsecase(id: _blogId);
      } else {
        await _addBlogLikeUsecase(id: _blogId);
      }

      final currentCount = blog.likeCount ?? 0;
      final nextIsLiked = !isLiked;
      final nextLikeCount = nextIsLiked
          ? currentCount + 1
          : (currentCount > 0 ? currentCount - 1 : 0);

      state = state.copyWith(
        isLiking: false,
        blog: blog.copyWith(isLiked: nextIsLiked, likeCount: nextLikeCount),
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLiking: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '블로그 좋아요를 처리하지 못했어요.',
        },
      );
      rethrow;
    }
  }
}
