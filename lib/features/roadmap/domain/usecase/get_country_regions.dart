import 'package:mohaeng_app_service/features/roadmap/data/model/country_region_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/country_region_repository.dart';

class GetCountryRegionsUsecase {
  const GetCountryRegionsUsecase(this._repository);

  final CountryRegionRepository _repository;

  Future<CountryRegionsResponse> call({required String countryName}) {
    return _repository.getCountryRegions(countryName: countryName);
  }
}
