import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mohaeng_app_service/core/network/api_client.dart';
import 'package:mohaeng_app_service/core/network/auth_interceptor.dart';
import 'package:mohaeng_app_service/core/network/endpoints.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/blog/data/model/blog_create_models.dart';

class BlogRemoteDataSource {
  BlogRemoteDataSource({
    ApiClient? apiClient,
    AccessTokenProvider? accessTokenProvider,
    AuthTokenStorage? tokenStorage,
  }) : _apiClient =
           apiClient ??
           ApiClient(
             baseUrl: _readBaseUrl(),
             loggerLabel: 'BLOG-API',
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

  Future<String> uploadImage({
    required String filePath,
    CancelToken? cancelToken,
  }) async {
    final String normalizedPath = filePath.trim();
    if (normalizedPath.isEmpty) {
      throw const FormatException('image file path is empty.');
    }

    final String fileName = normalizedPath.split('/').last;
    final FormData formData = FormData.fromMap(<String, dynamic>{
      'file': await MultipartFile.fromFile(normalizedPath, filename: fileName),
    });

    final response = await _apiClient.post<dynamic>(
      '${ApiEndpoints.basePath}/images/upload',
      data: formData,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    final imageUrl = payload['imageUrl'];
    if (imageUrl is String && imageUrl.trim().isNotEmpty) {
      return imageUrl.trim();
    }

    throw const FormatException('imageUrl is missing in upload response.');
  }

  Future<CreatedBlogResponse> createBlog({
    required CreateBlogRequest request,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.post<dynamic>(
      ApiEndpoints.blogs,
      data: request.toJson(),
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return CreatedBlogResponse.fromJson(payload);
  }
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
