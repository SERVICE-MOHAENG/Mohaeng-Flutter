// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap_chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadmapChatRequest _$RoadmapChatRequestFromJson(Map<String, dynamic> json) =>
    RoadmapChatRequest(message: json['message'] as String);

Map<String, dynamic> _$RoadmapChatRequestToJson(RoadmapChatRequest instance) =>
    <String, dynamic>{'message': instance.message};

RoadmapChatResponse _$RoadmapChatResponseFromJson(Map<String, dynamic> json) =>
    RoadmapChatResponse(
      jobId: json['jobId'] as String,
      status: json['status'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$RoadmapChatResponseToJson(
  RoadmapChatResponse instance,
) => <String, dynamic>{
  'jobId': instance.jobId,
  'status': instance.status,
  'message': instance.message,
};
