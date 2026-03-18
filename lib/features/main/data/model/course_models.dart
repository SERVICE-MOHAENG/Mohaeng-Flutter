import 'package:json_annotation/json_annotation.dart';
import 'package:mohaeng_app_service/features/main/data/model/pagination_models.dart';

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

@JsonSerializable(explicitToJson: true)
class CourseResponse {
  const CourseResponse({
    this.id,
    this.title,
    this.description,
    this.countryCode,
    this.countries = const [],
    this.regionNames = const [],
    this.thumbnailUrl,
    this.viewCount,
    this.nights,
    this.days,
    this.likeCount,
    this.modificationCount,
    this.userId,
    this.userName,
    this.isLiked,
    this.tags = const [],
    this.places = const [],
    this.isPublic,
    this.isCompleted,
    this.createdAt,
    this.updatedAt,
    this.sourceCourseId,
  });

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? id;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? title;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? description;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? countryCode;

  @JsonKey(fromJson: _readStringList, toJson: _writeStringList)
  final List<String> countries;

  @JsonKey(fromJson: _readStringList, toJson: _writeStringList)
  final List<String> regionNames;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? thumbnailUrl;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? viewCount;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? nights;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? days;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? likeCount;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? modificationCount;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? userId;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? userName;

  @JsonKey(fromJson: _readBoolNullable, toJson: _writeBoolNullable)
  final bool? isLiked;

  @JsonKey(fromJson: _readStringList, toJson: _writeStringList)
  final List<String> tags;

  @JsonKey(fromJson: _readPlacesList, toJson: _writePlacesList)
  final List<CoursePlaceResponse> places;

  @JsonKey(fromJson: _readBoolNullable, toJson: _writeBoolNullable)
  final bool? isPublic;

  @JsonKey(fromJson: _readBoolNullable, toJson: _writeBoolNullable)
  final bool? isCompleted;

  /// ISO8601 string.
  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? createdAt;

  /// ISO8601 string.
  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? updatedAt;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? sourceCourseId;

  factory CourseResponse.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};

    if (!normalized.containsKey('id') && normalized['courseId'] != null) {
      normalized['id'] = normalized['courseId'];
    }
    if (!normalized.containsKey('title') && normalized['name'] != null) {
      normalized['title'] = normalized['name'];
    }
    if (!normalized.containsKey('description')) {
      normalized['description'] =
          normalized['description'] ??
          normalized['summary'] ??
          normalized['content'];
    }
    if (!normalized.containsKey('countryCode')) {
      final countries = normalized['countries'];
      if (countries is List && countries.isNotEmpty) {
        normalized['countryCode'] = countries.first;
      }
    }
    if (!normalized.containsKey('thumbnailUrl') &&
        normalized['imageUrl'] != null) {
      normalized['thumbnailUrl'] = normalized['imageUrl'];
    }
    if (!normalized.containsKey('thumbnailUrl') &&
        normalized['thumbnail'] != null) {
      normalized['thumbnailUrl'] = normalized['thumbnail'];
    }
    if (!normalized.containsKey('tags') && normalized['hashTags'] is List) {
      normalized['tags'] = normalized['hashTags'];
    }
    if (!normalized.containsKey('days') && normalized['durationDays'] != null) {
      normalized['days'] = normalized['durationDays'];
    }
    if (!normalized.containsKey('likeCount') && normalized['likes'] != null) {
      normalized['likeCount'] = normalized['likes'];
    }
    if (!normalized.containsKey('isLiked')) {
      normalized['isLiked'] =
          normalized['isLiked'] ??
          normalized['liked'] ??
          normalized['isBookmarked'] ??
          normalized['bookmarked'];
    }
    if (!normalized.containsKey('places') &&
        normalized['coursePlaces'] is List) {
      normalized['places'] = normalized['coursePlaces'];
    }
    if (!normalized.containsKey('sourceCourseId') &&
        normalized['originalCourseId'] != null) {
      normalized['sourceCourseId'] = normalized['originalCourseId'];
    }

    return _$CourseResponseFromJson(normalized);
  }

  Map<String, dynamic> toJson() => _$CourseResponseToJson(this);

  CourseResponse copyWith({
    String? id,
    String? title,
    String? description,
    String? countryCode,
    List<String>? countries,
    List<String>? regionNames,
    String? thumbnailUrl,
    int? viewCount,
    int? nights,
    int? days,
    int? likeCount,
    int? modificationCount,
    String? userId,
    String? userName,
    bool? isLiked,
    List<String>? tags,
    List<CoursePlaceResponse>? places,
    bool? isPublic,
    bool? isCompleted,
    String? createdAt,
    String? updatedAt,
    String? sourceCourseId,
  }) {
    return CourseResponse(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      countryCode: countryCode ?? this.countryCode,
      countries: countries ?? this.countries,
      regionNames: regionNames ?? this.regionNames,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      viewCount: viewCount ?? this.viewCount,
      nights: nights ?? this.nights,
      days: days ?? this.days,
      likeCount: likeCount ?? this.likeCount,
      modificationCount: modificationCount ?? this.modificationCount,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      isLiked: isLiked ?? this.isLiked,
      tags: tags ?? this.tags,
      places: places ?? this.places,
      isPublic: isPublic ?? this.isPublic,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceCourseId: sourceCourseId ?? this.sourceCourseId,
    );
  }
}

