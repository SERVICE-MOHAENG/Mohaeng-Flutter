import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';

class OauthButton extends StatelessWidget {
  final String label;
  final String imagePath;
  final Color textColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onPressed;

  const OauthButton({
    super.key,
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.imagePath,
    required this.borderColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 13.h),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.r),
          side: BorderSide(width: 1.w, color: borderColor),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath, width: 12.w, height: 12.h),
          SizedBox(width: 10.w),
          Text(label, style: MTextStyles.labelM.copyWith(color: textColor)),
        ],
      ),
    );
  }
}
