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

  factory RoadmapChatResponse.fromJson(Map<String, dynamic> json) {
    final source = _normalizeChatJson(json);
    final jobId = _readStringValue(source, keys: const ['jobId', 'job_id']);
    if (jobId == null || jobId.isEmpty) {
      throw const FormatException('jobId is missing in chat response.');
    }

    final status =
        _readStringValue(source, keys: const ['status']) ?? 'PENDING';
    final message = _readStringValue(source, keys: const ['message']) ?? '';

    return RoadmapChatResponse(jobId: jobId, status: status, message: message);
  }

  Map<String, dynamic> toJson() => _$RoadmapChatResponseToJson(this);
}

Map<String, dynamic> _normalizeChatJson(Map<String, dynamic> json) {
  final chat = json['chat'];
  if (chat is Map<String, dynamic>) {
    return chat;
  }
  if (chat is Map) {
    return chat.map((key, value) => MapEntry(key.toString(), value));
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
    if ((value is num || value is bool) && value.toString().isNotEmpty) {
      return value.toString();
    }
  }
  return null;
}
