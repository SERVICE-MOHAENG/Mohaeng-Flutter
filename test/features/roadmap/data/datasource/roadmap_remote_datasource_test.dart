import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/core/network/api_client.dart';
import 'package:mohaeng_app_service/features/roadmap/data/datasource/roadmap_remote_datasource.dart';

void main() {
  group('RoadmapRemoteDataSource preference results', () {
    test('parses me result from data.destinations', () async {
      final dataSource = _buildDataSourceWithResponse(<String, dynamic>{
        'success': true,
        'data': <String, dynamic>{
          'destinations': <Map<String, dynamic>>[
            <String, dynamic>{
              'regionName': 'BARCELONA',
              'likeCount': 0,
              'isLiked': false,
            },
            <String, dynamic>{
              'regionName': 'COPENHAGEN',
              'likeCount': 3,
              'isLiked': true,
            },
          ],
        },
      });

      final items = await dataSource.getPreferenceMeResult();

      expect(items, hasLength(2));
      expect(items.first.regionName, 'BARCELONA');
      expect(items.last.regionName, 'COPENHAGEN');
      expect(items.last.likeCount, 3);
      expect(items.last.isLiked, isTrue);
    });

    test('parses job result from data list', () async {
      final dataSource = _buildDataSourceWithResponse(<String, dynamic>{
        'success': true,
        'data': <Map<String, dynamic>>[
          <String, dynamic>{
            'regionName': 'LISBON',
            'likeCount': 1,
            'isLiked': false,
          },
        ],
      });

      final items = await dataSource.getPreferenceJobResult(jobId: 'job-1');

      expect(items, hasLength(1));
      expect(items.single.regionName, 'LISBON');
      expect(items.single.likeCount, 1);
      expect(items.single.isLiked, isFalse);
    });
  });
}

RoadmapRemoteDataSource _buildDataSourceWithResponse(Object? responseData) {
  final dio = Dio();
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            data: responseData,
            statusCode: 200,
          ),
        );
      },
    ),
  );

  return RoadmapRemoteDataSource(
    apiClient: ApiClient(
      baseUrl: 'https://example.com',
      dio: dio,
      addLoggerInterceptor: false,
    ),
  );
}
