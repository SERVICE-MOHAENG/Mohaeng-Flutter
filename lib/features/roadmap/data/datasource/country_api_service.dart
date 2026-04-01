import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mohaeng_app_service/core/network/api_client.dart';
import 'package:mohaeng_app_service/core/network/auth_interceptor.dart';
import 'package:mohaeng_app_service/core/network/endpoints.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/country_models.dart';

class CountryApiService {
  CountryApiService({
    ApiClient? apiClient,
    AccessTokenProvider? accessTokenProvider,
    AuthTokenStorage? tokenStorage,
  }) : _apiClient =
           apiClient ??
           ApiClient(
             baseUrl: _readBaseUrl(),
             loggerLabel: 'COUNTRY-API',
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

  Future<CountriesResponse> getCountries({
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.get<dynamic>(
      ApiEndpoints.countries,
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return CountriesResponse.fromJson(payload);
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
      return _unwrapPayload(nested);
    }
    return data;
  }

  throw const FormatException('응답 형식이 올바르지 않습니다.');
}
