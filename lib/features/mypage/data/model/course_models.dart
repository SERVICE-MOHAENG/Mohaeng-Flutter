import 'package:json_annotation/json_annotation.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/pagination_models.dart';

part 'course_models.g.dart';

@JsonSerializable(explicitToJson: true)
class CoursesResponse {
  const CoursesResponse({
    required this.courses,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  @JsonKey(fromJson: _readCoursesList, toJson: _writeCoursesList)
  final List<CourseResponse> courses;

  @JsonKey(fromJson: _readPageInt, toJson: _writeInt)
  final int page;

  @JsonKey(fromJson: _readLimitInt, toJson: _writeInt)
  final int limit;

  @JsonKey(fromJson: _readTotalInt, toJson: _writeInt)
  final int total;

  @JsonKey(fromJson: _readTotalPagesInt, toJson: _writeInt)
  final int totalPages;

  PaginationMeta get meta => PaginationMeta(
    page: page,
    limit: limit,
    total: total,
    totalPages: totalPages,
  );

  factory CoursesResponse.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final payload = nested is Map<String, dynamic> ? nested : json;
    return _$CoursesResponseFromJson(payload);
  }

  Map<String, dynamic> toJson() => _$CoursesResponseToJson(this);
}

/// Used by `/courses/me/bookmarks`, `/courses/me/likes` responses.
@JsonSerializable(explicitToJson: true)
class CourseItemsResponse {
  const CourseItemsResponse({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  @JsonKey(fromJson: _readCoursesList, toJson: _writeCoursesList)
  final List<CourseResponse> items;

  @JsonKey(fromJson: _readPageInt, toJson: _writeInt)
  final int page;

  @JsonKey(fromJson: _readLimitInt, toJson: _writeInt)
  final int limit;

  @JsonKey(fromJson: _readTotalInt, toJson: _writeInt)
  final int total;

  @JsonKey(fromJson: _readTotalPagesInt, toJson: _writeInt)
  final int totalPages;

  PaginationMeta get meta => PaginationMeta(
    page: page,
    limit: limit,
    total: total,
    totalPages: totalPages,
  );

  factory CourseItemsResponse.fromJson(Map<String, dynamic> json) {
    final nested = json['data'];
    final payload = nested is Map<String, dynamic> ? nested : json;
    return _$CourseItemsResponseFromJson(payload);
  }

  Map<String, dynamic> toJson() => _$CourseItemsResponseToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CourseResponse {
  const CourseResponse({
    this.id,
    this.title,
    this.countryCode,
    this.thumbnailUrl,
    this.days,
    this.likeCount,
    this.tags = const [],
    this.places = const [],
    this.createdAt,
    this.updatedAt,
  });

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? id;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? title;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? countryCode;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? thumbnailUrl;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? days;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? likeCount;

  @JsonKey(fromJson: _readStringList, toJson: _writeStringList)
  final List<String> tags;

  @JsonKey(fromJson: _readPlacesList, toJson: _writePlacesList)
  final List<CoursePlaceResponse> places;

  /// ISO8601 string.
  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? createdAt;

  /// ISO8601 string.
  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? updatedAt;

  factory CourseResponse.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};

    if (!normalized.containsKey('id') && normalized['courseId'] != null) {
      normalized['id'] = normalized['courseId'];
    }
    if (!normalized.containsKey('title') && normalized['name'] != null) {
      normalized['title'] = normalized['name'];
    }
    if (!normalized.containsKey('thumbnailUrl')) {
      normalized['thumbnailUrl'] =
          normalized['thumbnailUrl'] ??
          normalized['imageUrl'] ??
          normalized['thumbnail'];
    }
    if (!normalized.containsKey('days') && normalized['durationDays'] != null) {
      normalized['days'] = normalized['durationDays'];
    }
    if (!normalized.containsKey('likeCount') && normalized['likes'] != null) {
      normalized['likeCount'] = normalized['likes'];
    }
    if (!normalized.containsKey('places') &&
        normalized['coursePlaces'] is List) {
      normalized['places'] = normalized['coursePlaces'];
    }

    return _$CourseResponseFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$CourseResponseToJson(this);
}

@JsonSerializable()
class CoursePlaceResponse {
  const CoursePlaceResponse({
    this.id,
    this.placeId,
    this.name,
    this.address,
    this.latitude,
    this.longitude,
    this.order,
    this.visitedAt,
  });

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? id;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? placeId;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? name;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? address;

  @JsonKey(fromJson: _readDoubleNullable, toJson: _writeDoubleNullable)
  final double? latitude;

  @JsonKey(fromJson: _readDoubleNullable, toJson: _writeDoubleNullable)
  final double? longitude;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? order;

  /// ISO8601 string.
  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? visitedAt;

  factory CoursePlaceResponse.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    if (!normalized.containsKey('name') && normalized['title'] != null) {
      normalized['name'] = normalized['title'];
    }
    if (!normalized.containsKey('latitude') && normalized['lat'] != null) {
      normalized['latitude'] = normalized['lat'];
    }
    if (!normalized.containsKey('longitude') && normalized['lng'] != null) {
      normalized['longitude'] = normalized['lng'];
    }

    return _$CoursePlaceResponseFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$CoursePlaceResponseToJson(this);
}

List<CourseResponse> _readCoursesList(Object? value) {
  if (value is! List) return const <CourseResponse>[];
  return value
      .whereType<Map<String, dynamic>>()
      .map(CourseResponse.fromJson)
      .toList();
}

List<Map<String, dynamic>> _writeCoursesList(List<CourseResponse> value) =>
    value.map((e) => e.toJson()).toList();

List<CoursePlaceResponse> _readPlacesList(Object? value) {
  if (value is! List) return const <CoursePlaceResponse>[];
  return value
      .whereType<Map<String, dynamic>>()
      .map(CoursePlaceResponse.fromJson)
      .toList();
}

List<Map<String, dynamic>> _writePlacesList(List<CoursePlaceResponse> value) =>
    value.map((e) => e.toJson()).toList();

int _readIntWithFallback(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int _readPageInt(Object? value) => _readIntWithFallback(value, 1);

int _readLimitInt(Object? value) => _readIntWithFallback(value, 20);

int _readTotalInt(Object? value) => _readIntWithFallback(value, 0);

int _readTotalPagesInt(Object? value) => _readIntWithFallback(value, 0);

int _writeInt(int value) => value;

int? _readIntNullable(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

int? _writeIntNullable(int? value) => value;

double? _readDoubleNullable(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

double? _writeDoubleNullable(double? value) => value;

String? _readStringNullable(Object? value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}

String? _writeStringNullable(String? value) => value;

List<String> _readStringList(Object? value) {
  if (value is! List) return const <String>[];
  return value
      .map((e) => e is String ? e : e?.toString())
      .whereType<String>()
      .map((e) => e.trim())
      .where((e) => e.isNotEmpty)
      .toList();
}

List<String> _writeStringList(List<String> value) => value;
