sealed class CountryException implements Exception {
  const CountryException({
    required this.message,
    this.statusCode,
    this.cause,
  });

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() =>
      'CountryException(message: $message, statusCode: $statusCode)';
}

final class CountryNetworkException extends CountryException {
  const CountryNetworkException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}

final class CountryUnknownException extends CountryException {
  const CountryUnknownException({
    required super.message,
    super.statusCode,
    super.cause,
  });
}
