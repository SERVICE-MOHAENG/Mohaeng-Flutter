import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'roadmap_itinerary_result_models.g.dart';

@immutable
@JsonSerializable()
class RoadmapItineraryResultResponse {
  const RoadmapItineraryResultResponse({
    required this.status,
    this.data,
    this.error,
  });

  final String status;
  final RoadmapItineraryData? data;
  final RoadmapItineraryError? error;

  factory RoadmapItineraryResultResponse.fromJson(Map<String, dynamic> json) =>
      _$RoadmapItineraryResultResponseFromJson(json);

  Map<String, dynamic> toJson() =>
      _$RoadmapItineraryResultResponseToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapItineraryData {
  const RoadmapItineraryData({
    this.startDate,
    this.endDate,
    this.tripDays,
    this.nights,
    this.peopleCount,
    this.regions,
    this.tags,
    this.title,
    this.summary,
    this.itinerary,
    this.llmCommentary,
    this.nextActionSuggestion,
  });

  @JsonKey(name: 'start_date', fromJson: _parseDateTimeNullable)
  final DateTime? startDate;
  @JsonKey(name: 'end_date', fromJson: _parseDateTimeNullable)
  final DateTime? endDate;
  @JsonKey(name: 'trip_days')
  final int? tripDays;
  final int? nights;
  @JsonKey(name: 'people_count')
  final int? peopleCount;
  final List<RoadmapItineraryRegion>? regions;
  final List<String>? tags;
  final String? title;
  final Object? summary;
  final List<RoadmapDailyItinerary>? itinerary;
  @JsonKey(name: 'llm_commentary')
  final Object? llmCommentary;
  @JsonKey(name: 'next_action_suggestion')
  final List<String>? nextActionSuggestion;

  factory RoadmapItineraryData.fromJson(Map<String, dynamic> json) =>
      _$RoadmapItineraryDataFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapItineraryDataToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapItineraryRegion {
  const RoadmapItineraryRegion({
    this.regionName,
    this.startDate,
    this.endDate,
  });

  @JsonKey(name: 'region_name')
  final String? regionName;
  @JsonKey(name: 'start_date', fromJson: _parseDateTimeNullable)
  final DateTime? startDate;
  @JsonKey(name: 'end_date', fromJson: _parseDateTimeNullable)
  final DateTime? endDate;

  factory RoadmapItineraryRegion.fromJson(Map<String, dynamic> json) =>
      _$RoadmapItineraryRegionFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapItineraryRegionToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapDailyItinerary {
  const RoadmapDailyItinerary({
    this.dayNumber,
    this.dailyDate,
    this.places,
  });

  @JsonKey(name: 'day_number')
  final int? dayNumber;
  @JsonKey(name: 'daily_date', fromJson: _parseDateTimeNullable)
  final DateTime? dailyDate;
  final List<RoadmapItineraryPlace>? places;

  factory RoadmapDailyItinerary.fromJson(Map<String, dynamic> json) =>
      _$RoadmapDailyItineraryFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapDailyItineraryToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapItineraryPlace {
  const RoadmapItineraryPlace({
    this.placeName,
    this.placeId,
    this.address,
    this.latitude,
    this.longitude,
    this.placeUrl,
    this.description,
    this.visitSequence,
    this.visitTime,
  });

  @JsonKey(name: 'place_name')
  final String? placeName;
  @JsonKey(name: 'place_id')
  final String? placeId;
  final String? address;
  final double? latitude;
  final double? longitude;
  @JsonKey(name: 'place_url')
  final String? placeUrl;
  final String? description;
  @JsonKey(name: 'visit_sequence')
  final int? visitSequence;
  @JsonKey(name: 'visit_time')
  final Object? visitTime;

  factory RoadmapItineraryPlace.fromJson(Map<String, dynamic> json) =>
      _$RoadmapItineraryPlaceFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapItineraryPlaceToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapItineraryError {
  const RoadmapItineraryError({
    this.code,
    this.message,
  });

  final String? code;
  final String? message;

  factory RoadmapItineraryError.fromJson(Map<String, dynamic> json) =>
      _$RoadmapItineraryErrorFromJson(json);

  Map<String, dynamic> toJson() => _$RoadmapItineraryErrorToJson(this);
}

DateTime? _parseDateTimeNullable(Object? value) {
  if (value == null) return null;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value);
  }
  return null;
}
