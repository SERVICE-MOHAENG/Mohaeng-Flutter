import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';

class MainCourseRoadmapCard extends StatelessWidget {
  const MainCourseRoadmapCard({
    super.key,
    required this.course,
    required this.onTapPrimaryAction,
  });

  final CourseResponse course;
  final VoidCallback onTapPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final title = _resolveCourseTitle(course);
    final daysText = _resolveDaysText(course);
    final tags = _resolveTags(course);

    return Container(
      constraints: BoxConstraints(minHeight: 102.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: MColor.black100.withValues(alpha: 0.04),
            blurRadius: 14.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: _buildCourseThumbnail(course.thumbnailUrl),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.labelB.copyWith(color: MColor.gray800),
                ),
                SizedBox(height: 6.h),
                Text(
                  daysText,
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
                if (tags.isNotEmpty) ...[
                  SizedBox(height: 10.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 6.h,
                    children: [
                      for (final tag in tags) _CourseTagChip(text: tag),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 12.w),
          _CoursePrimaryButton(onTap: onTapPrimaryAction),
        ],
      ),
    );
  }

  Widget _buildCourseThumbnail(String? thumbnailUrl) {
    final uri = thumbnailUrl == null ? null : Uri.tryParse(thumbnailUrl);
    final isNetwork = uri != null && uri.hasScheme;

    if (isNetwork) {
      final url = thumbnailUrl!;
      return Image.network(
        url,
        width: 76.w,
        height: 76.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          MImages.sibuya,
          width: 76.w,
          height: 76.w,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      MImages.sibuya,
      width: 76.w,
      height: 76.w,
      fit: BoxFit.cover,
    );
  }
}

class _CoursePrimaryButton extends StatelessWidget {
  const _CoursePrimaryButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999.r),
        child: Ink(
          width: 86.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: MColor.primary500,
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Center(
            child: Text(
              '바로가기',
              style: MTextStyles.labelB.copyWith(color: MColor.white100),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseTagChip extends StatelessWidget {
  const _CourseTagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: [
          BoxShadow(
            color: MColor.black100.withValues(alpha: 0.05),
            blurRadius: 8.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Text(
        text,
        style: MTextStyles.sLabelM.copyWith(color: MColor.primary500),
      ),
    );
  }
}

String _resolveCourseTitle(CourseResponse course) {
  final title = (course.title ?? '').trim();
  if (title.isNotEmpty) return title;

  return course.places
      .map((place) => (place.name ?? '').trim())
      .firstWhere((name) => name.isNotEmpty, orElse: () => '여행 코스');
}

String _resolveDaysText(CourseResponse course) {
  final nights = course.nights;
  final days = course.days;
  if (nights != null && nights >= 0 && days != null && days > 0) {
    return '$nights박 $days일';
  }
  if (days != null && days > 0) {
    return '$days일 일정';
  }
  return '일정 미정';
}

List<String> _resolveTags(CourseResponse course) {
  return course.tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .map((tag) => tag.startsWith('#') ? tag : '#$tag')
      .take(2)
      .toList(growable: false);
}
