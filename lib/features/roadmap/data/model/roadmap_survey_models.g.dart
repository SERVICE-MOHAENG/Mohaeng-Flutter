// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap_survey_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadmapSurveyRegionRequest _$RoadmapSurveyRegionRequestFromJson(
  Map<String, dynamic> json,
) => RoadmapSurveyRegionRequest(
  region: json['region'] as String,
  startDate: _parseDate(json['start_date'] as String),
  endDate: _parseDate(json['end_date'] as String),
);

Map<String, dynamic> _$RoadmapSurveyRegionRequestToJson(
  RoadmapSurveyRegionRequest instance,
) => <String, dynamic>{
  'region': instance.region,
  'start_date': _formatDate(instance.startDate),
  'end_date': _formatDate(instance.endDate),
};

RoadmapSurveyRequest _$RoadmapSurveyRequestFromJson(
  Map<String, dynamic> json,
) => RoadmapSurveyRequest(
  startDate: _parseDate(json['start_date'] as String),
  endDate: _parseDate(json['end_date'] as String),
  regions: (json['regions'] as List<dynamic>)
      .map(
        (e) => RoadmapSurveyRegionRequest.fromJson(e as Map<String, dynamic>),
      )
      .toList(),
  peopleCount: (json['people_count'] as num).toInt(),
  companionTypes: _companionTypeListFromJson(json['companion_type'] as List),
  travelThemes: _travelConceptListFromJson(json['travel_themes'] as List),
  pacePreference: _pacePreferenceFromJson(json['pace_preference'] as String),
  planningPreference: _planningPreferenceFromJson(
    json['planning_preference'] as String,
  ),
  destinationPreference: _destinationPreferenceFromJson(
    json['destination_preference'] as String,
  ),
  activityPreference: _activityPreferenceFromJson(
    json['activity_preference'] as String,
  ),
  priorityPreference: _priorityPreferenceFromJson(
    json['priority_preference'] as String,
  ),
  budgetRange: _budgetRangeFromJson(json['budget_range'] as String),
  notes: json['notes'] as String? ?? '',
);

Map<String, dynamic> _$RoadmapSurveyRequestToJson(
  RoadmapSurveyRequest instance,
) => <String, dynamic>{
  'start_date': _formatDate(instance.startDate),
  'end_date': _formatDate(instance.endDate),
  'regions': instance.regions,
  'people_count': instance.peopleCount,
  'companion_type': _companionTypeListToJson(instance.companionTypes),
  'travel_themes': _travelConceptListToJson(instance.travelThemes),
  'pace_preference': _pacePreferenceToJson(instance.pacePreference),
  'planning_preference': _planningPreferenceToJson(instance.planningPreference),
  'destination_preference': _destinationPreferenceToJson(
    instance.destinationPreference,
  ),
  'activity_preference': _activityPreferenceToJson(instance.activityPreference),
  'priority_preference': _priorityPreferenceToJson(instance.priorityPreference),
  'budget_range': _budgetRangeToJson(instance.budgetRange),
  'notes': instance.notes,
};

RoadmapSurveyResponse _$RoadmapSurveyResponseFromJson(
  Map<String, dynamic> json,
) => RoadmapSurveyResponse(
  surveyId: json['surveyId'] as String,
  jobId: json['jobId'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$RoadmapSurveyResponseToJson(
  RoadmapSurveyResponse instance,
) => <String, dynamic>{
  'surveyId': instance.surveyId,
  'jobId': instance.jobId,
  'status': instance.status,
};
