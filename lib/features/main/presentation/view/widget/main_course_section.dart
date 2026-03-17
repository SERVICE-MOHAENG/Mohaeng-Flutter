import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_courses_view_model.dart';

class MainCourseSection extends StatelessWidget {
  const MainCourseSection({
    super.key,
    required this.coursesState,
    required this.onSelectCountry,
    required this.onToggleLike,
  });

  final MainCoursesState coursesState;
  final ValueChanged<String> onSelectCountry;
  final ValueChanged<CourseResponse> onToggleLike;

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
        height: 194.h,
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
        height: 194.h,
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

    if (coursesState.courses.isEmpty) {
      return SizedBox(
        height: 194.h,
        child: Center(
          child: Text(
            '아직 표시할 코스가 없어요.',
            style: MTextStyles.labelM.copyWith(color: MColor.gray500),
          ),
        ),
      );
    }

    return SizedBox(
      height: 194.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        scrollDirection: Axis.horizontal,
        itemCount: coursesState.courses.length,
        separatorBuilder: (_, _) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          return _buildCourseCard(course: coursesState.courses[index]);
        },
      ),
    );
  }

  Widget _buildCourseCard({required CourseResponse course}) {
    final title = _resolveCourseTitle(course);
    final description = _buildCourseDescription(course);
    final isLiked = course.isLiked ?? false;
    final likeCount = course.likeCount ?? 0;

    return Container(
      width: 160.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.16.r),
        boxShadow: [
          BoxShadow(
            color: MColor.black100.withValues(alpha: 0.12),
            blurRadius: 18.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.16.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildCourseThumbnail(course.thumbnailUrl),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    MColor.black100.withValues(alpha: 0.28),
                    MColor.black100.withValues(alpha: 0.62),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 12.32.w,
              right: 12.32.w,
              bottom: 16.h,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: MTextStyles.lBodyB.copyWith(
                      color: MColor.white100,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    description,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontWeight: FontWeight.w500,
                      fontSize: 7.sp,
                      height: 1.28,
                      color: MColor.white100.withValues(alpha: 0.95),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: _buildCourseLikeBadge(
                course: course,
                isLiked: isLiked,
                likeCount: likeCount,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseLikeBadge({
    required CourseResponse course,
    required bool isLiked,
    required int likeCount,
  }) {
    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onToggleLike(course),
            customBorder: const CircleBorder(),
            child: Ink(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: MColor.white100,
                shape: BoxShape.circle,
                border: Border.all(width: 0.3.w, color: MColor.gray200),
              ),
              child: Icon(
                isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: isLiked ? const Color(0xFFFF4C78) : MColor.gray300,
                size: 24.w,
              ),
            ),
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          _formatLikeCount(likeCount),
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
            color: MColor.gray300,
          ),
        ),
      ],
    );
  }

  Widget _buildCourseThumbnail(String? thumbnailUrl) {
    final uri = thumbnailUrl == null ? null : Uri.tryParse(thumbnailUrl);
    final isNetwork = uri != null && uri.hasScheme;

    if (isNetwork) {
      final url = thumbnailUrl!;
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            Image.asset(MImages.sibuya, fit: BoxFit.cover),
      );
    }

    return Image.asset(MImages.sibuya, fit: BoxFit.cover);
  }
}

String _resolveCourseTitle(CourseResponse course) {
  final title = (course.title ?? '').trim();
  if (title.isNotEmpty) return title;

  return course.places
      .map((place) => (place.name ?? '').trim())
      .firstWhere(
        (name) => name.isNotEmpty,
        orElse: () => _countryLabel(course.countryCode),
      );
}

String _buildCourseDescription(CourseResponse course) {
  final placeNames = course.places
      .map((place) => (place.name ?? '').trim())
      .where((name) => name.isNotEmpty)
      .take(3)
      .toList(growable: false);
  final tagNames = course.tags
      .map((tag) => tag.replaceFirst('#', '').trim())
      .where((tag) => tag.isNotEmpty)
      .take(2)
      .toList(growable: false);

  final buffer = StringBuffer();
  final days = course.days;
  if (days != null && days > 0) {
    buffer.write('$days일 동안 ');
  }

  if (placeNames.isNotEmpty) {
    buffer.write('${placeNames.join(', ')}를 둘러보는 여행 코스');
  } else if (tagNames.isNotEmpty) {
    buffer.write('${tagNames.join(', ')} 테마를 담은 여행 코스');
  } else {
    buffer.write('지금 메인에서 바로 둘러볼 수 있는 추천 여행 코스');
  }

  return buffer.toString();
}

String _countryLabel(String? countryCode) {
  return switch ((countryCode ?? '').trim().toUpperCase()) {
    'JP' => '일본',
    'US' => '미국',
    'FR' => '프랑스',
    'EG' => '이집트',
    'DE' => '독일',
    _ => '여행 코스',
  };
}

String _formatLikeCount(int value) {
  final safeValue = value < 0 ? 0 : value;
  final raw = safeValue.toString();
  return raw.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
}
