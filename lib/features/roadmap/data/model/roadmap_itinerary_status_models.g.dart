// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap_itinerary_status_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadmapItineraryStatusResponse _$RoadmapItineraryStatusResponseFromJson(
  Map<String, dynamic> json,
) => RoadmapItineraryStatusResponse(
  status: json['status'] as String,
  attemptCount: (json['attemptCount'] as num).toInt(),
  errorCode: json['errorCode'],
  errorMessage: json['errorMessage'],
  createdAt: _parseDateTimeNullable(json['createdAt']),
  startedAt: _parseDateTimeNullable(json['startedAt']),
  completedAt: _parseDateTimeNullable(json['completedAt']),
);

Map<String, dynamic> _$RoadmapItineraryStatusResponseToJson(
  RoadmapItineraryStatusResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'attemptCount': instance.attemptCount,
  'errorCode': instance.errorCode,
  'errorMessage': instance.errorMessage,
  'createdAt': _dateTimeToJsonNullable(instance.createdAt),
  'startedAt': _dateTimeToJsonNullable(instance.startedAt),
  'completedAt': _dateTimeToJsonNullable(instance.completedAt),
};
