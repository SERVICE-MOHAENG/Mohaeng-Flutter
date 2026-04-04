import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view/ui/blog_write_screen.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view_model/blog_providers.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view_model/blog_course_selection_view_model.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';

class BlogCourseSelectScreen extends ConsumerStatefulWidget {
  const BlogCourseSelectScreen({super.key});

  @override
  ConsumerState<BlogCourseSelectScreen> createState() =>
      _BlogCourseSelectScreenState();
}

class _BlogCourseSelectScreenState
    extends ConsumerState<BlogCourseSelectScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(blogCourseSelectionViewModelProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(blogCourseSelectionViewModelProvider);

    return MLayout(
      backgroundColor: MColor.gray50,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Text(
              '마이페이지',
              style: MTextStyles.labelM.copyWith(color: MColor.black100),
            ),
            SizedBox(height: 20.h),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildBody(state),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BlogCourseSelectionState state) {
    if (state.isLoading) {
      return Center(
        child: SizedBox(
          width: 22.w,
          height: 22.w,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            color: MColor.primary500,
          ),
        ),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.errorMessage!,
              textAlign: TextAlign.center,
              style: MTextStyles.labelM.copyWith(color: MColor.gray500),
            ),
            SizedBox(height: 12.h),
            OutlinedButton(
              onPressed: () => ref
                  .read(blogCourseSelectionViewModelProvider.notifier)
                  .load(),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: MColor.primary500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
              ),
              child: Text(
                '다시 시도',
                style: MTextStyles.labelM.copyWith(color: MColor.primary500),
              ),
            ),
          ],
        ),
      );
    }

    if (state.courses.isEmpty) {
      return Center(
        child: Text(
          '완료한 로드맵이 아직 없어요.',
          style: MTextStyles.labelM.copyWith(color: MColor.gray500),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.only(bottom: 24.h),
      itemCount: state.courses.length,
      separatorBuilder: (_, _) => SizedBox(height: 12.h),
      itemBuilder: (context, index) => _buildCourseCard(state.courses[index]),
    );
  }

  Widget _buildCourseCard(CourseResponse course) {
    final String title = (course.title ?? '여행 로드맵').trim();
    final int? days = course.days;
    final String durationText = days == null ? '일정' : '$days일 일정';
    final String subtitle = _buildSubtitle(course);

    return Container(
      height: 120.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: _buildThumbnail(course.thumbnailUrl),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MTextStyles.labelB.copyWith(
                          color: MColor.gray800,
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      durationText,
                      style: MTextStyles.sLabelM.copyWith(
                        color: MColor.gray400,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
                const Spacer(),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: () => _openWriteScreen(course),
                    style: OutlinedButton.styleFrom(
                      minimumSize: Size(72.w, 28.h),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 6.h,
                      ),
                      side: BorderSide(color: MColor.primary500, width: 1.1.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                    child: Text(
                      '선택하기',
                      style: MTextStyles.sLabelM.copyWith(
                        color: MColor.primary500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(String? thumbnailUrl) {
    if (thumbnailUrl != null && thumbnailUrl.trim().isNotEmpty) {
      return Image.network(
        thumbnailUrl,
        width: 84.w,
        height: 84.w,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _buildFallbackThumbnail(),
      );
    }

    return _buildFallbackThumbnail();
  }

  Widget _buildFallbackThumbnail() {
    return Image.asset(
      MImages.sibuya,
      width: 84.w,
      height: 84.w,
      fit: BoxFit.cover,
    );
  }

  String _buildSubtitle(CourseResponse course) {
    final String? description = course.description?.trim();
    if (description != null && description.isNotEmpty) {
      return description;
    }

    final String regions = course.regionNames
        .where((value) => value.trim().isNotEmpty)
        .join(', ');
    if (regions.isNotEmpty) {
      return regions;
    }

    final String countries = course.countries
        .where((value) => value.trim().isNotEmpty)
        .join(', ');
    if (countries.isNotEmpty) {
      return countries;
    }

    return '선택한 로드맵으로 블로그를 작성할 수 있어요.';
  }

  Future<void> _openWriteScreen(CourseResponse course) async {
    final String? courseId = course.id?.trim();
    if (courseId == null || courseId.isEmpty) return;

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlogWriteScreen(travelCourseId: courseId),
      ),
    );

    if (!mounted || result == null) return;
    Navigator.of(context).pop(result);
  }
}
