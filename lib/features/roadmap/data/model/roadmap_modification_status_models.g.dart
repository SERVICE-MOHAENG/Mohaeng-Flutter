// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap_modification_status_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadmapModificationStatusResponse _$RoadmapModificationStatusResponseFromJson(
  Map<String, dynamic> json,
) => RoadmapModificationStatusResponse(
  jobId: json['jobId'] as String,
  status: json['status'] as String,
  intentStatus: json['intentStatus'] as String?,
  message: json['message'],
  diffKeys: (json['diffKeys'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  errorCode: json['errorCode'],
  errorMessage: json['errorMessage'],
  createdAt: _parseDateTimeNullable(json['createdAt']),
  startedAt: _parseDateTimeNullable(json['startedAt']),
  completedAt: _parseDateTimeNullable(json['completedAt']),
  travelCourseId: json['travelCourseId'],
);

Map<String, dynamic> _$RoadmapModificationStatusResponseToJson(
  RoadmapModificationStatusResponse instance,
) => <String, dynamic>{
  'jobId': instance.jobId,
  'status': instance.status,
  'intentStatus': instance.intentStatus,
  'message': instance.message,
  'diffKeys': instance.diffKeys,
  'errorCode': instance.errorCode,
  'errorMessage': instance.errorMessage,
  'createdAt': _dateTimeToJsonNullable(instance.createdAt),
  'startedAt': _dateTimeToJsonNullable(instance.startedAt),
  'completedAt': _dateTimeToJsonNullable(instance.completedAt),
  'travelCourseId': instance.travelCourseId,
};
