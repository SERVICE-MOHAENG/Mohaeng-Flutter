import 'package:mohaeng_app_service/features/roadmap/data/model/country_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/country_repository.dart';

class GetCountriesUsecase {
  const GetCountriesUsecase(this._repository);

  final CountryRepository _repository;

  Future<CountriesResponse> call() {
    return _repository.getCountries();
  }
}
