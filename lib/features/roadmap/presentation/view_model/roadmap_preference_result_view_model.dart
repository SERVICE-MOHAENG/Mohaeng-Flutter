import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_preference_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_preference_job_result.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/get_roadmap_preference_me_result.dart';

@immutable
class RoadmapPreferenceResultState {
  const RoadmapPreferenceResultState({
    this.isLoading = false,
    this.errorMessage,
    this.items = const <RoadmapPreferenceResultItem>[],
    this.lastRequestedJobId,
  });

  final bool isLoading;
  final String? errorMessage;
  final List<RoadmapPreferenceResultItem> items;
  final String? lastRequestedJobId;

  RoadmapPreferenceResultState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<RoadmapPreferenceResultItem>? items,
    String? lastRequestedJobId,
  }) {
    return RoadmapPreferenceResultState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      items: items ?? this.items,
      lastRequestedJobId: lastRequestedJobId ?? this.lastRequestedJobId,
    );
  }
}

class RoadmapPreferenceResultViewModel
    extends StateNotifier<RoadmapPreferenceResultState> {
  static const String _meRequestKey = '__me__';

  RoadmapPreferenceResultViewModel(
    this._getPreferenceJobResultUsecase,
    this._getPreferenceMeResultUsecase,
  ) : super(const RoadmapPreferenceResultState());

  final GetRoadmapPreferenceJobResultUsecase _getPreferenceJobResultUsecase;
  final GetRoadmapPreferenceMeResultUsecase _getPreferenceMeResultUsecase;

  Future<bool> load(String jobId, {bool force = false}) async {
    final normalizedJobId = jobId.trim();
    if (normalizedJobId.isEmpty) {
      _logPreference('skip load: empty jobId');
      state = state.copyWith(errorMessage: '작업 ID가 필요합니다.');
      return false;
    }

    if (state.isLoading && state.lastRequestedJobId == normalizedJobId) {
      _logPreference('skip load: already loading jobId=$normalizedJobId');
      return false;
    }

    if (!force &&
        state.lastRequestedJobId == normalizedJobId &&
        state.items.isNotEmpty) {
      _logPreference(
        'skip load: already has result jobId=$normalizedJobId, itemCount=${state.items.length}',
      );
      return true;
    }

    _logPreference('request result: jobId=$normalizedJobId');

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      lastRequestedJobId: normalizedJobId,
    );

    try {
      final items = await _getPreferenceJobResultUsecase(
        jobId: normalizedJobId,
      );
      _logPreference(
        'success result: jobId=$normalizedJobId, itemCount=${items.length}',
      );
      state = state.copyWith(isLoading: false, clearError: true, items: items);
      return true;
    } catch (error) {
      _logPreference('error result: jobId=$normalizedJobId, error=$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '추천 여행지를 불러오지 못했어요.',
        },
      );
      return false;
    }
  }

  Future<bool> loadMine({bool force = false}) async {
    if (state.isLoading && state.lastRequestedJobId == _meRequestKey) {
      _logPreference('skip load: already loading me result');
      return false;
    }

    if (!force &&
        state.lastRequestedJobId == _meRequestKey &&
        state.items.isNotEmpty) {
      _logPreference(
        'skip load: already has me result, itemCount=${state.items.length}',
      );
      return true;
    }

    _logPreference('request result: me');

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      lastRequestedJobId: _meRequestKey,
    );

    try {
      final items = await _getPreferenceMeResultUsecase();
      _logPreference('success result: me, itemCount=${items.length}');
      state = state.copyWith(isLoading: false, clearError: true, items: items);
      return true;
    } catch (error) {
      _logPreference('error result: me, error=$error');
      state = state.copyWith(
        isLoading: false,
        errorMessage: switch (error) {
          ApiError(:final message) => message,
          _ => '추천 여행지를 불러오지 못했어요.',
        },
      );
      return false;
    }
  }

  void toggleLike(RoadmapPreferenceResultItem target) {
    final nextItems = state.items
        .map((item) {
          if (!_isSamePreferenceItem(item, target)) return item;

          final isLiked = item.isLiked ?? false;
          final nextIsLiked = !isLiked;
          final currentLikeCount = item.likeCount ?? 0;
          final nextLikeCount = nextIsLiked
              ? currentLikeCount + 1
              : currentLikeCount > 0
              ? currentLikeCount - 1
              : 0;

          return RoadmapPreferenceResultItem(
            regionName: item.regionName,
            description: item.description,
            imageUrl: item.imageUrl,
            regionId: item.regionId,
            likeCount: nextLikeCount,
            isLiked: nextIsLiked,
          );
        })
        .toList(growable: false);

    state = state.copyWith(items: nextItems);
  }

  void _logPreference(String message) {
    if (!kDebugMode) return;
    debugPrint('[ROADMAP][PREFERENCE] $message');
  }

  bool _isSamePreferenceItem(
    RoadmapPreferenceResultItem left,
    RoadmapPreferenceResultItem right,
  ) {
    final leftRegionId = _normalizeComparableValue(left.regionId);
    final rightRegionId = _normalizeComparableValue(right.regionId);
    if (leftRegionId != null && rightRegionId != null) {
      return leftRegionId == rightRegionId;
    }

    final leftRegionName = left.regionName.trim();
    final rightRegionName = right.regionName.trim();
    if (leftRegionName.isNotEmpty && rightRegionName.isNotEmpty) {
      return leftRegionName == rightRegionName &&
          _normalizeComparableValue(left.imageUrl) ==
              _normalizeComparableValue(right.imageUrl) &&
          _normalizeComparableValue(left.description) ==
              _normalizeComparableValue(right.description);
    }

    return identical(left, right);
  }

  String? _normalizeComparableValue(Object? value) {
    if (value == null) return null;
    if (value is Map || value is List) return value.toString();

    final normalized = value.toString().trim();
    return normalized.isEmpty ? null : normalized;
  }
}
