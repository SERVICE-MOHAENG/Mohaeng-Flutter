import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/domain/usecase/get_main_courses.dart';

@immutable
class MainCoursesState {
  const MainCoursesState({
    this.isLoading = false,
    this.errorMessage,
    this.courses = const <CourseResponse>[],
    this.selectedCountryCode = 'JP',
  });

  final bool isLoading;
  final String? errorMessage;
  final List<CourseResponse> courses;
  final String selectedCountryCode;

  MainCoursesState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<CourseResponse>? courses,
    String? selectedCountryCode,
  }) {
    return MainCoursesState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      courses: courses ?? this.courses,
      selectedCountryCode: selectedCountryCode ?? this.selectedCountryCode,
    );
  }
}

class MainCoursesViewModel extends StateNotifier<MainCoursesState> {
  MainCoursesViewModel(this._getMainCoursesUsecase)
    : super(const MainCoursesState());

  final GetMainCoursesUsecase _getMainCoursesUsecase;

  Future<void> load({String? countryCode}) async {
    if (state.isLoading) return;

    final nextCountryCode = (countryCode ?? state.selectedCountryCode).trim();
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedCountryCode: nextCountryCode,
    );

    try {
      final response = await _getMainCoursesUsecase(
        countryCode: nextCountryCode,
        page: 1,
        limit: 10,
      );

      state = state.copyWith(
        isLoading: false,
        courses: response.courses,
        clearError: true,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '코스를 불러오지 못했어요.',
        },
      );
    }
  }
}
