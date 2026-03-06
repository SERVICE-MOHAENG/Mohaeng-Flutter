import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'roadmap_itinerary_status_models.g.dart';

@immutable
@JsonSerializable()
class RoadmapItineraryStatusResponse {
  const RoadmapItineraryStatusResponse({
    required this.status,
    required this.attemptCount,
    this.errorCode,
    this.errorMessage,
    this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  final String status;
  final int attemptCount;
  final Object? errorCode;
  final Object? errorMessage;
  @JsonKey(fromJson: _parseDateTimeNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? createdAt;
  @JsonKey(fromJson: _parseDateTimeNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? startedAt;
  @JsonKey(fromJson: _parseDateTimeNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? completedAt;

  factory RoadmapItineraryStatusResponse.fromJson(Map<String, dynamic> json) {
    final nestedStatus = json['status'];
    if (nestedStatus is Map<String, dynamic>) {
      return _$RoadmapItineraryStatusResponseFromJson(nestedStatus);
    }
    if (nestedStatus is Map) {
      return _$RoadmapItineraryStatusResponseFromJson(
        nestedStatus.map((key, value) => MapEntry(key.toString(), value)),
      );
    }
    return _$RoadmapItineraryStatusResponseFromJson(json);
  }

  Map<String, dynamic> toJson() => _$RoadmapItineraryStatusResponseToJson(this);
}

DateTime? _parseDateTimeNullable(Object? value) {
  if (value == null) return null;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

String? _dateTimeToJsonNullable(DateTime? value) => value?.toIso8601String();
