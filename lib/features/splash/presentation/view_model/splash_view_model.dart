import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';

@immutable
class SplashState {
  const SplashState({this.isChecking = false});

  final bool isChecking;

  SplashState copyWith({bool? isChecking}) {
    return SplashState(isChecking: isChecking ?? this.isChecking);
  }
}

class SplashViewModel extends StateNotifier<SplashState> {
  SplashViewModel(this._tokenStorage) : super(const SplashState());

  final AuthTokenStorage _tokenStorage;

  Future<bool> checkAutoLogin() async {
    if (state.isChecking) return false;
    state = state.copyWith(isChecking: true);
    try {
      final accessToken = await _tokenStorage.readAccessToken();
      return _isAccessTokenValid(accessToken);
    } finally {
      state = state.copyWith(isChecking: false);
    }
  }

  bool _isAccessTokenValid(String? token) {
    if (token == null || token.isEmpty) {
      return false;
    }

    final parts = token.split('.');
    if (parts.length != 3) {
      return false;
    }

    try {
      final normalized = base64Url.normalize(parts[1]);
      final payloadBytes = base64Url.decode(normalized);
      final payload =
          jsonDecode(utf8.decode(payloadBytes)) as Map<String, dynamic>;

      final expValue = payload['exp'];
      final expiresAtValue = payload['expiresAt'];
      if (expValue != null) {
        final exp = _parseExpiry(expValue);
        if (exp == null) {
          return false;
        }
        return exp.isAfter(DateTime.now().toUtc());
      }

      if (expiresAtValue is String) {
        final expiresAt = DateTime.tryParse(expiresAtValue);
        if (expiresAt != null) {
          return expiresAt.toUtc().isAfter(DateTime.now().toUtc());
        }
      }
    } catch (_) {
      return false;
    }

    return false;
  }

  DateTime? _parseExpiry(Object expValue) {
    int? exp;
    if (expValue is int) {
      exp = expValue;
    } else if (expValue is String) {
      exp = int.tryParse(expValue);
    }

    if (exp == null) {
      return null;
    }

    final expMs = exp > 1000000000000 ? exp : exp * 1000;
    return DateTime.fromMillisecondsSinceEpoch(expMs, isUtc: true);
  }
}
