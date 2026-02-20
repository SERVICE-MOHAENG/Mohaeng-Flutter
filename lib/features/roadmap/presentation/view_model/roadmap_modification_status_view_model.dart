import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_modification_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_modification_status.dart';

@immutable
class RoadmapModificationStatusState {
  const RoadmapModificationStatusState({
    this.isLoading = false,
    this.errorMessage,
    this.status,
  });

  final bool isLoading;
  final String? errorMessage;
  final RoadmapModificationStatusResponse? status;

  RoadmapModificationStatusState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    RoadmapModificationStatusResponse? status,
    bool keepStatus = true,
  }) {
    return RoadmapModificationStatusState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      status: keepStatus ? (status ?? this.status) : status,
    );
  }
}

class RoadmapModificationStatusViewModel
    extends StateNotifier<RoadmapModificationStatusState> {
  RoadmapModificationStatusViewModel(this._getStatusUsecase)
    : super(const RoadmapModificationStatusState());

  final GetRoadmapModificationStatusUsecase _getStatusUsecase;

  Future<bool> load(String jobId) async {
    if (state.isLoading) return false;
    if (jobId.trim().isEmpty) {
      state = state.copyWith(errorMessage: '작업 ID가 필요합니다.');
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final status = await _getStatusUsecase(jobId: jobId.trim());
      state = state.copyWith(
        isLoading: false,
        status: status,
        clearError: true,
      );
      return true;
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '수정 작업 상태를 불러오지 못했어요.',
        },
      );
      return false;
    }
  }
}
