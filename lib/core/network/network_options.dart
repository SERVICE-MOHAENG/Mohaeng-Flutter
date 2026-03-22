import 'package:dio/dio.dart';

final class NetworkTimeouts {
  const NetworkTimeouts({
    this.connectTimeout = defaultConnectTimeout,
    this.sendTimeout = defaultSendTimeout,
    this.receiveTimeout = defaultReceiveTimeout,
  });

  static const Duration defaultConnectTimeout = Duration(seconds: 15);
  static const Duration defaultSendTimeout = Duration(seconds: 15);
  static const Duration defaultReceiveTimeout = Duration(seconds: 30);

  final Duration connectTimeout;
  final Duration sendTimeout;
  final Duration receiveTimeout;
}

BaseOptions buildJsonBaseOptions({
  required String baseUrl,
  Map<String, dynamic>? headers,
  NetworkTimeouts timeouts = const NetworkTimeouts(),
}) {
  return BaseOptions(
    baseUrl: normalizeBaseUrl(baseUrl),
    contentType: Headers.jsonContentType,
    responseType: ResponseType.json,
    headers: headers,
    connectTimeout: timeouts.connectTimeout,
    sendTimeout: timeouts.sendTimeout,
    receiveTimeout: timeouts.receiveTimeout,
  );
}

String normalizeBaseUrl(String baseUrl) {
  final trimmed = baseUrl.trim();
  if (trimmed.isEmpty) {
    throw const FormatException('baseUrl is empty.');
  }

  return trimmed.endsWith('/')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
}
