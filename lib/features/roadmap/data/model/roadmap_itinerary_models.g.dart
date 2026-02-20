// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap_itinerary_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadmapItineraryRequest _$RoadmapItineraryRequestFromJson(
  Map<String, dynamic> json,
) => RoadmapItineraryRequest(surveyId: json['surveyId'] as String);

Map<String, dynamic> _$RoadmapItineraryRequestToJson(
  RoadmapItineraryRequest instance,
) => <String, dynamic>{'surveyId': instance.surveyId};

RoadmapItineraryResponse _$RoadmapItineraryResponseFromJson(
  Map<String, dynamic> json,
) => RoadmapItineraryResponse(
  jobId: json['jobId'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$RoadmapItineraryResponseToJson(
  RoadmapItineraryResponse instance,
) => <String, dynamic>{'jobId': instance.jobId, 'status': instance.status};
