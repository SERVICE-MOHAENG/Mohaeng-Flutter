abstract final class ApiEndpoints {
  static const String basePath = '/api/v1';

  static const String countries = '$basePath/countries';
  static const String countryRegions = '$countries/regions';
  static const String courses = '$basePath/courses';
  static const String blogs = '$basePath/blogs';
  static const String visitedCountries = '$basePath/visited-countries';
}
