import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class PeopleSelectScreen extends StatefulWidget {
  const PeopleSelectScreen({super.key});

  @override
  State<PeopleSelectScreen> createState() => _PeopleSelectScreenState();
}

class _PeopleSelectScreenState extends State<PeopleSelectScreen> {
  int _count = 1;

  @override
  Widget build(BuildContext context) {
    return MLayout(
      backgroundColor: MColor.white100,
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 16.w),
        child: _buildCompleteButton(),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 6.h),
            _buildTopBar(),
            Expanded(
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 40.h),
                      child: _buildDescription(),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: _buildCounterRow(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 44.h,
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
          color: MColor.black100,
          splashRadius: 22.r,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          Text(
            '인원 선택',
            textAlign: TextAlign.center,
            style: MTextStyles.lBodyM.copyWith(color: MColor.black100),
          ),
          SizedBox(height: 16.h),
          Text(
            '여행 가는 예상 인원을 선택해주세요!\n본인을 포함한 인원수로 계산을 해주세요!',
            textAlign: TextAlign.center,
            style: MTextStyles.labelM.copyWith(color: MColor.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SquareIconButton(
          imagePath: MImages.minusIcon,
          enabled: _count > 1,
          onPressed: _count > 1 ? () => setState(() => _count -= 1) : null,
        ),
        _CountCard(count: _count),
        _SquareIconButton(
          imagePath: MImages.plusIcon,
          enabled: _count < 99,
          onPressed: _count < 99 ? () => setState(() => _count += 1) : null,
        ),
      ],
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.roadmapCompanion),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: MColor.primary500,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Text(
          '완료',
          style: MTextStyles.labelM.copyWith(color: MColor.white100),
        ),
      ),
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  const _SquareIconButton({
    required this.enabled,
    required this.onPressed,
    required this.imagePath,
  });

  final String imagePath;
  final bool enabled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final background = enabled ? MColor.gray200 : MColor.gray100;

    return SizedBox(
      width: 60.w,
      height: 60.w,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          disabledBackgroundColor: background,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.r),
          ),
        ),
        child: Image.asset(imagePath, width: 32.w, height: 32.h),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76.w,
      height: 95.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(3.r),
        border: Border.all(color: MColor.primary500, width: 1.5.w),
      ),
      child: Text(
        '$count',
        style: MTextStyles.lHeadlineM.copyWith(color: MColor.black100),
      ),
    );
  }
}
