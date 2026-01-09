enum NaverLoginStatus { success, cancelled, failure }

class NaverLoginResult {
  const NaverLoginResult._(
    this.status, {
    this.accessToken,
    this.expiresAt,
    this.message,
  });

  final NaverLoginStatus status;
  final String? accessToken;
  final String? expiresAt;
  final String? message;

  factory NaverLoginResult.success(String accessToken, String expiresAt) {
    return NaverLoginResult._(
      NaverLoginStatus.success,
      accessToken: accessToken,
      expiresAt: expiresAt,
    );
  }

  factory NaverLoginResult.cancelled() {
    return const NaverLoginResult._(NaverLoginStatus.cancelled);
  }

  factory NaverLoginResult.failure(String message) {
    return NaverLoginResult._(NaverLoginStatus.failure, message: message);
  }
}
