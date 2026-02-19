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
  const RoadmapItineraryResponse({
    required this.jobId,
    required this.status,
  });

  final String jobId;
  final String status;

  factory RoadmapItineraryResponse.fromJson(Map<String, dynamic> json) =>
      _$RoadmapItineraryResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapItineraryResponseToJson(this);
}
