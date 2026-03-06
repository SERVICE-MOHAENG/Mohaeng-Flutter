import 'package:mohaeng_app_service/features/roadmap/data/model/country_region_models.dart';

abstract class CountryRegionRepository {
  Future<CountryRegionsResponse> getCountryRegions({
    required String countryName,
  });
}
