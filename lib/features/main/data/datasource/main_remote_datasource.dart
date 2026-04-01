import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mohaeng_app_service/core/model/user_summary_models.dart';
import 'package:mohaeng_app_service/core/network/api_client.dart';
import 'package:mohaeng_app_service/core/network/auth_interceptor.dart';
import 'package:mohaeng_app_service/core/network/endpoints.dart';
import 'package:mohaeng_app_service/core/network/query_params.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/main/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';

class MainRemoteDataSource {
  MainRemoteDataSource({
    ApiClient? apiClient,
    AccessTokenProvider? accessTokenProvider,
    AuthTokenStorage? tokenStorage,
  }) : _apiClient =
           apiClient ??
           ApiClient(
             baseUrl: _readBaseUrl(),
             loggerLabel: 'MAIN-API',
             interceptors: [
               AuthInterceptor(
                 accessTokenProvider:
                     accessTokenProvider ??
                     () =>
                         (tokenStorage ?? AuthTokenStorage()).readAccessToken(),
               ),
             ],
           );

  final ApiClient _apiClient;

  static const String _mainCoursesPath = '${ApiEndpoints.courses}/mainpage';
  static const String _courseDetailPath = ApiEndpoints.courses;
  static const String _mainBlogsPath = '${ApiEndpoints.blogs}/mainpage';
  static const String _mainUserMePath = '${ApiEndpoints.basePath}/users/me';

