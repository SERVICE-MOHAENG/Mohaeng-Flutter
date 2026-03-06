import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'roadmap_itinerary_models.g.dart';

@immutable
@JsonSerializable()
class RoadmapItineraryRequest {
  const RoadmapItineraryRequest({required this.surveyId});

  final String surveyId;

  factory RoadmapItineraryRequest.fromJson(Map<String, dynamic> json) =>
      _$RoadmapItineraryRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapItineraryRequestToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapItineraryResponse {
  const RoadmapItineraryResponse({required this.jobId, required this.status});

  final String jobId;
  final String status;

  factory RoadmapItineraryResponse.fromJson(Map<String, dynamic> json) {
    final source = _normalizeItineraryJson(json);
    final jobId = _readStringValue(
      source,
      keys: const ['jobId', 'job_id', 'id'],
    );
    if (jobId == null || jobId.isEmpty) {
      throw const FormatException('jobId is missing in itinerary response.');
    }

    final status =
        _readStringValue(source, keys: const ['status']) ?? 'PENDING';

    return RoadmapItineraryResponse(jobId: jobId, status: status);
  }

  Map<String, dynamic> toJson() => _$RoadmapItineraryResponseToJson(this);
}

Map<String, dynamic> _normalizeItineraryJson(Map<String, dynamic> json) {
  final itinerary = json['itinerary'];
  if (itinerary is Map<String, dynamic>) {
    return itinerary;
  }
  if (itinerary is Map) {
    return itinerary.map((key, value) => MapEntry(key.toString(), value));
  }

  final job = json['job'];
  if (job is Map<String, dynamic>) {
    return job;
  }
  if (job is Map) {
    return job.map((key, value) => MapEntry(key.toString(), value));
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
