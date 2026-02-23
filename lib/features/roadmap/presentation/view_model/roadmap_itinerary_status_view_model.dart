import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_itinerary_status.dart';

@immutable
class RoadmapItineraryStatusState {
  const RoadmapItineraryStatusState({
    this.isLoading = false,
    this.errorMessage,
    this.status,
  });

  final bool isLoading;
  final String? errorMessage;
  final RoadmapItineraryStatusResponse? status;

  RoadmapItineraryStatusState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    RoadmapItineraryStatusResponse? status,
    bool keepStatus = true,
  }) {
    return RoadmapItineraryStatusState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      status: keepStatus ? (status ?? this.status) : status,
    );
  }
}

class RoadmapItineraryStatusViewModel
    extends StateNotifier<RoadmapItineraryStatusState> {
  RoadmapItineraryStatusViewModel(this._getStatusUsecase)
    : super(const RoadmapItineraryStatusState());

  final GetRoadmapItineraryStatusUsecase _getStatusUsecase;

  Future<bool> load(String jobId) async {
    if (state.isLoading) return false;
    if (jobId.trim().isEmpty) {
      state = state.copyWith(errorMessage: '작업 ID가 필요합니다.');
      _logStatus('skip load: empty jobId');
      return false;
    }

    _logStatus('request status: jobId=${jobId.trim()}');

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      keepStatus: false,
    );

    try {
      final status = await _getStatusUsecase(jobId: jobId.trim());
      _logStatus(
        'success status: ${status.status}, attemptCount=${status.attemptCount}',
      );
      state = state.copyWith(
        isLoading: false,
        status: status,
        clearError: true,
      );
      return true;
    } on ApiError catch (error) {
      _logStatus(
        'api error: statusCode=${error.statusCode}, message=${error.message}',
      );
      state = state.copyWith(isLoading: false, errorMessage: error.message);
      return false;
    } catch (error) {
      _logStatus('unknown error: $error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: '일정 생성 상태를 불러오지 못했어요.',
      );
      return false;
    }
  }

  void _logStatus(String message) {
    if (!kDebugMode) return;
    debugPrint('[ROADMAP][STATUS] $message');
  }
}
