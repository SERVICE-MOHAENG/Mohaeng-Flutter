import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/core/network/api_client.dart';
import 'package:mohaeng_app_service/core/network/network_options.dart';

void main() {
  group('ApiClient', () {
    test('uses shared default timeout values', () {
      final client = ApiClient(
        baseUrl: 'https://example.com/',
        addLoggerInterceptor: false,
      );

      expect(client.dio.options.baseUrl, 'https://example.com');
      expect(
        client.dio.options.connectTimeout,
        NetworkTimeouts.defaultConnectTimeout,
      );
      expect(
        client.dio.options.sendTimeout,
        NetworkTimeouts.defaultSendTimeout,
      );
      expect(
        client.dio.options.receiveTimeout,
        NetworkTimeouts.defaultReceiveTimeout,
      );
    });

    test('allows timeout overrides through NetworkTimeouts', () {
      const timeouts = NetworkTimeouts(
        connectTimeout: Duration(seconds: 5),
        sendTimeout: Duration(seconds: 7),
        receiveTimeout: Duration(seconds: 9),
      );

      final client = ApiClient(
        baseUrl: 'https://example.com',
        addLoggerInterceptor: false,
        timeouts: timeouts,
      );

      expect(client.dio.options.connectTimeout, const Duration(seconds: 5));
      expect(client.dio.options.sendTimeout, const Duration(seconds: 7));
      expect(client.dio.options.receiveTimeout, const Duration(seconds: 9));
    });
  });
}
