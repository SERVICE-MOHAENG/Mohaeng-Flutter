import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'roadmap_modification_status_models.g.dart';

@immutable
@JsonSerializable()
class RoadmapModificationStatusResponse {
  const RoadmapModificationStatusResponse({
    required this.jobId,
    required this.status,
    this.intentStatus,
    this.message,
    this.diffKeys,
    this.errorCode,
    this.errorMessage,
    this.createdAt,
    this.startedAt,
    this.completedAt,
    this.travelCourseId,
  });

  final String jobId;
  final String status;
  final String? intentStatus;
  final Object? message;
  final List<String>? diffKeys;
  final Object? errorCode;
  final Object? errorMessage;
  @JsonKey(fromJson: _parseDateTimeNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? createdAt;
  @JsonKey(fromJson: _parseDateTimeNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? startedAt;
  @JsonKey(fromJson: _parseDateTimeNullable, toJson: _dateTimeToJsonNullable)
  final DateTime? completedAt;
  @JsonKey(name: 'travelCourseId')
  final Object? travelCourseId;

  factory RoadmapModificationStatusResponse.fromJson(
    Map<String, dynamic> json,
  ) => _$RoadmapModificationStatusResponseFromJson(
    _normalizeModificationStatusJson(json),
  );

  Map<String, dynamic> toJson() =>
      _$RoadmapModificationStatusResponseToJson(this);
}

DateTime? _parseDateTimeNullable(Object? value) {
  if (value == null) return null;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}

String? _dateTimeToJsonNullable(DateTime? value) => value?.toIso8601String();

Map<String, dynamic> _normalizeModificationStatusJson(
  Map<String, dynamic> json,
) {
  final nestedStatus = json['status'];
  if (nestedStatus is Map<String, dynamic>) {
    return nestedStatus;
  }
  if (nestedStatus is Map) {
    return nestedStatus.map((key, value) => MapEntry(key.toString(), value));
  }
  return json;
}
