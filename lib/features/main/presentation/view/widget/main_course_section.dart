import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/widget/main_course_roadmap_card.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_courses_view_model.dart';

class MainCourseSection extends StatelessWidget {
  const MainCourseSection({
    super.key,
    required this.coursesState,
    required this.onSelectCountry,
    required this.onToggleLike,
    required this.onOpenRoadmap,
    required this.onOpenCourseDetail,
  });

  final MainCoursesState coursesState;
  final ValueChanged<String> onSelectCountry;
  final ValueChanged<CourseResponse> onToggleLike;
  final VoidCallback onOpenRoadmap;
  final ValueChanged<CourseResponse> onOpenCourseDetail;

  List<CourseResponse> get _displayCourses {
    return coursesState.courses;
  }

  @override
  Widget build(BuildContext context) {
    final courseContent = _buildMainCoursesContent();
    final countries = const <({String label, String code})>[
      (label: '일본', code: 'JP'),
      (label: '미국', code: 'US'),
      (label: '프랑스', code: 'FR'),
      (label: '이집트', code: 'EG'),
      (label: '독일', code: 'DE'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            '사람들이 생성한 인기있는\n여행코스에요!',
            style: MTextStyles.lBodyM.copyWith(color: MColor.gray800),
          ),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            '실제 경험을 바탕으로 코스를 짰어요!',
            style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
          ),
        ),
        SizedBox(height: 22.h),
        Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (int i = 0; i < countries.length; i++) ...[
                  _buildFilterChip(
                    countries[i].label,
                    isSelected:
                        coursesState.selectedCountryCode == countries[i].code,
                    onTap: coursesState.isLoading
                        ? null
                        : () => onSelectCountry(countries[i].code),
                  ),
                  if (i != countries.length - 1) SizedBox(width: 8.w),
                ],
              ],
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: 1.sw,
          decoration: BoxDecoration(color: MColor.gray50),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 22.h),
            child: courseContent,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? MColor.primary500 : MColor.gray100,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: Text(
          label,
          style: isSelected
              ? MTextStyles.labelB.copyWith(color: MColor.white100)
              : MTextStyles.labelM.copyWith(color: MColor.gray400),
        ),
      ),
    );
  }

  Widget _buildMainCoursesContent() {
    if (coursesState.isLoading) {
      return SizedBox(
        height: 176.h,
        child: Center(
          child: SizedBox(
            width: 20.w,
            height: 20.w,
            child: CircularProgressIndicator(
              strokeWidth: 2.w,
              color: MColor.primary500,
            ),
          ),
        ),
      );
    }

    final errorMessage = coursesState.errorMessage;
    if (errorMessage != null) {
      return SizedBox(
        height: 176.h,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                errorMessage,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: MTextStyles.labelM.copyWith(color: MColor.gray500),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () => onSelectCountry(coursesState.selectedCountryCode),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: MColor.primary500,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: Text(
                    '다시 시도',
                    style: MTextStyles.labelB.copyWith(color: MColor.white100),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final displayCourses = _displayCourses;
    if (displayCourses.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _buildEmptyCourseCard(),
          ),
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: _buildOpenRoadmapButton(),
          ),
        ],
      );
    }

    final featuredCourse = displayCourses.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: MainCourseRoadmapCard(
            course: featuredCourse,
            onTapPrimaryAction: () => onOpenCourseDetail(featuredCourse),
          ),
        ),
        SizedBox(height: 12.h),
        _RoadmapIndicatorRow(
          count: displayCourses.length.clamp(1, 4),
          selectedIndex: 0,
          activeColor: MColor.gray600,
          inactiveColor: MColor.gray100,
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: _buildOpenRoadmapButton(),
        ),
      ],
    );
  }

  Widget _buildEmptyCourseCard() {
    return Container(
      constraints: BoxConstraints(minHeight: 102.h),
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Center(
        child: Text(
          '표시할 여행 코스가 없어요.',
          textAlign: TextAlign.center,
          style: MTextStyles.labelM.copyWith(color: MColor.gray400),
        ),
      ),
    );
  }

  Widget _buildOpenRoadmapButton() {
    return Align(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpenRoadmap,
          borderRadius: BorderRadius.circular(999.r),
          child: Ink(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            decoration: BoxDecoration(
              color: MColor.white100,
              borderRadius: BorderRadius.circular(999.r),
              border: Border.all(color: MColor.primary500, width: 1.2.w),
            ),
            child: Center(
              child: Text(
                '로드맵 보러가기',
                style: MTextStyles.sLabelM.copyWith(color: MColor.primary500),
              ),
            ),
          ),
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