  Future<CoursesResponse> getMainCourses({
    String sortBy = 'popular',
    String? countryCode,
    int page = 1,
    int limit = 10,
    CancelToken? cancelToken,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safeLimit = _sanitizeCoursesLimit(limit);

    final queryParameters = removeNullQueryParams({
      'sortBy': sortBy,
      'countryCode': countryCode,
      'page': safePage,
      'limit': safeLimit,
    });

    final response = await _apiClient.get<dynamic>(
      _mainCoursesPath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return CoursesResponse.fromJson(payload);
  }

  Future<BlogsResponse> getMainBlogs({
    String sortBy = 'latest',
    int page = 1,
    int limit = 6,
    CancelToken? cancelToken,
  }) async {
    final safePage = page < 1 ? 1 : page;
    final safeLimit = _sanitizeBlogsLimit(limit);

    final queryParameters = removeNullQueryParams({
      'sortBy': sortBy,
      'page': safePage,
      'limit': safeLimit,
    });

    final response = await _apiClient.get<dynamic>(
      _mainBlogsPath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return BlogsResponse.fromJson(payload);
  }

  Future<CourseResponse> getMainCourseDetail({
    required String id,
    CancelToken? cancelToken,
  }) async {
    final courseId = id.trim();
    if (courseId.isEmpty) {
      throw const FormatException('course id is empty.');
    }

    final response = await _apiClient.get<dynamic>(
      '$_courseDetailPath/$courseId',
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    final normalized = _normalizeCourseDetailPayload(payload);
    return CourseResponse.fromJson(normalized);
  }

  Future<CourseResponse> completeMainCourse({
    required String id,
    required bool isCompleted,
    CancelToken? cancelToken,
  }) async {
    final courseId = id.trim();
    if (courseId.isEmpty) {
      throw const FormatException('course id is empty.');
    }

    final response = await _apiClient.patch<dynamic>(
      '$_courseDetailPath/$courseId/completion',
      data: {'isCompleted': isCompleted},
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    final normalized = _normalizeCourseDetailPayload(payload);
    return CourseResponse.fromJson(normalized);
  }

  Future<UserSummaryResponse> getMainUserMe({CancelToken? cancelToken}) async {
    final response = await _apiClient.get<dynamic>(
      _mainUserMePath,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return UserSummaryResponse.fromJson(payload);
  }
}

int _sanitizeCoursesLimit(int limit) {
  if (limit < 1) return 1;
  if (limit > 10) return 10;
  return limit;
}

int _sanitizeBlogsLimit(int limit) {
  if (limit < 1) return 1;
  if (limit > 100) return 100;
  return limit;
}

String _readBaseUrl() {
  final baseUrl = dotenv.env['BASE_URL']?.trim() ?? '';
  if (baseUrl.isEmpty) {
    throw const FormatException('BASE_URL is not set.');
  }
  return baseUrl;
}

Map<String, dynamic> _unwrapPayload(Object? data) {
  if (data is! Map<String, dynamic>) {
    throw const FormatException('응답 형식이 올바르지 않습니다.');
  }

  var current = data;
  while (true) {
    final nested = current['data'];
    if (nested is Map<String, dynamic>) {
      current = nested;
      continue;
    }
    return current;
  }
}

Map<String, dynamic> _normalizeCourseDetailPayload(Map<String, dynamic> payload) {
  final normalized = <String, dynamic>{...payload};

  _assignFirstNonEmpty(normalized, 'id', [
    normalized['courseId'],
    normalized['roadmapId'],
    normalized['roadmap_id'],
    normalized['course_id'],
    normalized['roadmapid'],
  ]);
  _assignFirstNonEmpty(normalized, 'title', [
    normalized['name'],
    normalized['course_name'],
  ]);
  _assignFirstNonEmpty(normalized, 'description', [
    normalized['summary'],
    normalized['content'],
    normalized['description'],
  ]);
  _assignFirstNonEmpty(normalized, 'startDate', [
    normalized['start_date'],
    normalized['start_date_time'],
    normalized['start'],
  ]);
  _assignFirstNonEmpty(normalized, 'endDate', [
    normalized['end_date'],
    normalized['end_date_time'],
    normalized['end'],
  ]);
  _assignFirstNonEmpty(normalized, 'days', [
    normalized['trip_days'],
    normalized['tripDays'],
    normalized['days'],
  ]);
  _assignFirstNonEmpty(normalized, 'isCompleted', [
    normalized['is_completed'],
    normalized['isCompleted'],
  ]);
  _assignFirstNonEmpty(normalized, 'thumbnailUrl', [
    normalized['thumbnail_url'],
    normalized['thumbnail'],
    normalized['imageUrl'],
  ]);
  _assignFirstNonEmpty(normalized, 'sourceCourseId', [
    normalized['originalCourseId'],
    normalized['source_course_id'],
  ]);
  if (normalized['itinerary'] is List) {
    normalized['places'] = _flattenItineraryPlaces(
      normalized['itinerary'] as List,
    );
    if ((normalized['days'] is! int || (normalized['days'] as int) == 0) &&
        (normalized['itinerary'] as List).isNotEmpty) {
      normalized['days'] = (normalized['itinerary'] as List).length;
    }
  }

  return normalized;
}

List<Map<String, dynamic>> _flattenItineraryPlaces(List itinerary) {
  final result = <Map<String, dynamic>>[];

  for (final day in itinerary) {
    if (day is! Map<String, dynamic>) continue;
    final dayNumber = _firstNonEmptyValue([
      day['day_number'],
      day['dayNumber'],
      day['day'],
    ]);
    final dailyDate = _firstNonEmptyValue([
      day['daily_date'],
      day['dailyDate'],
      day['date'],
    ]);
    final places = day['places'];
    if (places is! List) continue;

    for (var index = 0; index < places.length; index++) {
      final place = places[index];
      if (place is! Map<String, dynamic>) continue;
      result.add({
        'placeId': _firstNonEmptyValue([
          place['place_id'],
          place['placeId'],
          place['id'],
        ]),
        'name': _firstNonEmptyValue([
          place['place_name'],
          place['placeName'],
          place['name'],
          place['title'],
        ]),
        'address': _firstNonEmptyValue([
          place['address'],
          place['place_address'],
        ]),
        'latitude': _firstNonEmptyValue([
          place['latitude'],
          place['lat'],
        ]),
        'longitude': _firstNonEmptyValue([
          place['longitude'],
          place['lng'],
          place['lon'],
        ]),
        'placeUrl': _firstNonEmptyValue([
          place['place_url'],
          place['placeUrl'],
          place['url'],
        ]),
        'description': _firstNonEmptyValue([
          place['description'],
          place['place_description'],
        ]),
        'order': _firstNonEmptyValue([
          place['visit_sequence'],
          place['visitSequence'],
          index + 1,
        ]),
        'memo': _firstNonEmptyValue([
          place['memo'],
          place['note'],
        ]),
        'dayNumber': dayNumber,
        'visitedAt': _firstNonEmptyValue([
          place['visit_time'],
          place['visitTime'],
          dailyDate,
        ]),
      });
    }
  }

  return result;
}

void _assignFirstNonEmpty(
  Map<String, dynamic> normalized,
  String key,
  List<Object?> candidates,
) {
  final current = normalized[key];
  if (_hasValue(current)) return;

  final next = _firstNonEmptyValue(candidates);
  if (next != null) {
    normalized[key] = next;
  }
}

Object? _firstNonEmptyValue(List<Object?> values) {
  for (final value in values) {
    if (_hasValue(value)) return value;
  }
  return null;
}

bool _hasValue(Object? value) {
  if (value == null) return false;
  if (value is String) return value.trim().isNotEmpty;
  if (value is Iterable) return value.isNotEmpty;
  return true;
}
