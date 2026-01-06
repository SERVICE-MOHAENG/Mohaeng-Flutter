import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class CompleteSignUpScreen extends StatelessWidget {
  const CompleteSignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MLayout(
      backgroundColor: MColor.white100,
      body: Center(child: _buildCenter()),
      bottomSheet: _buildBottomSheet(() {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
      }),
    );
  }

  Widget _buildCenter() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(MImages.completeIcon, width: 100.w, height: 100.h),
        SizedBox(height: 25.h),
        Text(
          '손희찬님,\n모행에 오신걸 환영해요!',
          textAlign: TextAlign.center,
          style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
        ),
      ],
    );
  }

  Widget _buildBottomSheet(VoidCallback onPressed) {
    return Padding(
      padding: EdgeInsets.only(bottom: 32.h),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: MColor.primary500,
          padding: EdgeInsets.symmetric(horizontal: 150.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Text(
          '시작하기',
          style: TextStyle(
            fontFamily: 'GmarketSansMedium',
            color: MColor.white100,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }
}
