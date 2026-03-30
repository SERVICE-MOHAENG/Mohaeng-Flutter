import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/core/utils/user_friendly_message.dart';

void main() {
  group('toUserFriendlyMessage', () {
    const fallback = '잠시 후 다시 시도해주세요.';

    test('maps status-based exception messages to user-friendly copy', () {
      final message = toUserFriendlyMessage(
        'Exception: 로그인 실패: 401',
        fallbackMessage: fallback,
      );

      expect(message, '인증 정보를 다시 확인해주세요.');
    });

    test('maps network-related messages to a connection hint', () {
      final message = toUserFriendlyMessage(
        '회원가입 실패: 네트워크 오류',
        fallbackMessage: fallback,
      );

      expect(message, '네트워크 연결을 확인해주세요.');
    });

    test('falls back for technical configuration errors', () {
      final message = toUserFriendlyMessage(
        'FormatException: BASE_URL is not set.',
        fallbackMessage: fallback,
      );

      expect(message, fallback);
    });

    test('preserves already user-facing messages', () {
      final message = toUserFriendlyMessage(
        '이메일 형식을 확인해주세요.',
        fallbackMessage: fallback,
      );

      expect(message, '이메일 형식을 확인해주세요.');
    });
  });
}
