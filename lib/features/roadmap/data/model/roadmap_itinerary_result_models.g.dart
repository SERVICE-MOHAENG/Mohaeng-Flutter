// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'roadmap_itinerary_result_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoadmapItineraryResultResponse _$RoadmapItineraryResultResponseFromJson(
  Map<String, dynamic> json,
) => RoadmapItineraryResultResponse(
  status: json['status'] as String,
  data: json['data'] == null
      ? null
      : RoadmapItineraryData.fromJson(json['data'] as Map<String, dynamic>),
  error: json['error'] == null
      ? null
      : RoadmapItineraryError.fromJson(json['error'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RoadmapItineraryResultResponseToJson(
  RoadmapItineraryResultResponse instance,
) => <String, dynamic>{
  'status': instance.status,
  'data': instance.data,
  'error': instance.error,
};

RoadmapItineraryData _$RoadmapItineraryDataFromJson(
  Map<String, dynamic> json,
) => RoadmapItineraryData(
  startDate: _parseDateTimeNullable(json['start_date']),
  endDate: _parseDateTimeNullable(json['end_date']),
  tripDays: (json['trip_days'] as num?)?.toInt(),
  nights: (json['nights'] as num?)?.toInt(),
  peopleCount: (json['people_count'] as num?)?.toInt(),
  regions: (json['regions'] as List<dynamic>?)
      ?.map((e) => RoadmapItineraryRegion.fromJson(e as Map<String, dynamic>))
      .toList(),
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
  title: json['title'] as String?,
  summary: json['summary'],
  itinerary: (json['itinerary'] as List<dynamic>?)
      ?.map((e) => RoadmapDailyItinerary.fromJson(e as Map<String, dynamic>))
      .toList(),
  llmCommentary: json['llm_commentary'],
  nextActionSuggestion: (json['next_action_suggestion'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$RoadmapItineraryDataToJson(
  RoadmapItineraryData instance,
) => <String, dynamic>{
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
  'trip_days': instance.tripDays,
  'nights': instance.nights,
  'people_count': instance.peopleCount,
  'regions': instance.regions,
  'tags': instance.tags,
  'title': instance.title,
  'summary': instance.summary,
  'itinerary': instance.itinerary,
  'llm_commentary': instance.llmCommentary,
  'next_action_suggestion': instance.nextActionSuggestion,
};

RoadmapItineraryRegion _$RoadmapItineraryRegionFromJson(
  Map<String, dynamic> json,
) => RoadmapItineraryRegion(
  regionName: json['region_name'] as String?,
  startDate: _parseDateTimeNullable(json['start_date']),
  endDate: _parseDateTimeNullable(json['end_date']),
);

Map<String, dynamic> _$RoadmapItineraryRegionToJson(
  RoadmapItineraryRegion instance,
) => <String, dynamic>{
  'region_name': instance.regionName,
  'start_date': instance.startDate?.toIso8601String(),
  'end_date': instance.endDate?.toIso8601String(),
};

RoadmapDailyItinerary _$RoadmapDailyItineraryFromJson(
  Map<String, dynamic> json,
) => RoadmapDailyItinerary(
  dayNumber: (json['day_number'] as num?)?.toInt(),
  dailyDate: _parseDateTimeNullable(json['daily_date']),
  places: (json['places'] as List<dynamic>?)
      ?.map((e) => RoadmapItineraryPlace.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$RoadmapDailyItineraryToJson(
  RoadmapDailyItinerary instance,
) => <String, dynamic>{
  'day_number': instance.dayNumber,
  'daily_date': instance.dailyDate?.toIso8601String(),
  'places': instance.places,
};

RoadmapItineraryPlace _$RoadmapItineraryPlaceFromJson(
  Map<String, dynamic> json,
) => RoadmapItineraryPlace(
  placeName: json['place_name'] as String?,
  placeId: json['place_id'] as String?,
  address: json['address'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  placeUrl: json['place_url'] as String?,
  description: json['description'] as String?,
  visitSequence: (json['visit_sequence'] as num?)?.toInt(),
  visitTime: json['visit_time'],
);

Map<String, dynamic> _$RoadmapItineraryPlaceToJson(
  RoadmapItineraryPlace instance,
) => <String, dynamic>{
  'place_name': instance.placeName,
  'place_id': instance.placeId,
  'address': instance.address,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'place_url': instance.placeUrl,
  'description': instance.description,
  'visit_sequence': instance.visitSequence,
  'visit_time': instance.visitTime,
};

RoadmapItineraryError _$RoadmapItineraryErrorFromJson(
  Map<String, dynamic> json,
) => RoadmapItineraryError(
  code: json['code'] as String?,
  message: json['message'] as String?,
);

Map<String, dynamic> _$RoadmapItineraryErrorToJson(
  RoadmapItineraryError instance,
) => <String, dynamic>{'code': instance.code, 'message': instance.message};