@JsonSerializable()
class CoursePlaceResponse {
  const CoursePlaceResponse({
    this.id,
    this.placeId,
    this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.order,
    this.dayNumber,
    this.memo,
    this.placeUrl,
    this.visitedAt,
  });

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? id;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? placeId;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? name;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? description;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? address;

  @JsonKey(fromJson: _readDoubleNullable, toJson: _writeDoubleNullable)
  final double? latitude;

  @JsonKey(fromJson: _readDoubleNullable, toJson: _writeDoubleNullable)
  final double? longitude;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? order;

  @JsonKey(fromJson: _readIntNullable, toJson: _writeIntNullable)
  final int? dayNumber;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? memo;

  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? placeUrl;

  /// ISO8601 string.
  @JsonKey(fromJson: _readStringNullable, toJson: _writeStringNullable)
  final String? visitedAt;

  factory CoursePlaceResponse.fromJson(Map<String, dynamic> json) {
    final normalized = <String, dynamic>{...json};
    if (!normalized.containsKey('name') && normalized['title'] != null) {
      normalized['name'] = normalized['title'];
    }
    if (!normalized.containsKey('name') && normalized['placeName'] != null) {
      normalized['name'] = normalized['placeName'];
    }
    if (!normalized.containsKey('description') &&
        normalized['placeDescription'] != null) {
      normalized['description'] = normalized['placeDescription'];
    }
    if (!normalized.containsKey('latitude') && normalized['lat'] != null) {
      normalized['latitude'] = normalized['lat'];
    }
    if (!normalized.containsKey('longitude') && normalized['lng'] != null) {
      normalized['longitude'] = normalized['lng'];
    }
    if (!normalized.containsKey('order') && normalized['visitOrder'] != null) {
      normalized['order'] = normalized['visitOrder'];
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

int _readIntWithFallback(Object? value, int fallback) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

int _readPageInt(Object? value) => _readIntWithFallback(value, 1);

int _readLimitInt(Object? value) => _readIntWithFallback(value, 10);

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

bool? _readBoolNullable(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true' || normalized == '1') return true;
    if (normalized == 'false' || normalized == '0') return false;
  }
  return null;
}

bool? _writeBoolNullable(bool? value) => value;

double? _readDoubleNullable(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

double? _writeDoubleNullable(double? value) => value;

String? _readStringNullable(Object? value) {
  if (value == null) return null;
  if (value is Map || value is List) return null;
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

List<CoursePlaceResponse> _readPlacesList(Object? value) {
  if (value is! List) return const <CoursePlaceResponse>[];
  return value
      .whereType<Map<String, dynamic>>()
      .map(CoursePlaceResponse.fromJson)
      .toList();
}

List<Map<String, dynamic>> _writePlacesList(List<CoursePlaceResponse> value) =>
    value.map((e) => e.toJson()).toList();
