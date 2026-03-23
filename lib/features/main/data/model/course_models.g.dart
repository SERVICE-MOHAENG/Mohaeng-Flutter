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
      id: _readStringNullable(json['id']),
      title: _readStringNullable(json['title']),
      description: _readStringNullable(json['description']),
      startDate: _readStringNullable(json['startDate']),
      endDate: _readStringNullable(json['endDate']),
      countryCode: _readStringNullable(json['countryCode']),
      countries: json['countries'] == null
          ? const []
          : _readStringList(json['countries']),
      regionNames: json['regionNames'] == null
          ? const []
          : _readStringList(json['regionNames']),
      thumbnailUrl: _readStringNullable(json['thumbnailUrl']),
      viewCount: _readIntNullable(json['viewCount']),
      nights: _readIntNullable(json['nights']),
      days: _readIntNullable(json['days']),
      likeCount: _readIntNullable(json['likeCount']),
      modificationCount: _readIntNullable(json['modificationCount']),
      userId: _readStringNullable(json['userId']),
      userName: _readStringNullable(json['userName']),
      isLiked: _readBoolNullable(json['isLiked']),
      tags: json['tags'] == null ? const [] : _readStringList(json['tags']),
      places: json['places'] == null
          ? const []
          : _readPlacesList(json['places']),
      isPublic: _readBoolNullable(json['isPublic']),
      isCompleted: _readBoolNullable(json['isCompleted']),
      createdAt: _readStringNullable(json['createdAt']),
      updatedAt: _readStringNullable(json['updatedAt']),
      sourceCourseId: _readStringNullable(json['sourceCourseId']),
    );

Map<String, dynamic> _$CourseResponseToJson(CourseResponse instance) =>
    <String, dynamic>{
      'id': _writeStringNullable(instance.id),
      'title': _writeStringNullable(instance.title),
      'description': _writeStringNullable(instance.description),
      'startDate': _writeStringNullable(instance.startDate),
      'endDate': _writeStringNullable(instance.endDate),
      'countryCode': _writeStringNullable(instance.countryCode),
      'countries': _writeStringList(instance.countries),
      'regionNames': _writeStringList(instance.regionNames),
      'thumbnailUrl': _writeStringNullable(instance.thumbnailUrl),
      'viewCount': _writeIntNullable(instance.viewCount),
      'nights': _writeIntNullable(instance.nights),
      'days': _writeIntNullable(instance.days),
      'likeCount': _writeIntNullable(instance.likeCount),
      'modificationCount': _writeIntNullable(instance.modificationCount),
      'userId': _writeStringNullable(instance.userId),
      'userName': _writeStringNullable(instance.userName),
      'isLiked': _writeBoolNullable(instance.isLiked),
      'tags': _writeStringList(instance.tags),
      'places': _writePlacesList(instance.places),
      'isPublic': _writeBoolNullable(instance.isPublic),
      'isCompleted': _writeBoolNullable(instance.isCompleted),
      'createdAt': _writeStringNullable(instance.createdAt),
      'updatedAt': _writeStringNullable(instance.updatedAt),
      'sourceCourseId': _writeStringNullable(instance.sourceCourseId),
    };

CoursePlaceResponse _$CoursePlaceResponseFromJson(Map<String, dynamic> json) =>
    CoursePlaceResponse(
      id: _readStringNullable(json['id']),
      placeId: _readStringNullable(json['placeId']),
      name: _readStringNullable(json['name']),
      description: _readStringNullable(json['description']),
      address: _readStringNullable(json['address']),
      latitude: _readDoubleNullable(json['latitude']),
      longitude: _readDoubleNullable(json['longitude']),
      order: _readIntNullable(json['order']),
      dayNumber: _readIntNullable(json['dayNumber']),
      memo: _readStringNullable(json['memo']),
      placeUrl: _readStringNullable(json['placeUrl']),
      visitedAt: _readStringNullable(json['visitedAt']),
    );

Map<String, dynamic> _$CoursePlaceResponseToJson(
  CoursePlaceResponse instance,
) => <String, dynamic>{
  'id': _writeStringNullable(instance.id),
  'placeId': _writeStringNullable(instance.placeId),
  'name': _writeStringNullable(instance.name),
  'description': _writeStringNullable(instance.description),
  'address': _writeStringNullable(instance.address),
  'latitude': _writeDoubleNullable(instance.latitude),
  'longitude': _writeDoubleNullable(instance.longitude),
  'order': _writeIntNullable(instance.order),
  'dayNumber': _writeIntNullable(instance.dayNumber),
  'memo': _writeStringNullable(instance.memo),
  'placeUrl': _writeStringNullable(instance.placeUrl),
  'visitedAt': _writeStringNullable(instance.visitedAt),
};
