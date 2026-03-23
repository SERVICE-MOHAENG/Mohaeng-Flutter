import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mohaeng_app_service/core/network/api_client.dart';
import 'package:mohaeng_app_service/core/network/auth_interceptor.dart';
import 'package:mohaeng_app_service/core/network/endpoints.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/country_region_models.dart';

class CountryRegionApiService {
  CountryRegionApiService({
    ApiClient? apiClient,
    AccessTokenProvider? accessTokenProvider,
    AuthTokenStorage? tokenStorage,
  }) : _apiClient =
           apiClient ??
           ApiClient(
             baseUrl: _readBaseUrl(),
             loggerLabel: 'REGION-API',
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

  Future<CountryRegionsResponse> getCountryRegions({
    required String countryName,
    CancelToken? cancelToken,
  }) async {
    final normalizedCountryName = countryName.trim();
    if (normalizedCountryName.isEmpty) {
      throw ArgumentError.value(countryName, 'countryName', '국가명은 필수입니다.');
    }

    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.countryRegions,
      queryParameters: {'countryName': normalizedCountryName},
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return CountryRegionsResponse.fromJson(payload);
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
  if (data is Map<String, dynamic>) {
    final nested = data['data'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    return data;
  }

  throw const FormatException('응답 형식이 올바르지 않습니다.');
}
