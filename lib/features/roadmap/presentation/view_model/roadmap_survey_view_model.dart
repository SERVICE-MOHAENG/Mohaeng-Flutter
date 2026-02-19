import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_survey_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/usecase/create_roadmap_survey.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/additional_request_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/budget_range_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/companion_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/concept_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/people_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/region_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/schedule_select_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/travel_style_select_view_model.dart';

@immutable
class RoadmapSurveyState {
  const RoadmapSurveyState({
    this.isLoading = false,
    this.errorMessage,
    this.response,
  });

  final bool isLoading;
  final String? errorMessage;
  final RoadmapSurveyResponse? response;

  RoadmapSurveyState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    RoadmapSurveyResponse? response,
    bool keepResponse = true,
  }) {
    return RoadmapSurveyState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      response: keepResponse ? (response ?? this.response) : response,
    );
  }
}

class RoadmapSurveyViewModel extends StateNotifier<RoadmapSurveyState> {
  RoadmapSurveyViewModel(this._createRoadmapSurveyUsecase)
    : super(const RoadmapSurveyState());

  final CreateRoadmapSurveyUsecase _createRoadmapSurveyUsecase;

  Future<bool> submit(RoadmapSurveyRequest request) async {
    if (state.isLoading) return false;

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _createRoadmapSurveyUsecase(request: request);
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
          _ => '로드맵 설문을 저장하지 못했어요.',
        },
      );
      return false;
    }
  }

  Future<bool> submitFromSelections({
    required ScheduleSelectState schedule,
    required RegionSelectState region,
    required PeopleSelectState people,
    required CompanionSelectState companion,
    required ConceptSelectState concept,
    required TravelStyleSelectState style,
    required BudgetRangeState budget,
    required AdditionalRequestState additional,
  }) async {
    final result = _buildRequest(
      schedule: schedule,
      region: region,
      people: people,
      companion: companion,
      concept: concept,
      style: style,
      budget: budget,
      additional: additional,
    );

    if (result.request == null) {
      state = state.copyWith(errorMessage: result.errorMessage);
      return false;
    }

    return submit(result.request!);
  }
}

_SurveyBuildResult _buildRequest({
  required ScheduleSelectState schedule,
  required RegionSelectState region,
  required PeopleSelectState people,
  required CompanionSelectState companion,
  required ConceptSelectState concept,
  required TravelStyleSelectState style,
  required BudgetRangeState budget,
  required AdditionalRequestState additional,
}) {
  final start = schedule.startDate;
  final end = schedule.endDate;
  if (start == null || end == null) {
    return const _SurveyBuildResult.error('여행 날짜를 선택해주세요.');
  }

  if (end.isBefore(start)) {
    return const _SurveyBuildResult.error('여행 날짜를 다시 선택해주세요.');
  }

  if (_daysBetween(start, end) > 7) {
    return const _SurveyBuildResult.error('여행 기간은 최대 7일로 선택해주세요.');
  }

  final regions = region.selectedCities;
  if (regions.isEmpty) {
    return const _SurveyBuildResult.error('여행 지역을 선택해주세요.');
  }

  final companionType = companion.selected;
  if (companionType == null) {
    return const _SurveyBuildResult.error('동행인을 선택해주세요.');
  }

  if (concept.selected.isEmpty) {
    return const _SurveyBuildResult.error('여행 컨셉을 선택해주세요.');
  }

  final pace = style.pacePreference;
  final planning = style.planningPreference;
  final destination = style.destinationPreference;
  final activity = style.activityPreference;
  final priority = style.priorityPreference;
  if (pace == null ||
      planning == null ||
      destination == null ||
      activity == null ||
      priority == null) {
    return const _SurveyBuildResult.error('여행 스타일을 선택해주세요.');
  }

  final budgetRange = budget.range;
  if (budgetRange == null) {
    return const _SurveyBuildResult.error('예산 범위를 선택해주세요.');
  }

  final request = RoadmapSurveyRequest(
    startDate: start,
    endDate: end,
    regions: regions
        .map(
          (regionName) => RoadmapSurveyRegionRequest(
            region: regionName,
            startDate: start,
            endDate: end,
          ),
        )
        .toList(),
    peopleCount: people.count,
    companionTypes: [companionType],
    travelThemes: concept.selected.toList(),
    pacePreference: pace,
    planningPreference: planning,
    destinationPreference: destination,
    activityPreference: activity,
    priorityPreference: priority,
    budgetRange: budgetRange,
    notes: additional.request.trim(),
  );

  return _SurveyBuildResult(request: request);
}

int _daysBetween(DateTime start, DateTime end) {
  final normalizedStart = DateTime(start.year, start.month, start.day);
  final normalizedEnd = DateTime(end.year, end.month, end.day);
  return normalizedEnd.difference(normalizedStart).inDays;
}

@immutable
class _SurveyBuildResult {
  const _SurveyBuildResult({this.request, this.errorMessage});

  const _SurveyBuildResult.error(String message)
    : request = null,
      errorMessage = message;

  final RoadmapSurveyRequest? request;
  final String? errorMessage;
}
