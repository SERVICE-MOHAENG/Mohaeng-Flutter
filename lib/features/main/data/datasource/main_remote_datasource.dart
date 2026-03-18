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
  if (data is Map<String, dynamic>) {
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    return data;
  }

  throw const FormatException('응답 형식이 올바르지 않습니다.');
}
