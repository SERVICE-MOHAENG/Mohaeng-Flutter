import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mohaeng_app_service/core/network/api_client.dart';
import 'package:mohaeng_app_service/core/network/auth_interceptor.dart';
import 'package:mohaeng_app_service/core/network/endpoints.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_chat_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_modification_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_preference_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_survey_models.dart';

class RoadmapRemoteDataSource {
  RoadmapRemoteDataSource({
    ApiClient? apiClient,
    AccessTokenProvider? accessTokenProvider,
    AuthTokenStorage? tokenStorage,
  }) : _apiClient =
           apiClient ??
           ApiClient(
             baseUrl: _readBaseUrl(),
             loggerLabel: 'ROADMAP-API',
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

  static const String _surveyPath =
      '${ApiEndpoints.basePath}/itineraries/surveys';
  static const String _itineraryPath = '${ApiEndpoints.basePath}/itineraries';
  static const String _modificationJobPath =
      '${ApiEndpoints.basePath}/itineraries/modification-jobs';
  static const String _preferenceJobPath =
      '${ApiEndpoints.basePath}/preferences/jobs';
  static const String _preferenceMeResultPath =
      '${ApiEndpoints.basePath}/preferences/me/result';

  Future<RoadmapSurveyResponse> createSurvey({
    required RoadmapSurveyRequest request,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.post<dynamic>(
      _surveyPath,
      data: request.toJson(),
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return RoadmapSurveyResponse.fromJson(payload);
  }

  Future<RoadmapItineraryResponse> createItinerary({
    required RoadmapItineraryRequest request,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.post<dynamic>(
      _itineraryPath,
      data: request.toJson(),
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return RoadmapItineraryResponse.fromJson(payload);
  }

  Future<RoadmapItineraryStatusResponse> getItineraryStatus({
    required String jobId,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.get<dynamic>(
      '$_itineraryPath/$jobId/status',
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return RoadmapItineraryStatusResponse.fromJson(payload);
  }

  Future<RoadmapItineraryResultResponse> getItineraryResult({
    required String jobId,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.get<dynamic>(
      '$_itineraryPath/$jobId',
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return RoadmapItineraryResultResponse.fromJson(payload);
  }

  Future<RoadmapChatResponse> sendRoadmapChat({
    required String itineraryId,
    required RoadmapChatRequest request,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.post<dynamic>(
      '$_itineraryPath/$itineraryId/chat',
      data: request.toJson(),
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return RoadmapChatResponse.fromJson(payload);
  }

  Future<RoadmapModificationStatusResponse> getModificationStatus({
    required String jobId,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.get<dynamic>(
      '$_modificationJobPath/$jobId/status',
      cancelToken: cancelToken,
    );

    final payload = _unwrapPayload(response.data);
    return RoadmapModificationStatusResponse.fromJson(payload);
  }

  Future<List<RoadmapPreferenceResultItem>> getPreferenceJobResult({
    required String jobId,
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.get<dynamic>(
      '$_preferenceJobPath/$jobId/result',
      cancelToken: cancelToken,
    );

    final payload = _unwrapListPayload(response.data);
    return payload.map(RoadmapPreferenceResultItem.fromJson).toList();
  }

  Future<List<RoadmapPreferenceResultItem>> getPreferenceMeResult({
    CancelToken? cancelToken,
  }) async {
    final response = await _apiClient.get<dynamic>(
      _preferenceMeResultPath,
      cancelToken: cancelToken,
    );

    final payload = _unwrapListPayload(response.data);
    return payload.map(RoadmapPreferenceResultItem.fromJson).toList();
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

List<Map<String, dynamic>> _unwrapListPayload(Object? data) {
  if (data is List) {
    return _parseMapList(data);
  }

  if (data is Map<String, dynamic>) {
    final nested = data['data'];
    if (nested is List) {
      return _parseMapList(nested);
    }
    if (nested is Map<String, dynamic>) {
      final destinations = nested['destinations'];
      if (destinations is List) {
        return _parseMapList(destinations);
      }
    }
  }

  throw const FormatException('응답 형식이 올바르지 않습니다.');
}

List<Map<String, dynamic>> _parseMapList(List<dynamic> source) {
  final result = <Map<String, dynamic>>[];
  for (final item in source) {
    if (item is Map<String, dynamic>) {
      result.add(item);
      continue;
    }
    if (item is Map) {
      result.add(item.map((key, value) => MapEntry(key.toString(), value)));
    }
  }
  return result;
}
