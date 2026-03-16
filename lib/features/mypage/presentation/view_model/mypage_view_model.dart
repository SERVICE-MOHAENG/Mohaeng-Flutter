import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/liked_region_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/mypage_summary_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/clear_my_page_cache.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/delete_my_account.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_liked_regions.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_blog_likes.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_blogs.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_course_likes.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_courses.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_page_summary.dart';

@immutable
class MyPageState {
  const MyPageState({
    this.isLoadingUser = false,
    this.userErrorMessage,
    this.user,
    this.isLoading = false,
    this.isDeletingAccount = false,
    this.loadErrorMessage,
    this.myCourses,
    this.myBlogs,
    this.myCourseLikes,
    this.myBlogLikes,
    this.likedRegions,
  });

  final bool isLoadingUser;
  final String? userErrorMessage;
  final MyPageSummaryResponse? user;

  final bool isLoading;
  final bool isDeletingAccount;
  final String? loadErrorMessage;
  final CoursesResponse? myCourses;
  final BlogsResponse? myBlogs;
  final CourseItemsResponse? myCourseLikes;
  final BlogItemsResponse? myBlogLikes;
  final LikedRegionsResponse? likedRegions;

  MyPageState copyWith({
    bool? isLoadingUser,
    String? userErrorMessage,
    bool clearUserError = false,
    MyPageSummaryResponse? user,
    bool keepUser = true,
    bool? isLoading,
    bool? isDeletingAccount,
    String? loadErrorMessage,
    bool clearLoadError = false,
    CoursesResponse? myCourses,
    BlogsResponse? myBlogs,
    CourseItemsResponse? myCourseLikes,
    BlogItemsResponse? myBlogLikes,
    LikedRegionsResponse? likedRegions,
  }) {
    return MyPageState(
      isLoadingUser: isLoadingUser ?? this.isLoadingUser,
      userErrorMessage: clearUserError
          ? null
          : (userErrorMessage ?? this.userErrorMessage),
      user: keepUser ? (user ?? this.user) : user,
      isLoading: isLoading ?? this.isLoading,
      isDeletingAccount: isDeletingAccount ?? this.isDeletingAccount,
      loadErrorMessage: clearLoadError
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),
      myCourses: myCourses ?? this.myCourses,
      myBlogs: myBlogs ?? this.myBlogs,
      myCourseLikes: myCourseLikes ?? this.myCourseLikes,
      myBlogLikes: myBlogLikes ?? this.myBlogLikes,
      likedRegions: likedRegions ?? this.likedRegions,
    );
  }
}

class MyPageViewModel extends StateNotifier<MyPageState> {
  MyPageViewModel({
    required GetMyPageSummaryUsecase getMyPageSummaryUsecase,
    required GetMyCoursesUsecase getMyCoursesUsecase,
    required GetMyBlogsUsecase getMyBlogsUsecase,
    required GetMyCourseLikesUsecase getMyCourseLikesUsecase,
    required GetMyBlogLikesUsecase getMyBlogLikesUsecase,
    required GetLikedRegionsUsecase getLikedRegionsUsecase,
    required DeleteMyAccountUsecase deleteMyAccountUsecase,
    required ClearMyPageCacheUsecase clearMyPageCacheUsecase,
    required AuthTokenStorage tokenStorage,
  }) : _getMyPageSummaryUsecase = getMyPageSummaryUsecase,
       _getMyCoursesUsecase = getMyCoursesUsecase,
       _getMyBlogsUsecase = getMyBlogsUsecase,
       _getMyCourseLikesUsecase = getMyCourseLikesUsecase,
       _getMyBlogLikesUsecase = getMyBlogLikesUsecase,
       _getLikedRegionsUsecase = getLikedRegionsUsecase,
       _deleteMyAccountUsecase = deleteMyAccountUsecase,
       _clearMyPageCacheUsecase = clearMyPageCacheUsecase,
       _tokenStorage = tokenStorage,
       super(const MyPageState());

