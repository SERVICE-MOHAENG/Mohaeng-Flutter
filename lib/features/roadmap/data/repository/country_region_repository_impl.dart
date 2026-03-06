import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/roadmap/data/datasource/country_region_api_service.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/country_region_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/exception/country_region_exception.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/country_region_repository.dart';

class CountryRegionRepositoryImpl implements CountryRegionRepository {
  CountryRegionRepositoryImpl({CountryRegionApiService? apiService})
    : _apiService = apiService ?? CountryRegionApiService();

  final CountryRegionApiService _apiService;

  @override
  Future<CountryRegionsResponse> getCountryRegions({
    required String countryName,
  }) async {
    final normalizedCountryName = countryName.trim();
    if (normalizedCountryName.isEmpty) {
      throw const CountryRegionUnknownException(message: '국가명을 입력해 주세요.');
    }

    try {
      return await _apiService.getCountryRegions(
        countryName: normalizedCountryName,
      );
    } on ApiError catch (error) {
      throw _mapApiError(error: error, countryName: normalizedCountryName);
    } on FormatException catch (error) {
      throw CountryRegionUnknownException(message: error.message, cause: error);
    } catch (error) {
      throw CountryRegionUnknownException(
        message: '도시 목록 조회 중 오류가 발생했습니다.',
        cause: error,
      );
    }
  }
}

CountryRegionException _mapApiError({
  required ApiError error,
  required String countryName,
}) {
  return switch (error.kind) {
    ApiErrorKind.notFound => CountryNotFoundException(
      countryName: countryName,
      message: error.message,
      statusCode: error.statusCode,
      cause: error,
    ),
    ApiErrorKind.network ||
    ApiErrorKind.timeout => CountryRegionNetworkException(
      message: error.message,
      statusCode: error.statusCode,
      cause: error,
    ),
    _ => CountryRegionUnknownException(
      message: error.message,
      statusCode: error.statusCode,
      cause: error,
    ),
  };
}
