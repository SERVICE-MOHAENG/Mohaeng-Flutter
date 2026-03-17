// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CoursesResponse _$CoursesResponseFromJson(Map<String, dynamic> json) =>
    CoursesResponse(
      courses: _readCoursesList(json['courses']),
      page: _readPageInt(json['page']),
      limit: _readLimitInt(json['limit']),
      total: _readTotalInt(json['total']),
      totalPages: _readTotalPagesInt(json['totalPages']),
    );

Map<String, dynamic> _$CoursesResponseToJson(CoursesResponse instance) =>
    <String, dynamic>{
      'courses': _writeCoursesList(instance.courses),
      'page': _writeInt(instance.page),
      'limit': _writeInt(instance.limit),
      'total': _writeInt(instance.total),
      'totalPages': _writeInt(instance.totalPages),
    };

CourseResponse _$CourseResponseFromJson(Map<String, dynamic> json) =>
    CourseResponse(
      id: _readIntNullable(json['id']),
      title: _readStringNullable(json['title']),
      countryCode: _readStringNullable(json['countryCode']),
      thumbnailUrl: _readStringNullable(json['thumbnailUrl']),
      days: _readIntNullable(json['days']),
      likeCount: _readIntNullable(json['likeCount']),
      isLiked: _readBoolNullable(json['isLiked']),
      tags: json['tags'] == null ? const [] : _readStringList(json['tags']),
      places: json['places'] == null
          ? const []
          : _readPlacesList(json['places']),
      createdAt: _readStringNullable(json['createdAt']),
      updatedAt: _readStringNullable(json['updatedAt']),
    );

Map<String, dynamic> _$CourseResponseToJson(CourseResponse instance) =>
    <String, dynamic>{
      'id': _writeIntNullable(instance.id),
      'title': _writeStringNullable(instance.title),
      'countryCode': _writeStringNullable(instance.countryCode),
      'thumbnailUrl': _writeStringNullable(instance.thumbnailUrl),
      'days': _writeIntNullable(instance.days),
      'likeCount': _writeIntNullable(instance.likeCount),
      'isLiked': _writeBoolNullable(instance.isLiked),
      'tags': _writeStringList(instance.tags),
      'places': _writePlacesList(instance.places),
      'createdAt': _writeStringNullable(instance.createdAt),
      'updatedAt': _writeStringNullable(instance.updatedAt),
    };

CoursePlaceResponse _$CoursePlaceResponseFromJson(Map<String, dynamic> json) =>
    CoursePlaceResponse(
      id: _readIntNullable(json['id']),
      placeId: _readIntNullable(json['placeId']),
      name: _readStringNullable(json['name']),
      address: _readStringNullable(json['address']),
      latitude: _readDoubleNullable(json['latitude']),
      longitude: _readDoubleNullable(json['longitude']),
      order: _readIntNullable(json['order']),
      visitedAt: _readStringNullable(json['visitedAt']),
    );

Map<String, dynamic> _$CoursePlaceResponseToJson(
  CoursePlaceResponse instance,
) => <String, dynamic>{
  'id': _writeIntNullable(instance.id),
  'placeId': _writeIntNullable(instance.placeId),
  'name': _writeStringNullable(instance.name),
  'address': _writeStringNullable(instance.address),
  'latitude': _writeDoubleNullable(instance.latitude),
  'longitude': _writeDoubleNullable(instance.longitude),
  'order': _writeIntNullable(instance.order),
  'visitedAt': _writeStringNullable(instance.visitedAt),
};
