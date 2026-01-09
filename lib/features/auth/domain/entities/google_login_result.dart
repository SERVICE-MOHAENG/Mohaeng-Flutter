enum GoogleLoginStatus { success, cancelled, failure }

class GoogleLoginResult {
  const GoogleLoginResult._(
    this.status, {
    this.accessToken,
    this.idToken,
    this.serverAuthCode,
    this.message,
  });

  final GoogleLoginStatus status;
  final String? accessToken;
  final String? idToken;
  final String? serverAuthCode;
  final String? message;

  factory GoogleLoginResult.success({
    String? accessToken,
    String? idToken,
    String? serverAuthCode,
  }) {
    return GoogleLoginResult._(
      GoogleLoginStatus.success,
      accessToken: accessToken,
      idToken: idToken,
      serverAuthCode: serverAuthCode,
    );
  }

  factory GoogleLoginResult.cancelled() {
    return const GoogleLoginResult._(GoogleLoginStatus.cancelled);
  }

  factory GoogleLoginResult.failure(String message) {
    return GoogleLoginResult._(GoogleLoginStatus.failure, message: message);
  }
}
