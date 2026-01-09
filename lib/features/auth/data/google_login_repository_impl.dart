import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mohaeng_app_service/features/auth/domain/entities/google_login_result.dart';
import 'package:mohaeng_app_service/features/auth/domain/repositories/google_login_repository.dart';

class GoogleLoginRepositoryImpl implements GoogleLoginRepository {
  GoogleLoginRepositoryImpl({GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? _buildGoogleSignIn();

  final GoogleSignIn _googleSignIn;

  static GoogleSignIn _buildGoogleSignIn() {
    if (kIsWeb || !Platform.isAndroid) {
      return GoogleSignIn();
    }

    final serverClientId = dotenv.env['ANDROID_GOOGLE_KEY']?.trim();
    return GoogleSignIn(
      serverClientId:
          serverClientId != null && serverClientId.isNotEmpty
              ? serverClientId
              : null,
    );
  }

  @override
  Future<GoogleLoginResult> login() async {
    if (kIsWeb || !Platform.isAndroid) {
      return GoogleLoginResult.failure('안드로이드에서만 지원합니다.');
    }

    try {
      await _googleSignIn.signOut();
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return GoogleLoginResult.cancelled();
      }

      final auth = await account.authentication;
      return GoogleLoginResult.success(
        accessToken: auth.accessToken,
        idToken: auth.idToken,
        serverAuthCode: account.serverAuthCode,
      );
    } on PlatformException catch (error) {
      if (_isCancelledCode(error.code) ||
          _isCancelledMessage(error.message)) {
        return GoogleLoginResult.cancelled();
      }
      return GoogleLoginResult.failure(
        '구글 로그인 실패: ${error.message ?? error.code}',
      );
    } catch (error) {
      if (_isCancelledMessage(error.toString())) {
        return GoogleLoginResult.cancelled();
      }
      return GoogleLoginResult.failure('구글 로그인 실패: $error');
    }
  }

  bool _isCancelledCode(String code) {
    final lower = code.toLowerCase();
    return lower == GoogleSignIn.kSignInCanceledError ||
        lower.contains('sign_in_canceled');
  }

  bool _isCancelledMessage(String? message) {
    if (message == null || message.isEmpty) return false;
    final lower = message.toLowerCase();
    return lower.contains('cancel') ||
        lower.contains('canceled') ||
        lower.contains('cancelled') ||
        message.contains('취소');
  }
}
