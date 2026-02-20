import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_itinerary_result.dart';

@immutable
class RoadmapItineraryResultState {
  const RoadmapItineraryResultState({
    this.isLoading = false,
    this.errorMessage,
    this.result,
  });

  final bool isLoading;
  final String? errorMessage;
  final RoadmapItineraryResultResponse? result;

  RoadmapItineraryResultState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    RoadmapItineraryResultResponse? result,
    bool keepResult = true,
  }) {
    return RoadmapItineraryResultState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: keepResult ? (result ?? this.result) : result,
    );
  }
}

class RoadmapItineraryResultViewModel
    extends StateNotifier<RoadmapItineraryResultState> {
  RoadmapItineraryResultViewModel(this._getResultUsecase)
    : super(const RoadmapItineraryResultState());

  final GetRoadmapItineraryResultUsecase _getResultUsecase;

  Future<bool> load(String jobId) async {
    if (state.isLoading) return false;
    if (jobId.trim().isEmpty) {
      state = state.copyWith(errorMessage: '작업 ID가 필요합니다.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _getResultUsecase(jobId: jobId.trim());
      state = state.copyWith(
        isLoading: false,
        result: result,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '일정 결과를 불러오지 못했어요.',
        },
      );
      return false;
    }
  }
}
