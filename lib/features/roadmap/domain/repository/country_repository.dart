import 'package:mohaeng_app_service/features/roadmap/data/model/country_models.dart';

abstract class CountryRepository {
  Future<CountriesResponse> getCountries();
}
