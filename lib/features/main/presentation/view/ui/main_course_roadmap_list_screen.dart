import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/widget/main_course_roadmap_card.dart';

class MainCourseRoadmapListScreen extends StatelessWidget {
  const MainCourseRoadmapListScreen({
    super.key,
    required this.courses,
    required this.onOpenCourseDetail,
  });

  final List<CourseResponse> courses;
  final ValueChanged<CourseResponse> onOpenCourseDetail;

  @override
  Widget build(BuildContext context) {
    return MLayout(
      backgroundColor: MColor.white100,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18.sp,
                        color: MColor.gray800,
                      ),
                    ),
                  ),
                  Text(
                    '로드맵 보기',
                    style: MTextStyles.labelB.copyWith(color: MColor.gray900),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            if (courses.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      '조회할 로드맵이 아직 없어요.',
                      textAlign: TextAlign.center,
                      style: MTextStyles.labelM.copyWith(color: MColor.gray400),
                    ),
                  ),
                ),
              )
            else ...[
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
                  itemCount: courses.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final course = courses[index];
                    return MainCourseRoadmapCard(
                      course: course,
                      onTapPrimaryAction: () => onOpenCourseDetail(course),
                    );
                  },
                ),
              ),
              _RoadmapIndicatorRow(
                count: courses.length > 1 ? 3 : 1,
                selectedIndex: 0,
                activeColor: MColor.primary500,
                inactiveColor: MColor.gray100,
              ),
              SizedBox(height: 22.h),
            ],
          ],
        ),
      ),
    );
  }
}

class _RoadmapIndicatorRow extends StatelessWidget {
  const _RoadmapIndicatorRow({
    required this.count,
    required this.selectedIndex,
    required this.activeColor,
    required this.inactiveColor,
  });

  final int count;
  final int selectedIndex;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++) ...[
          Container(
            width: i == selectedIndex ? 22.w : 8.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: i == selectedIndex ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(999.r),
            ),
          ),
          if (i != count - 1) SizedBox(width: 6.w),
        ],
      ],
    );
  }
}