  final GetMyPageSummaryUsecase _getMyPageSummaryUsecase;
  final GetMyCoursesUsecase _getMyCoursesUsecase;
  final GetMyBlogsUsecase _getMyBlogsUsecase;
  final GetMyCourseLikesUsecase _getMyCourseLikesUsecase;
  final GetMyBlogLikesUsecase _getMyBlogLikesUsecase;
  final GetLikedRegionsUsecase _getLikedRegionsUsecase;
  final DeleteMyAccountUsecase _deleteMyAccountUsecase;
  final ClearMyPageCacheUsecase _clearMyPageCacheUsecase;
  final AuthTokenStorage _tokenStorage;

  Future<void> loadInitial({bool forceRefresh = false}) async {
    await Future.wait([
      loadUser(forceRefresh: forceRefresh),
      refreshAll(forceRefresh: forceRefresh),
    ]);
  }

  Future<void> loadUser({bool forceRefresh = false}) async {
    if (state.isLoadingUser) return;

    state = state.copyWith(isLoadingUser: true, clearUserError: true);
    try {
      final user = await _getMyPageSummaryUsecase(forceRefresh: forceRefresh);
      state = state.copyWith(
        isLoadingUser: false,
        user: user,
        clearUserError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoadingUser: false,
        userErrorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '상단 요약 정보를 불러오지 못했어요.',
        },
      );
    }
  }

  Future<void> refreshAll({bool forceRefresh = false}) async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearLoadError: true);

    final errors = <String>[];
    CoursesResponse? myCourses;
    BlogsResponse? myBlogs;
    CourseItemsResponse? myCourseLikes;
    BlogItemsResponse? myBlogLikes;
    LikedRegionsResponse? likedRegions;

    try {
      myCourses = await _getMyCoursesUsecase(
        page: 1,
        limit: 10,
        forceRefresh: forceRefresh,
      );
    } catch (error) {
      errors.add(_errorMessage(error, fallback: '내 여행 일정(코스)을 불러오지 못했어요.'));
    }

    try {
      myBlogs = await _getMyBlogsUsecase(
        page: 1,
        limit: 10,
        forceRefresh: forceRefresh,
      );
    } catch (error) {
      errors.add(_errorMessage(error, fallback: '작성한 여행 기록(블로그)을 불러오지 못했어요.'));
    }

    try {
      myCourseLikes = await _getMyCourseLikesUsecase(
        page: 1,
        limit: 10,
        forceRefresh: forceRefresh,
      );
    } catch (error) {
      errors.add(_errorMessage(error, fallback: '좋아요한 일정 목록을 불러오지 못했어요.'));
    }

    try {
      myBlogLikes = await _getMyBlogLikesUsecase(
        page: 1,
        limit: 10,
        forceRefresh: forceRefresh,
      );
    } catch (error) {
      errors.add(_errorMessage(error, fallback: '좋아요한 블로그 목록을 불러오지 못했어요.'));
    }

    try {
      likedRegions = await _getLikedRegionsUsecase(
        page: 1,
        limit: 10,
        forceRefresh: forceRefresh,
      );
    } catch (error) {
      errors.add(_errorMessage(error, fallback: '좋아요한 여행지 목록을 불러오지 못했어요.'));
    }

    state = state.copyWith(
      myCourses: myCourses,
      myBlogs: myBlogs,
      myCourseLikes: myCourseLikes,
      myBlogLikes: myBlogLikes,
      likedRegions: likedRegions,
      isLoading: false,
      loadErrorMessage: errors.isEmpty ? null : errors.first,
    );
  }

  Future<void> deleteMyAccount() async {
    if (state.isDeletingAccount) return;

    state = state.copyWith(isDeletingAccount: true);
    try {
      await _deleteMyAccountUsecase();
      _clearMyPageCacheUsecase();
      await _tokenStorage.clearTokens();
    } finally {
      if (mounted) {
        state = state.copyWith(isDeletingAccount: false);
      }
    }
  }

  Future<void> logout() async {
    _clearMyPageCacheUsecase();
    await _tokenStorage.clearTokens();
  }

  String _errorMessage(Object error, {required String fallback}) {
    return switch (error) {
      ApiError(:final message) => message,
      _ => fallback,
    };
  }
}
