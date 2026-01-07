enum KakaoLoginStatus { success, cancelled, failure }

class KakaoLoginResult {
  const KakaoLoginResult._(
    this.status, {
    this.accessToken,
    this.expiresAt,
    this.message,
  });

  final KakaoLoginStatus status;
  final String? accessToken;
  final DateTime? expiresAt;
  final String? message;

  factory KakaoLoginResult.success(String accessToken, DateTime expiresAt) {
    return KakaoLoginResult._(
      KakaoLoginStatus.success,
      accessToken: accessToken,
      expiresAt: expiresAt,
    );
  }

  factory KakaoLoginResult.cancelled() {
    return const KakaoLoginResult._(KakaoLoginStatus.cancelled);
  }

  factory KakaoLoginResult.failure(String message) {
    return KakaoLoginResult._(KakaoLoginStatus.failure, message: message);
  }
}
