import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mohaeng_app_service/core/network/api_client.dart';
import 'package:mohaeng_app_service/core/network/auth_interceptor.dart';
import 'package:mohaeng_app_service/core/network/endpoints.dart';
import 'package:mohaeng_app_service/core/network/query_params.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/visited_country_models.dart';

class MyPageRemoteDataSource {
  MyPageRemoteDataSource({
    ApiClient? apiClient,
    AccessTokenProvider? accessTokenProvider,
    AuthTokenStorage? tokenStorage,
  }) : _apiClient =
           apiClient ??
           ApiClient(
             baseUrl: _readBaseUrl(),
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

  static const String _myCoursesPath = '${ApiEndpoints.courses}/me';
  static const String _myCourseBookmarksPath =
      '${ApiEndpoints.courses}/me/bookmarks';
  static const String _myCourseLikesPath = '${ApiEndpoints.courses}/me/likes';
  static const String _myBlogsPath = '${ApiEndpoints.blogs}/me';
  static const String _myBlogLikesPath = '${ApiEndpoints.blogs}/me/likes';
  static const String _myVisitedCountriesPath =
      '${ApiEndpoints.visitedCountries}/me';
  static const String _visitedCountriesPath = ApiEndpoints.visitedCountries;
  static const String _myAccountPath = '${ApiEndpoints.basePath}/users/me';

  Future<CoursesResponse> getMyCourses({
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = removeNullQueryParams({
      'page': _sanitizePage(page),
      'limit': _sanitizeLimit(limit),
    });

    final response = await _apiClient.get<dynamic>(
      _myCoursesPath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return CoursesResponse.fromJson(payload);
  }

  Future<CourseItemsResponse> getMyCourseBookmarks({
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = removeNullQueryParams({
      'page': _sanitizePage(page),
      'limit': _sanitizeLimit(limit),
    });

    final response = await _apiClient.get<dynamic>(
      _myCourseBookmarksPath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return CourseItemsResponse.fromJson(payload);
  }

  Future<CourseItemsResponse> getMyCourseLikes({
    int page = 1,
    int limit = 20,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = removeNullQueryParams({
      'page': _sanitizePage(page),
      'limit': _sanitizeLimit(limit),
    });

    final response = await _apiClient.get<dynamic>(
      _myCourseLikesPath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return CourseItemsResponse.fromJson(payload);
  }

  Future<BlogsResponse> getMyBlogs({
    int page = 1,
    int limit = 6,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = removeNullQueryParams({
      'page': _sanitizePage(page),
      'limit': _sanitizeLimit(limit),
    });

    final response = await _apiClient.get<dynamic>(
      _myBlogsPath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return BlogsResponse.fromJson(payload);
  }

  Future<BlogItemsResponse> getMyBlogLikes({
    int page = 1,
    int limit = 6,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = removeNullQueryParams({
      'page': _sanitizePage(page),
      'limit': _sanitizeLimit(limit),
    });

    final response = await _apiClient.get<dynamic>(
      _myBlogLikesPath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return BlogItemsResponse.fromJson(payload);
  }

  Future<VisitedCountryItemsResponse> getVisitedCountries({
    int page = 1,
    int limit = 10,
    CancelToken? cancelToken,
  }) async {
    final queryParameters = removeNullQueryParams({
      'page': _sanitizePage(page),
      'limit': _sanitizeLimit(limit),
    });

    final response = await _apiClient.get<dynamic>(
      _myVisitedCountriesPath,
      queryParameters: queryParameters,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return VisitedCountryItemsResponse.fromJson(payload);
  }

  Future<VisitedCountryResponse> addVisitedCountry({
    required String countryId,
    required String visitDate,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.post<dynamic>(
      _visitedCountriesPath,
      data: {'countryId': countryId, 'visitDate': visitDate},
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return VisitedCountryResponse.fromJson(payload);
  }

  Future<void> deleteVisitedCountry({
    required String id,
    CancelToken? cancelToken,
  }) async {
    await _apiClient.delete<dynamic>(
      '$_visitedCountriesPath/$id',
      cancelToken: cancelToken,
    );
  }

  Future<void> deleteMyAccount({CancelToken? cancelToken}) async {
    await _apiClient.delete<dynamic>(_myAccountPath, cancelToken: cancelToken);
  }
}

int _sanitizePage(int page) => page < 1 ? 1 : page;

int _sanitizeLimit(int limit) {
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
  if (data is Map<String, dynamic>) {
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    return data;
  }

  throw const FormatException('응답 형식이 올바르지 않습니다.');
}
