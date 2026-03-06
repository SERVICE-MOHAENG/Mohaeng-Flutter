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
    this.statusCode,
    this.response,
  });

  final bool isLoading;
  final String? errorMessage;
  final int? statusCode;
  final RoadmapItineraryResponse? response;

  RoadmapItineraryState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    int? statusCode,
    bool clearStatusCode = false,
    RoadmapItineraryResponse? response,
    bool keepResponse = true,
  }) {
    return RoadmapItineraryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      statusCode: clearStatusCode ? null : (statusCode ?? this.statusCode),
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

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearStatusCode: true,
    );

    try {
      final response = await _createRoadmapItineraryUsecase(
        request: RoadmapItineraryRequest(surveyId: surveyId.trim()),
      );
      state = state.copyWith(
        isLoading: false,
        clearStatusCode: true,
        response: response,
        clearError: true,
      );
      return true;
    } on ApiError catch (error) {
      state = state.copyWith(
        isLoading: false,
        statusCode: error.statusCode,
        errorMessage: error.message,
      );
      return false;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        clearStatusCode: true,
        errorMessage: switch (error) {
          _ => '여행 일정을 생성하지 못했어요.',
        },
      );
      return false;
    }
  }
}
