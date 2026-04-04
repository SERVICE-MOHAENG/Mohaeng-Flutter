import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_courses.dart';

@immutable
class BlogCourseSelectionState {
  const BlogCourseSelectionState({
    this.isLoading = false,
    this.errorMessage,
    this.courses = const <CourseResponse>[],
  });

  final bool isLoading;
  final String? errorMessage;
  final List<CourseResponse> courses;

  BlogCourseSelectionState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<CourseResponse>? courses,
  }) {
    return BlogCourseSelectionState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      courses: courses ?? this.courses,
    );
  }
}

class BlogCourseSelectionViewModel
    extends StateNotifier<BlogCourseSelectionState> {
  BlogCourseSelectionViewModel(this._getMyCoursesUsecase)
    : super(const BlogCourseSelectionState());

  final GetMyCoursesUsecase _getMyCoursesUsecase;

  Future<void> load() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _getMyCoursesUsecase(
        page: 1,
        limit: 20,
        forceRefresh: true,
      );

      final completedCourses = response.courses
          .where((course) => course.isCompleted ?? false)
          .toList(growable: false);

      state = state.copyWith(
        isLoading: false,
        courses: completedCourses,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '완료한 로드맵을 불러오지 못했어요.',
        },
      );
    }
  }
}
