import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'roadmap_chat_models.g.dart';

@immutable
@JsonSerializable()
class RoadmapChatRequest {
  const RoadmapChatRequest({required this.message});

  final String message;

  factory RoadmapChatRequest.fromJson(Map<String, dynamic> json) =>
      _$RoadmapChatRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapChatRequestToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapChatResponse {
  const RoadmapChatResponse({
    required this.jobId,
    required this.status,
    required this.message,
  });

  final String jobId;
  final String status;
  final String message;

  factory RoadmapChatResponse.fromJson(Map<String, dynamic> json) =>
      _$RoadmapChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapChatResponseToJson(this);
}
