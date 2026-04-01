import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/core/network/api_logging_config.dart';

void main() {
  group('ApiLoggingConfig', () {
    test('falls back to debug mode when env is absent', () {
      final config = ApiLoggingConfig.fromEnvironment(fallbackEnabled: true);

      expect(config.enabled, isTrue);
      expect(config.maxBodyLength, 2000);
    });
  });
}
