import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';

part 'roadmap_itinerary_result_models.g.dart';

@immutable
@JsonSerializable()
class RoadmapItineraryResultResponse {
  const RoadmapItineraryResultResponse({
    required this.status,
    this.travelCourseId,
    this.data,
    this.error,
  });

  final String status;
  @JsonKey(name: 'travelCourseId')
  final String? travelCourseId;
  final RoadmapItineraryData? data;
  final RoadmapItineraryError? error;

  factory RoadmapItineraryResultResponse.fromJson(Map<String, dynamic> json) {
    final source = _normalizeResultJson(json);
    return RoadmapItineraryResultResponse(
      status: _readStringValue(source, keys: const ['status']) ?? 'PENDING',
      travelCourseId:
          _readStringValue(
            source,
            keys: const ['travelCourseId', 'travel_course_id', 'itineraryId'],
          ) ??
          _readStringValue(
            _asStringKeyedMap(source['data']) ?? const <String, dynamic>{},
            keys: const ['travelCourseId', 'travel_course_id', 'itineraryId'],
          ),
      data: _parseModel(source['data'], RoadmapItineraryData.fromJson),
      error: _parseModel(source['error'], RoadmapItineraryError.fromJson),
    );
  }

  Map<String, dynamic> toJson() => _$RoadmapItineraryResultResponseToJson(this);
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

  factory RoadmapItineraryData.fromJson(Map<String, dynamic> json) {
    return RoadmapItineraryData(
      startDate: _parseDateTimeNullable(json['start_date']),
      endDate: _parseDateTimeNullable(json['end_date']),
      tripDays: _parseIntNullable(json['trip_days']),
      nights: _parseIntNullable(json['nights']),
      peopleCount: _parseIntNullable(json['people_count']),
      regions: _parseModelList(
        json['regions'],
        RoadmapItineraryRegion.fromJson,
      ),
      tags: _parseStringList(json['tags']),
      title: _readStringValue(json, keys: const ['title']),
      summary: json['summary'],
      itinerary: _parseModelList(
        json['itinerary'],
        RoadmapDailyItinerary.fromJson,
      ),
      llmCommentary: json['llm_commentary'],
      nextActionSuggestion: _parseStringList(json['next_action_suggestion']),
    );
  }

  Map<String, dynamic> toJson() => _$RoadmapItineraryDataToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapItineraryRegion {
  const RoadmapItineraryRegion({this.regionName, this.startDate, this.endDate});

  @JsonKey(name: 'region_name')
  final String? regionName;
  @JsonKey(name: 'start_date', fromJson: _parseDateTimeNullable)
  final DateTime? startDate;
  @JsonKey(name: 'end_date', fromJson: _parseDateTimeNullable)
  final DateTime? endDate;

  factory RoadmapItineraryRegion.fromJson(Map<String, dynamic> json) {
    return RoadmapItineraryRegion(
      regionName: _readStringValue(json, keys: const ['region_name']),
      startDate: _parseDateTimeNullable(json['start_date']),
      endDate: _parseDateTimeNullable(json['end_date']),
    );
  }

  Map<String, dynamic> toJson() => _$RoadmapItineraryRegionToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapDailyItinerary {
  const RoadmapDailyItinerary({this.dayNumber, this.dailyDate, this.places});

  @JsonKey(name: 'day_number')
  final int? dayNumber;
  @JsonKey(name: 'daily_date', fromJson: _parseDateTimeNullable)
  final DateTime? dailyDate;
  final List<RoadmapItineraryPlace>? places;

  factory RoadmapDailyItinerary.fromJson(Map<String, dynamic> json) {
    return RoadmapDailyItinerary(
      dayNumber: _parseIntNullable(json['day_number']),
      dailyDate: _parseDateTimeNullable(json['daily_date']),
      places: _parseModelList(json['places'], RoadmapItineraryPlace.fromJson),
    );
  }

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

  factory RoadmapItineraryPlace.fromJson(Map<String, dynamic> json) {
    return RoadmapItineraryPlace(
      placeName: _readStringValue(json, keys: const ['place_name']),
      placeId: _readStringValue(json, keys: const ['place_id']),
      address: _readStringValue(json, keys: const ['address']),
      latitude: _parseDoubleNullable(json['latitude']),
      longitude: _parseDoubleNullable(json['longitude']),
      placeUrl: _readStringValue(json, keys: const ['place_url']),
      description: _readStringValue(json, keys: const ['description']),
      visitSequence: _parseIntNullable(json['visit_sequence']),
      visitTime: json['visit_time'],
    );
  }

  Map<String, dynamic> toJson() => _$RoadmapItineraryPlaceToJson(this);
}

@immutable
@JsonSerializable()
class RoadmapItineraryError {
  const RoadmapItineraryError({this.code, this.message});

  final String? code;
  final String? message;

  factory RoadmapItineraryError.fromJson(Map<String, dynamic> json) {
    return RoadmapItineraryError(
      code: _readStringValue(json, keys: const ['code']),
      message: _readStringValue(json, keys: const ['message']),
    );
  }

  Map<String, dynamic> toJson() => _$RoadmapItineraryErrorToJson(this);
}

Map<String, dynamic> _normalizeResultJson(Map<String, dynamic> json) {
  final result = _asStringKeyedMap(json['result']);
  if (result != null) return result;

  final data = _asStringKeyedMap(json['data']);
  if (data != null) {
    final nestedResult = _asStringKeyedMap(data['result']);
    if (nestedResult != null) return nestedResult;
    if (data.containsKey('status')) return data;
  }

  return json;
}

Map<String, dynamic>? _asStringKeyedMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

T? _parseModel<T>(Object? value, T Function(Map<String, dynamic> json) parser) {
  final map = _asStringKeyedMap(value);
  if (map == null) return null;
  return parser(map);
}

List<T>? _parseModelList<T>(
  Object? value,
  T Function(Map<String, dynamic> json) parser,
) {
  if (value is! List) return null;

  final result = <T>[];
  for (final item in value) {
    final parsed = _parseModel(item, parser);
    if (parsed != null) {
      result.add(parsed);
    }
  }
  return result;
}

List<String>? _parseStringList(Object? value) {
  if (value is! List) return null;

  final result = <String>[];
  for (final item in value) {
    if (item == null) continue;
    final text = item.toString().trim();
    if (text.isEmpty) continue;
    result.add(text);
  }
  return result;
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

DateTime? _parseDateTimeNullable(Object? value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String && value.trim().isNotEmpty) {
    return DateTime.tryParse(value.trim());
  }
  return null;
}

int? _parseIntNullable(Object? value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String && value.trim().isNotEmpty) {
    return int.tryParse(value.trim());
  }
  return null;
}

double? _parseDoubleNullable(Object? value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String && value.trim().isNotEmpty) {
    return double.tryParse(value.trim());
  }
  return null;
}
