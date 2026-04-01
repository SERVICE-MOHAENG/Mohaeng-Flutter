import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/features/roadmap/data/datasource/country_api_service.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/country_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/exception/country_exception.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/country_repository.dart';

class CountryRepositoryImpl implements CountryRepository {
  CountryRepositoryImpl({CountryApiService? apiService})
    : _apiService = apiService ?? CountryApiService();

  final CountryApiService _apiService;

  @override
  Future<CountriesResponse> getCountries() async {
    try {
      return await _apiService.getCountries();
    } on ApiError catch (error) {
      throw _mapApiError(error);
    } on FormatException catch (error) {
      throw CountryUnknownException(message: error.message, cause: error);
    } catch (error) {
      throw CountryUnknownException(
        message: '국가 목록 조회 중 오류가 발생했습니다.',
        cause: error,
      );
    }
  }
}

CountryException _mapApiError(ApiError error) {
  return switch (error.kind) {
    ApiErrorKind.network || ApiErrorKind.timeout => CountryNetworkException(
      message: error.message,
      statusCode: error.statusCode,
      cause: error,
    ),
    _ => CountryUnknownException(
      message: error.message,
      statusCode: error.statusCode,
      cause: error,
    ),
  };
}
