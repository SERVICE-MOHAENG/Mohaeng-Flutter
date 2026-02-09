import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/main/data/model/user_models.dart';
import 'package:mohaeng_app_service/features/main/domain/usecase/get_main_user_me.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/visited_country_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_blogs.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_course_bookmarks.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_courses.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_visited_countries.dart';

@immutable
class MyPageState {
  const MyPageState({
    this.isLoadingUser = false,
    this.userErrorMessage,
    this.user,
    this.isLoading = false,
    this.loadErrorMessage,
    this.myCourses,
    this.myCourseBookmarks,
    this.myBlogs,
    this.visitedCountries,
  });

  final bool isLoadingUser;
  final String? userErrorMessage;
  final MainUserResponse? user;

  final bool isLoading;
  final String? loadErrorMessage;
  final CoursesResponse? myCourses;
  final CourseItemsResponse? myCourseBookmarks;
  final BlogsResponse? myBlogs;
  final VisitedCountryItemsResponse? visitedCountries;

  MyPageState copyWith({
    bool? isLoadingUser,
    String? userErrorMessage,
    bool clearUserError = false,
    MainUserResponse? user,
    bool keepUser = true,
    bool? isLoading,
    String? loadErrorMessage,
    bool clearLoadError = false,
    CoursesResponse? myCourses,
    CourseItemsResponse? myCourseBookmarks,
    BlogsResponse? myBlogs,
    VisitedCountryItemsResponse? visitedCountries,
  }) {
    return MyPageState(
      isLoadingUser: isLoadingUser ?? this.isLoadingUser,
      userErrorMessage: clearUserError
          ? null
          : (userErrorMessage ?? this.userErrorMessage),
      user: keepUser ? (user ?? this.user) : user,
      isLoading: isLoading ?? this.isLoading,
      loadErrorMessage: clearLoadError
          ? null
          : (loadErrorMessage ?? this.loadErrorMessage),
      myCourses: myCourses ?? this.myCourses,
      myCourseBookmarks: myCourseBookmarks ?? this.myCourseBookmarks,
      myBlogs: myBlogs ?? this.myBlogs,
      visitedCountries: visitedCountries ?? this.visitedCountries,
    );
  }
}

class MyPageViewModel extends StateNotifier<MyPageState> {
  MyPageViewModel({
    required GetMainUserMeUsecase getMainUserMeUsecase,
    required GetMyCoursesUsecase getMyCoursesUsecase,
    required GetMyCourseBookmarksUsecase getMyCourseBookmarksUsecase,
    required GetMyBlogsUsecase getMyBlogsUsecase,
    required GetVisitedCountriesUsecase getVisitedCountriesUsecase,
  }) : _getMainUserMeUsecase = getMainUserMeUsecase,
       _getMyCoursesUsecase = getMyCoursesUsecase,
       _getMyCourseBookmarksUsecase = getMyCourseBookmarksUsecase,
       _getMyBlogsUsecase = getMyBlogsUsecase,
       _getVisitedCountriesUsecase = getVisitedCountriesUsecase,
       super(const MyPageState());

  final GetMainUserMeUsecase _getMainUserMeUsecase;
  final GetMyCoursesUsecase _getMyCoursesUsecase;
  final GetMyCourseBookmarksUsecase _getMyCourseBookmarksUsecase;
  final GetMyBlogsUsecase _getMyBlogsUsecase;
  final GetVisitedCountriesUsecase _getVisitedCountriesUsecase;

  Future<void> loadInitial() async {
    await Future.wait([loadUser(), refreshAll()]);
  }

  Future<void> loadUser() async {
    if (state.isLoadingUser) return;

    state = state.copyWith(isLoadingUser: true, clearUserError: true);
    try {
      final user = await _getMainUserMeUsecase();
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
          _ => '사용자 정보를 불러오지 못했어요.',
        },
      );
    }
  }

  Future<void> refreshAll() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearLoadError: true);

    final errors = <String>[];
    CoursesResponse? myCourses;
    CourseItemsResponse? myCourseBookmarks;
    BlogsResponse? myBlogs;
    VisitedCountryItemsResponse? visitedCountries;

    try {
      myCourses = await _getMyCoursesUsecase(page: 1, limit: 20);
    } catch (error) {
      errors.add(_errorMessage(error, fallback: '내 여행 일정(코스)을 불러오지 못했어요.'));
    }

    try {
      myCourseBookmarks = await _getMyCourseBookmarksUsecase(
        page: 1,
        limit: 20,
      );
    } catch (error) {
      errors.add(_errorMessage(error, fallback: '북마크한 코스를 불러오지 못했어요.'));
    }

    try {
      myBlogs = await _getMyBlogsUsecase(page: 1, limit: 6);
    } catch (error) {
      errors.add(_errorMessage(error, fallback: '작성한 여행 기록(블로그)을 불러오지 못했어요.'));
    }

    try {
      visitedCountries = await _getVisitedCountriesUsecase(page: 1, limit: 10);
    } catch (error) {
      errors.add(_errorMessage(error, fallback: '방문한 국가를 불러오지 못했어요.'));
    }

    state = state.copyWith(
      myCourses: myCourses,
      myCourseBookmarks: myCourseBookmarks,
      myBlogs: myBlogs,
      visitedCountries: visitedCountries,
      isLoading: false,
      loadErrorMessage: errors.isEmpty ? null : errors.first,
    );
  }

  String _errorMessage(Object error, {required String fallback}) {
    return switch (error) {
      ApiError(:final message) => message,
      _ => fallback,
    };
  }
}
