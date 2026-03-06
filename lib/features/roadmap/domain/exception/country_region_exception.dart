sealed class CountryRegionException implements Exception {
  const CountryRegionException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() =>
      'CountryRegionException(message: $message, statusCode: $statusCode)';
}

final class CountryNotFoundException extends CountryRegionException {
  const CountryNotFoundException({
    required this.countryName,
    required super.message,
    super.statusCode = 404,
    super.cause,
  });

  final String countryName;
}

final class CountryRegionNetworkException extends CountryRegionException {
  const CountryRegionNetworkException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

final class CountryRegionUnknownException extends CountryRegionException {
  const CountryRegionUnknownException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}
