import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/splash/presentation/view_model/splash_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkAutoLogin();
    });
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
    final isValid = await ref
        .read(splashViewModelProvider.notifier)
        .checkAutoLogin();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      isValid ? AppRoutes.root : AppRoutes.login,
      (_) => false,
    );
  }
}
