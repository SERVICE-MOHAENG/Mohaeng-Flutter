import 'package:mohaeng_app_service/features/main/data/model/pagination_models.dart';

class CoursesResponse {
  const CoursesResponse({required this.courses, required this.meta});

  final List<CourseResponse> courses;
  final PaginationMeta meta;

  factory CoursesResponse.fromJson(Map<String, dynamic> json) {
    final coursesRaw = json['courses'];
    final coursesList = coursesRaw is List
        ? coursesRaw
              .whereType<Map<String, dynamic>>()
              .map(CourseResponse.fromJson)
              .toList()
        : const <CourseResponse>[];

    return CoursesResponse(
      courses: coursesList,
      meta: PaginationMeta.fromJson(json),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courses': courses.map((e) => e.toJson()).toList(),
      ...meta.toJson(),
    };
  }
}

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

  final int? id;
  final String? title;
  final String? countryCode;
  final String? thumbnailUrl;
  final int? days;
  final int? likeCount;
  final List<String> tags;
  final List<CoursePlaceResponse> places;

  /// ISO8601 string.
  final String? createdAt;

  /// ISO8601 string.
  final String? updatedAt;

  factory CourseResponse.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    final placesRaw = json['places'] ?? json['coursePlaces'];

    return CourseResponse(
      id: _readIntNullable(json['id'] ?? json['courseId']),
      title: _readStringNullable(json['title'] ?? json['name']),
      countryCode: _readStringNullable(json['countryCode']),
      thumbnailUrl: _readStringNullable(
        json['thumbnailUrl'] ?? json['imageUrl'],
      ),
      days: _readIntNullable(json['days'] ?? json['durationDays']),
      likeCount: _readIntNullable(json['likeCount'] ?? json['likes']),
      tags: tagsRaw is List
          ? tagsRaw
                .map((e) => e is String ? e : e?.toString())
                .whereType<String>()
                .toList()
          : const <String>[],
      places: placesRaw is List
          ? placesRaw
                .whereType<Map<String, dynamic>>()
                .map(CoursePlaceResponse.fromJson)
                .toList()
          : const <CoursePlaceResponse>[],
      createdAt: _readStringNullable(json['createdAt']),
      updatedAt: _readStringNullable(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'countryCode': countryCode,
      'thumbnailUrl': thumbnailUrl,
      'days': days,
      'likeCount': likeCount,
      'tags': tags,
      'places': places.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

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

  final int? id;
  final int? placeId;
  final String? name;
  final String? address;
  final double? latitude;
  final double? longitude;
  final int? order;

  /// ISO8601 string.
  final String? visitedAt;

  factory CoursePlaceResponse.fromJson(Map<String, dynamic> json) {
    return CoursePlaceResponse(
      id: _readIntNullable(json['id']),
      placeId: _readIntNullable(json['placeId']),
      name: _readStringNullable(json['name'] ?? json['title']),
      address: _readStringNullable(json['address']),
      latitude: _readDoubleNullable(json['latitude'] ?? json['lat']),
      longitude: _readDoubleNullable(json['longitude'] ?? json['lng']),
      order: _readIntNullable(json['order']),
      visitedAt: _readStringNullable(json['visitedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placeId': placeId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'order': order,
      'visitedAt': visitedAt,
    };
  }
}

int? _readIntNullable(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? _readDoubleNullable(Object? value) {
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

String? _readStringNullable(Object? value) {
  if (value == null) return null;
  final s = value.toString().trim();
  return s.isEmpty ? null : s;
}
