import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return MLayout(
      backgroundColor: MColor.primary500,
      body: Center(child: _buildCenter()),
    );
  }

  Widget _buildCenter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(MImages.mohaengLogo, width: 35.w, height: 35.h),
            SizedBox(width: 12.w),
            Text(
              'MoHaeng',
              style: TextStyle(
                fontFamily: 'GmarketSansBold',
                color: MColor.white100,
                fontSize: 27.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Text(
          '모두의 여행 계획, 모행',
          style: MTextStyles.bodyM.copyWith(color: MColor.white100),
        ),
      ],
    );
  }

  Future<void> _checkAutoLogin() async {
    final storage = AuthTokenStorage();
    final accessToken = await storage.readAccessToken();
    final isValid = _isAccessTokenValid(accessToken);
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      isValid ? AppRoutes.root : AppRoutes.login,
      (_) => false,
    );
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
