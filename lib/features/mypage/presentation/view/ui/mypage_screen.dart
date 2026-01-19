import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MColor.white100,
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: MTextStyles.labelB.copyWith(color: MColor.gray800),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: MColor.white100,
        surfaceTintColor: MColor.white100,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildProfileHeader(),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildStatsCard(),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _buildScheduleSection(),
            ),
            SizedBox(height: 18.h),
            _buildSettingsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 26.r,
          backgroundColor: MColor.gray100,
          child: Icon(Icons.person, size: 26.w, color: MColor.gray300),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '손희찬님',
              style: MTextStyles.labelB.copyWith(color: MColor.gray800),
            ),
            SizedBox(height: 4.h),
            Text(
              'hxxchxx@dsm.hs.kr',
              style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: MColor.black100.withOpacity(0.05),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: const [
          _StatItem(title: '총 이용 횟수', value: '8'),
          _StatItem(title: '방문한 국가', value: '16', isEmphasized: true),
          _StatItem(title: '작성한 여행 기록', value: '8'),
          _StatItem(title: '찜한 여행지', value: '12'),
        ],
      ),
    );
  }

  Widget _buildScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '내 일정',
          style: MTextStyles.bodyB.copyWith(color: MColor.gray800),
        ),
        SizedBox(height: 10.h),
        Row(
          children: const [
            _ScheduleTab(label: '내 여행 일정', isSelected: true),
            _ScheduleTab(label: '여행 기록'),
            _ScheduleTab(label: '북마크'),
          ],
        ),
        SizedBox(height: 12.h),
        _buildTripCard(),
        SizedBox(height: 10.h),
        _buildTripCard(),
        SizedBox(height: 10.h),
        _buildTripCard(),
        SizedBox(height: 10.h),
        _buildIndicatorRow(),
      ],
    );
  }

  Widget _buildTripCard() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: MColor.black100.withOpacity(0.05),
            blurRadius: 12.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(MImages.sibuya, width: 58.w, height: 58.w),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시부야 밤거리',
                  style: MTextStyles.labelB.copyWith(color: MColor.gray800),
                ),
                SizedBox(height: 4.h),
                Text(
                  '1일 일정',
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _buildTag('#당일치기'),
                    SizedBox(width: 6.w),
                    _buildTag('#친구'),
                    Spacer(),
                    _buildPrimaryButton('바로가기'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildIndicatorDot(isActive: true),
        SizedBox(width: 6.w),
        _buildIndicatorDot(),
        SizedBox(width: 6.w),
        _buildIndicatorDot(),
      ],
    );
  }

  Widget _buildIndicatorDot({bool isActive = false}) {
    return Container(
      width: isActive ? 16.w : 6.w,
      height: 6.w,
      decoration: BoxDecoration(
        color: isActive ? MColor.primary500 : MColor.gray100,
        borderRadius: BorderRadius.circular(100.r),
      ),
    );
  }

  Widget _buildPrimaryButton(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: MColor.primary500,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        label,
        style: MTextStyles.sLabelB.copyWith(color: MColor.white100),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(width: 0.5.w, color: MColor.primary500),
      ),
      child: Text(
        text,
        style: MTextStyles.sLabelM.copyWith(color: MColor.primary500),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      color: MColor.gray50,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '설정',
            style: MTextStyles.bodyB.copyWith(color: MColor.gray800),
          ),
          SizedBox(height: 10.h),
          _buildSettingItem('비밀번호 변경'),
          _buildSettingItem('로그아웃'),
          _buildSettingItem('회원탈퇴'),
        ],
      ),
    );
  }

  Widget _buildSettingItem(String label) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Text(
        label,
        style: MTextStyles.labelM.copyWith(color: MColor.gray700),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isEmphasized;

  const _StatItem({
    required this.title,
    required this.value,
    this.isEmphasized = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: MTextStyles.labelB.copyWith(
              color: isEmphasized ? MColor.primary500 : MColor.gray800,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _ScheduleTab({required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: (isSelected ? MTextStyles.labelB : MTextStyles.labelM)
                .copyWith(
              color: isSelected ? MColor.gray800 : MColor.gray300,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 2.h,
            width: 24.w,
            decoration: BoxDecoration(
              color: isSelected ? MColor.primary500 : Colors.transparent,
              borderRadius: BorderRadius.circular(100.r),
            ),
          ),
        ],
      ),
    );
  }
}
