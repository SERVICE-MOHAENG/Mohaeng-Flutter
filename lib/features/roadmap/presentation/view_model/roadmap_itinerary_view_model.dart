import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/create_roadmap_itinerary.dart';

@immutable
class RoadmapItineraryState {
  const RoadmapItineraryState({
    this.isLoading = false,
    this.errorMessage,
    this.response,
  });

  final bool isLoading;
  final String? errorMessage;
  final RoadmapItineraryResponse? response;

  RoadmapItineraryState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    RoadmapItineraryResponse? response,
    bool keepResponse = true,
  }) {
    return RoadmapItineraryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      response: keepResponse ? (response ?? this.response) : response,
    );
  }
}

class RoadmapItineraryViewModel extends StateNotifier<RoadmapItineraryState> {
  RoadmapItineraryViewModel(this._createRoadmapItineraryUsecase)
    : super(const RoadmapItineraryState());

  final CreateRoadmapItineraryUsecase _createRoadmapItineraryUsecase;

  Future<bool> submit(String surveyId) async {
    if (state.isLoading) return false;
    if (surveyId.trim().isEmpty) {
      state = state.copyWith(errorMessage: '설문 ID가 필요합니다.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _createRoadmapItineraryUsecase(
        request: RoadmapItineraryRequest(surveyId: surveyId.trim()),
      );
      state = state.copyWith(
        isLoading: false,
        response: response,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '여행 일정을 생성하지 못했어요.',
        },
      );
      return false;
    }
  }
}
