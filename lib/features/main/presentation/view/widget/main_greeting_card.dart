import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_user_view_model.dart';

class MainGreetingCard extends StatelessWidget {
  const MainGreetingCard({super.key, required this.userState});

  final MainUserState userState;

  @override
  Widget build(BuildContext context) {
    final name = (userState.user?.profile.name ?? '여행자').trim();
    final greeting = userState.isLoading ? '안녕하세요...' : '안녕하세요 $name님,';
    final visitedCountries = userState.user?.stats.visitedCountries ?? 0;

    return Container(
      padding: EdgeInsets.only(bottom: 28.h, left: 20.w, top: 20.h),
      decoration: BoxDecoration(color: MColor.gray50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
          ),
          if (userState.errorMessage != null) ...[
            SizedBox(height: 6.h),
            Text(
              userState.errorMessage!,
              style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
            ),
          ],
          Text.rich(
            TextSpan(
              style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
              children: [
                const TextSpan(text: '지금까지 '),
                TextSpan(
                  text: '$visitedCountries개국',
                  style: MTextStyles.bodyB.copyWith(color: MColor.primary500),
                ),
                const TextSpan(text: '을 여행했어요!'),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            width: 100.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: MColor.gray100,
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
        ],
      ),
    );
  }
}
