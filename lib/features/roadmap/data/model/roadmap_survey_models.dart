import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_types.dart';

part 'roadmap_survey_models.g.dart';

@immutable
@JsonSerializable()
class RoadmapSurveyRegionRequest {
  const RoadmapSurveyRegionRequest({
    required this.region,
    required this.startDate,
    required this.endDate,
  });

  final String region;
  @JsonKey(name: 'start_date', toJson: _formatDate, fromJson: _parseDate)
  final DateTime startDate;
  @JsonKey(name: 'end_date', toJson: _formatDate, fromJson: _parseDate)
  final DateTime endDate;

  factory RoadmapSurveyRegionRequest.fromJson(Map<String, dynamic> json) =>
      _$RoadmapSurveyRegionRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapSurveyRegionRequestToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapSurveyRequest {
  const RoadmapSurveyRequest({
    required this.startDate,
    required this.endDate,
    required this.regions,
    required this.peopleCount,
    required this.companionTypes,
    required this.travelThemes,
    required this.pacePreference,
    required this.planningPreference,
    required this.destinationPreference,
    required this.activityPreference,
    required this.priorityPreference,
    required this.budgetRange,
    this.notes = '',
  });

  @JsonKey(name: 'start_date', toJson: _formatDate, fromJson: _parseDate)
  final DateTime startDate;
  @JsonKey(name: 'end_date', toJson: _formatDate, fromJson: _parseDate)
  final DateTime endDate;
  final List<RoadmapSurveyRegionRequest> regions;
  @JsonKey(name: 'people_count')
  final int peopleCount;
  @JsonKey(
    name: 'companion_type',
    toJson: _companionTypeListToJson,
    fromJson: _companionTypeListFromJson,
  )
  final List<CompanionType> companionTypes;
  @JsonKey(
    name: 'travel_themes',
    toJson: _travelConceptListToJson,
    fromJson: _travelConceptListFromJson,
  )
  final List<TravelConcept> travelThemes;
  @JsonKey(
    name: 'pace_preference',
    toJson: _pacePreferenceToJson,
    fromJson: _pacePreferenceFromJson,
  )
  final PacePreference pacePreference;
  @JsonKey(
    name: 'planning_preference',
    toJson: _planningPreferenceToJson,
    fromJson: _planningPreferenceFromJson,
  )
  final PlanningPreference planningPreference;
  @JsonKey(
    name: 'destination_preference',
    toJson: _destinationPreferenceToJson,
    fromJson: _destinationPreferenceFromJson,
  )
  final DestinationPreference destinationPreference;
  @JsonKey(
    name: 'activity_preference',
    toJson: _activityPreferenceToJson,
    fromJson: _activityPreferenceFromJson,
  )
  final ActivityPreference activityPreference;
  @JsonKey(
    name: 'priority_preference',
    toJson: _priorityPreferenceToJson,
    fromJson: _priorityPreferenceFromJson,
  )
  final PriorityPreference priorityPreference;
  @JsonKey(
    name: 'budget_range',
    toJson: _budgetRangeToJson,
    fromJson: _budgetRangeFromJson,
  )
  final BudgetRange budgetRange;
  final String notes;

  factory RoadmapSurveyRequest.fromJson(Map<String, dynamic> json) =>
      _$RoadmapSurveyRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapSurveyRequestToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapSurveyResponse {
  const RoadmapSurveyResponse({
    required this.surveyId,
    required this.jobId,
    required this.status,
  });

  @JsonKey(name: 'surveyId')
  final String surveyId;
  @JsonKey(name: 'jobId')
  final String jobId;
  final String status;

  factory RoadmapSurveyResponse.fromJson(Map<String, dynamic> json) {
    final source = _normalizeSurveyJson(json);
    final surveyId = _readStringValue(
      source,
      keys: const ['surveyId', 'survey_id'],
    );

    if (surveyId == null || surveyId.isEmpty) {
      throw const FormatException('surveyId is missing in survey response.');
    }

    final jobId =
        _readStringValue(source, keys: const ['jobId', 'job_id']) ?? '';
    final status =
        _readStringValue(source, keys: const ['status']) ?? 'PENDING';

    return RoadmapSurveyResponse(
      surveyId: surveyId,
      jobId: jobId,
      status: status,
    );
  }

  Map<String, dynamic> toJson() => _$RoadmapSurveyResponseToJson(this);
}

Map<String, dynamic> _normalizeSurveyJson(Map<String, dynamic> json) {
  final survey = json['survey'];
  if (survey is Map<String, dynamic>) {
    return survey;
  }
  if (survey is Map) {
    return survey.map((key, value) => MapEntry(key.toString(), value));
  }
  return json;
}

String? _readStringValue(
  Map<String, dynamic> json, {
  required List<String> keys,
}) {
  for (final key in keys) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return null;
}

String _formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime _parseDate(String value) {
  final parts = value.split('-');
  if (parts.length == 3) {
    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);
    if (year != null && month != null && day != null) {
      return DateTime(year, month, day);
    }
  }
  return DateTime.tryParse(value) ?? DateTime(1970, 1, 1);
}

String _pacePreferenceToJson(PacePreference value) => value.apiValue;
PacePreference _pacePreferenceFromJson(String value) => PacePreference.values
    .firstWhere((e) => e.apiValue == value, orElse: () => PacePreference.DENSE);

String _planningPreferenceToJson(PlanningPreference value) => value.apiValue;
PlanningPreference _planningPreferenceFromJson(String value) =>
    PlanningPreference.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => PlanningPreference.PLANNED,
    );

String _destinationPreferenceToJson(DestinationPreference value) =>
    value.apiValue;
DestinationPreference _destinationPreferenceFromJson(String value) =>
    DestinationPreference.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => DestinationPreference.TOURIST_SPOTS,
    );

String _activityPreferenceToJson(ActivityPreference value) => value.apiValue;
ActivityPreference _activityPreferenceFromJson(String value) =>
    ActivityPreference.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => ActivityPreference.ACTIVE,
    );

String _priorityPreferenceToJson(PriorityPreference value) => value.apiValue;
PriorityPreference _priorityPreferenceFromJson(String value) =>
    PriorityPreference.values.firstWhere(
      (e) => e.apiValue == value,
      orElse: () => PriorityPreference.EFFICIENCY,
    );

String _budgetRangeToJson(BudgetRange value) => value.apiValue;
BudgetRange _budgetRangeFromJson(String value) => BudgetRange.values.firstWhere(
  (e) => e.apiValue == value,
  orElse: () => BudgetRange.MID,
);

List<String> _companionTypeListToJson(List<CompanionType> values) =>
    values.map((value) => value.apiValue).toList();
List<CompanionType> _companionTypeListFromJson(List<dynamic> values) => values
    .map((value) => value.toString())
    .map(
      (value) => CompanionType.values.firstWhere(
        (e) => e.apiValue == value,
        orElse: () => CompanionType.solo,
      ),
    )
    .toList();

List<String> _travelConceptListToJson(List<TravelConcept> values) =>
    values.map((value) => value.apiValue).toList();
List<TravelConcept> _travelConceptListFromJson(List<dynamic> values) => values
    .map((value) => value.toString())
    .map(
      (value) => TravelConcept.values.firstWhere(
        (e) => e.apiValue == value,
        orElse: () => TravelConcept.sightseeing,
      ),
    )
    .toList();
