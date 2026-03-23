import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/network/api_error.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart'
    as main_course;
import 'package:mohaeng_app_service/features/main/presentation/view/ui/main_course_roadmap_screen.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/liked_region_models.dart';
import 'package:mohaeng_app_service/features/mypage/presentation/view_model/mypage_providers.dart';
import 'package:mohaeng_app_service/features/mypage/presentation/view_model/mypage_view_model.dart';

class MyPageScreen extends ConsumerStatefulWidget {
  const MyPageScreen({super.key});

  @override
  ConsumerState<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends ConsumerState<MyPageScreen> {
  static const List<String> _scheduleTabs = <String>[
    '내 여행 일정',
    '여행 기록',
    '일정 좋아요',
    '블로그 좋아요',
    '좋아요한 여행지',
  ];

  int _scheduleTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(myPageViewModelProvider.notifier).loadInitial();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(myPageViewModelProvider);
    return MLayout(
      backgroundColor: MColor.gray50,
      appBar: AppBar(
        title: Text(
          '마이페이지',
          style: MTextStyles.labelM.copyWith(color: MColor.black100),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: MColor.gray50,
        surfaceTintColor: MColor.white100,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(myPageViewModelProvider.notifier)
              .loadInitial(forceRefresh: true);
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.zero,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildProfileHeader(state),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: _buildStatsCard(state),
              ),
              SizedBox(height: 23.h),
              _buildScheduleSection(state),
              SizedBox(height: 18.h),
              _buildSettingsSection(state),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleDeleteAccountTap() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('회원탈퇴'),
        content: const Text('정말 탈퇴하시겠어요?\n탈퇴 후 계정을 복구할 수 없어요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('탈퇴'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) {
      return;
    }

    try {
      await ref.read(myPageViewModelProvider.notifier).deleteMyAccount();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    } catch (error) {
      if (!mounted) return;
      final message = switch (error) {
        ApiError(:final message) => message,
        _ => '회원탈퇴에 실패했어요. 잠시 후 다시 시도해 주세요.',
      };
      _showMessage(message);
    }
  }

  Future<void> _handleLogoutTap() async {
    try {
      await ref.read(myPageViewModelProvider.notifier).logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
    } catch (error) {
      if (!mounted) return;
      final message = switch (error) {
        ApiError(:final message) => message,
        _ => '로그아웃에 실패했어요. 잠시 후 다시 시도해 주세요.',
      };
      _showMessage(message);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleOpenCourseRoadmap(CourseResponse course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MainCourseRoadmapScreen(course: _toMainCourse(course)),
      ),
    );
  }

  void _handleOpenCreatedRoadmap(CourseResponse course) {
    final itineraryId = (course.id ?? course.sourceCourseId)?.trim();
    if (itineraryId == null || itineraryId.isEmpty) {
      _showMessage('조회할 일정 ID를 확인하지 못했어요.');
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.roadmapResult,
      arguments: itineraryId,
    );
  }

  main_course.CourseResponse _toMainCourse(CourseResponse course) {
    final countryCode = course.countryCode?.trim();

    return main_course.CourseResponse(
      id: course.id,
      title: course.title,
      description: course.description,
      countryCode: countryCode,
      countries: course.countries.isNotEmpty
          ? course.countries
          : (countryCode == null || countryCode.isEmpty
                ? const <String>[]
                : <String>[countryCode]),
      regionNames: course.regionNames,
      thumbnailUrl: course.thumbnailUrl,
      nights: course.nights,
      days: course.days,
      likeCount: course.likeCount,
      isLiked: course.isLiked,
      tags: course.tags,
      places: course.places.map(_toMainCoursePlace).toList(growable: false),
      createdAt: course.createdAt,
      updatedAt: course.updatedAt,
      sourceCourseId: course.sourceCourseId,
    );
  }

  main_course.CoursePlaceResponse _toMainCoursePlace(
    CoursePlaceResponse place,
  ) {
    return main_course.CoursePlaceResponse(
      id: place.id,
      placeId: place.placeId,
      name: place.name,
      description: place.description,
      address: place.address,
      latitude: place.latitude,
      longitude: place.longitude,
      order: place.order,
      dayNumber: place.dayNumber,
      memo: place.memo,
      placeUrl: place.placeUrl,
      visitedAt: place.visitedAt,
    );
  }

  Widget _buildProfileHeader(MyPageState state) {
    final profile = state.user?.profile;
    final name = profile?.name?.trim();
    final email = profile?.email?.trim();
    final imageUrl = profile?.profileImageUrl?.trim();
    final showName = (name == null || name.isEmpty) ? null : name;
    final showEmail = (email == null || email.isEmpty) ? null : email;
    final showImageUrl = (imageUrl == null || imageUrl.isEmpty)
        ? null
        : imageUrl;

    return Row(
      children: [
        _buildProfileAvatar(showImageUrl),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.isLoadingUser ? '불러오는 중…' : (showName ?? '사용자'),
              style: MTextStyles.lBodyM.copyWith(color: MColor.black100),
            ),
            SizedBox(height: 4.h),
            Text(
              state.isLoadingUser ? '' : (showEmail ?? ''),
              style: MTextStyles.labelM.copyWith(color: MColor.gray400),
            ),
            if (!state.isLoadingUser && state.userErrorMessage != null)
              Padding(
                padding: EdgeInsets.only(top: 4.h),
                child: Text(
                  state.userErrorMessage!,
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(String? imageUrl) {
    final uri = imageUrl == null ? null : Uri.tryParse(imageUrl);
    final isNetwork = uri != null && uri.hasScheme;

    if (isNetwork) {
      return CircleAvatar(
        radius: 26.r,
        backgroundColor: MColor.gray100,
        backgroundImage: NetworkImage(imageUrl!),
        onBackgroundImageError: (exception, stackTrace) {},
        child: const SizedBox.shrink(),
      );
    }

    return CircleAvatar(
      radius: 26.r,
      backgroundColor: MColor.gray100,
      child: Icon(Icons.person, size: 26.w, color: MColor.gray300),
    );
  }

  Widget _buildStatsCard(MyPageState state) {
    final stats = state.user?.stats;
    final roadmapCount = stats?.createdRoadmaps.toString() ?? '-';
    final visitedCount = stats?.visitedCountries.toString() ?? '-';
    final blogCount = stats?.writtenBlogs.toString() ?? '-';
    final likedRegionCount = stats?.likedRegions.toString() ?? '-';

    return Container(
      padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          _StatItem(title: '여행 일정\n생성 횟수', value: roadmapCount),
          _StatItem(title: '방문한 국가', value: visitedCount, isEmphasized: true),
          _StatItem(title: '작성한 여행 기록', value: blogCount),
          _StatItem(title: '찜한 여행지', value: likedRegionCount),
        ],
      ),
    );
  }

  Widget _buildScheduleSection(MyPageState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            '내 활동',
            style: MTextStyles.lBodyM.copyWith(color: MColor.gray800),
          ),
        ),
        SizedBox(height: 10.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              for (int i = 0; i < _scheduleTabs.length; i++) ...[
                SizedBox(
                  width: 104.w,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _scheduleTabIndex = i),
                    child: _ScheduleTab(
                      label: _scheduleTabs[i],
                      isSelected: _scheduleTabIndex == i,
                    ),
                  ),
                ),
                if (i != _scheduleTabs.length - 1) SizedBox(width: 8.w),
              ],
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          color: MColor.white100,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: _buildScheduleTabContent(state),
          ),
        ),
      ],
    );
  }

  Widget _buildScheduleTabContent(MyPageState state) {
    final message = state.loadErrorMessage;

    bool isMissingSelectedTabData() {
      return switch (_scheduleTabIndex) {
        0 => state.myCourses == null,
        1 => state.myBlogs == null,
        2 => state.myCourseLikes == null,
        3 => state.myBlogLikes == null,
        _ => state.likedRegions == null,
      };
    }

    if (state.isLoading && isMissingSelectedTabData()) {
      return SizedBox(
        height: 180.h,
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

    if (!state.isLoading && message != null && isMissingSelectedTabData()) {
      return SizedBox(
        height: 180.h,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: MTextStyles.labelM.copyWith(color: MColor.gray400),
              ),
              SizedBox(height: 10.h),
              GestureDetector(
                onTap: () =>
                    ref.read(myPageViewModelProvider.notifier).refreshAll(),
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

    return switch (_scheduleTabIndex) {
      0 => _buildCourseCards(
        courses: state.myCourses?.courses ?? const <CourseResponse>[],
        emptyText: '내 여행 일정(코스)이 없어요.',
        onOpenCourse: _handleOpenCreatedRoadmap,
      ),
      1 => _buildBlogCards(
        blogs: state.myBlogs?.blogs ?? const <BlogResponse>[],
        emptyText: '작성한 여행 기록(블로그)이 없어요.',
      ),
      2 => _buildCourseCards(
        courses: state.myCourseLikes?.items ?? const <CourseResponse>[],
        emptyText: '좋아요한 일정이 없어요.',
        onOpenCourse: _handleOpenCourseRoadmap,
      ),
      3 => _buildBlogCards(
        blogs: state.myBlogLikes?.items ?? const <BlogResponse>[],
        emptyText: '좋아요한 블로그가 없어요.',
      ),
      _ => _buildLikedRegionCards(
        regions: state.likedRegions?.items ?? const <LikedRegionResponse>[],
        emptyText: '좋아요한 여행지가 없어요.',
      ),
    };
  }

  Widget _buildCourseCards({
    required List<CourseResponse> courses,
    required String emptyText,
    ValueChanged<CourseResponse>? onOpenCourse,
    bool showTitle = true,
  }) {
    if (courses.isEmpty) {
      return SizedBox(
        height: 60.h,
        child: Center(
          child: Text(
            emptyText,
            style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
          ),
        ),
      );
    }

    final display = courses.take(3).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < display.length; i++) ...[
          _buildTripCard(course: display[i], onTapPrimaryAction: onOpenCourse),
          if (i != display.length - 1) SizedBox(height: 10.h),
        ],
        if (showTitle) ...[
          SizedBox(height: 10.h),
          _buildIndicatorRow(count: display.length),
        ],
      ],
    );
  }

  Widget _buildBlogCards({
    required List<BlogResponse> blogs,
    required String emptyText,
    bool showTitle = true,
  }) {
    if (blogs.isEmpty) {
      return SizedBox(
        height: 60.h,
        child: Center(
          child: Text(
            emptyText,
            style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
          ),
        ),
      );
    }

    final display = blogs.take(3).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < display.length; i++) ...[
          _buildBlogCard(blog: display[i]),
          if (i != display.length - 1) SizedBox(height: 10.h),
        ],
        if (showTitle) ...[
          SizedBox(height: 10.h),
          _buildIndicatorRow(count: display.length),
        ],
      ],
    );
  }

  Widget _buildLikedRegionCards({
    required List<LikedRegionResponse> regions,
    required String emptyText,
    bool showTitle = true,
  }) {
    if (regions.isEmpty) {
      return SizedBox(
        height: 60.h,
        child: Center(
          child: Text(
            emptyText,
            style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
          ),
        ),
      );
    }

    final display = regions.take(3).toList(growable: false);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        for (int i = 0; i < display.length; i++) ...[
          _buildLikedRegionCard(region: display[i]),
          if (i != display.length - 1) SizedBox(height: 10.h),
        ],
        if (showTitle) ...[
          SizedBox(height: 10.h),
          _buildIndicatorRow(count: display.length),
        ],
      ],
    );
  }

  Widget _buildTripCard({
    required CourseResponse course,
    ValueChanged<CourseResponse>? onTapPrimaryAction,
  }) {
    final title = (course.title ?? '여행 코스').trim();
    final courseThumbnailUrl = _resolveNetworkImageUrl(course.thumbnailUrl);
    final daysText = switch ((course.nights, course.days)) {
      (final nights?, final days?) => '$nights박 $days일',
      (_, final days?) => '$days일 일정',
      _ => '일정',
    };
    final tags = course.tags
        .where((e) => e.trim().isNotEmpty)
        .take(2)
        .map((e) => e.startsWith('#') ? e : '#$e')
        .toList(growable: false);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: MColor.gray50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          if (courseThumbnailUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: _buildCourseThumbnail(courseThumbnailUrl),
            ),
            SizedBox(width: 10.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.labelB.copyWith(color: MColor.gray800),
                ),
                SizedBox(height: 4.h),
                Text(
                  daysText,
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    if (tags.isNotEmpty) ...[
                      for (int i = 0; i < tags.length; i++) ...[
                        _buildTag(tags[i]),
                        if (i != tags.length - 1) SizedBox(width: 6.w),
                      ],
                    ] else ...[
                      _buildTag('#여행코스'),
                    ],
                    Spacer(),
                    _buildPrimaryButton(
                      '바로가기',
                      onTap: onTapPrimaryAction == null
                          ? null
                          : () => onTapPrimaryAction(course),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseThumbnail(String thumbnailUrl) {
    return Image.network(
      thumbnailUrl,
      width: 58.w,
      height: 58.w,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          SizedBox(width: 58.w, height: 58.w),
    );
  }

  Widget _buildBlogCard({required BlogResponse blog}) {
    final title = (blog.title ?? '여행 기록').trim();
    final description = (blog.description ?? '').trim();
    final createdAtText = _formatCreatedAt(blog.createdAt);
    final tags = blog.tags
        .where((e) => e.trim().isNotEmpty)
        .take(2)
        .map((e) => e.startsWith('#') ? e : '#$e')
        .toList(growable: false);

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: MColor.gray50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: _buildBlogThumbnail(blog.thumbnailUrl),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.labelB.copyWith(color: MColor.gray800),
                ),
                SizedBox(height: 4.h),
                Text(
                  description.isNotEmpty
                      ? description
                      : (createdAtText ?? '내용이 없어요.'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    if (tags.isNotEmpty) ...[
                      for (int i = 0; i < tags.length; i++) ...[
                        _buildTag(tags[i]),
                        if (i != tags.length - 1) SizedBox(width: 6.w),
                      ],
                    ] else ...[
                      _buildTag('#여행후기'),
                    ],
                    const Spacer(),
                    Icon(
                      Icons.favorite_border,
                      size: 14.w,
                      color: MColor.gray300,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      (blog.likeCount ?? 0).toString(),
                      style: MTextStyles.sLabelM.copyWith(
                        color: MColor.gray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLikedRegionCard({required LikedRegionResponse region}) {
    final title = (region.regionName ?? '여행지').trim();
    final description = (region.description ?? '').trim();

    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: MColor.gray50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: _buildLikedRegionThumbnail(region.imageUrl),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? '여행지' : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.labelB.copyWith(color: MColor.gray800),
                ),
                SizedBox(height: 4.h),
                Text(
                  description.isEmpty ? '설명이 없어요.' : description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
                SizedBox(height: 10.h),
                Row(
                  children: [
                    _buildTag('#좋아요여행지'),
                    const Spacer(),
                    Icon(
                      Icons.favorite_rounded,
                      size: 14.w,
                      color: MColor.primary500,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      (region.likeCount ?? 0).toString(),
                      style: MTextStyles.sLabelM.copyWith(
                        color: MColor.gray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogThumbnail(String? thumbnailUrl) {
    final uri = thumbnailUrl == null ? null : Uri.tryParse(thumbnailUrl);
    final isNetwork = uri != null && uri.hasScheme;

    if (isNetwork) {
      final url = thumbnailUrl!;
      return Image.network(
        url,
        width: 58.w,
        height: 58.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          MImages.sibuya,
          width: 58.w,
          height: 58.w,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(MImages.sibuya, width: 58.w, height: 58.w);
  }

  Widget _buildLikedRegionThumbnail(String? imageUrl) {
    final uri = imageUrl == null ? null : Uri.tryParse(imageUrl);
    final isNetwork = uri != null && uri.hasScheme;

    if (isNetwork) {
      final url = imageUrl!;
      return Image.network(
        url,
        width: 58.w,
        height: 58.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          MImages.sibuya,
          width: 58.w,
          height: 58.w,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(MImages.sibuya, width: 58.w, height: 58.w);
  }

  String? _resolveNetworkImageUrl(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }

    final uri = Uri.tryParse(trimmed);
    if (uri == null || !uri.hasScheme) {
      return null;
    }

    return trimmed;
  }

  String? _formatCreatedAt(String? createdAt) {
    final value = createdAt?.trim();
    if (value == null || value.isEmpty) return null;

    final parsed = DateTime.tryParse(value);
    if (parsed == null) return null;

    final month = parsed.month.toString().padLeft(2, '0');
    final day = parsed.day.toString().padLeft(2, '0');
    return '${parsed.year}.$month.$day 작성';
  }

  Widget _buildIndicatorRow({int count = 3}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++) ...[
          _buildIndicatorDot(isActive: i == 0),
          if (i != count - 1) SizedBox(width: 6.w),
        ],
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

  Widget _buildPrimaryButton(String label, {VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(100.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: MColor.primary500,
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: Text(
            label,
            style: MTextStyles.sLabelB.copyWith(color: MColor.white100),
          ),
        ),
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

  Widget _buildSettingsSection(MyPageState state) {
    return Container(
      color: MColor.gray50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Text(
              '설정',
              style: MTextStyles.lBodyM.copyWith(color: MColor.black100),
            ),
          ),
          SizedBox(height: 10.h),
          Container(
            width: 1.sw,
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            decoration: BoxDecoration(color: MColor.white100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSettingItem('비밀번호 변경'),
                _buildSettingItem(
                  '로그아웃',
                  onTap: state.isDeletingAccount ? null : _handleLogoutTap,
                ),
                _buildSettingItem(
                  state.isDeletingAccount ? '회원탈퇴 처리중…' : '회원탈퇴',
                  onTap: state.isDeletingAccount
                      ? null
                      : _handleDeleteAccountTap,
                  trailing: state.isDeletingAccount
                      ? SizedBox(
                          width: 14.w,
                          height: 14.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            color: MColor.primary500,
                          ),
                        )
                      : null,
                ),
                _buildSettingItem(
                  '피드맥 하기',
                  onTap: () => _showMessage('피드맥 기능은 준비 중이에요.'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    String label, {
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: MTextStyles.labelM.copyWith(color: MColor.gray700),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
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
            style: MTextStyles.bodyB.copyWith(
              color: isEmphasized ? MColor.primary500 : Color(0xff111827),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: MTextStyles.sLabelM.copyWith(color: Color(0xff4B5563)),
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
    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          style: MTextStyles.labelM.copyWith(
            color: isSelected ? MColor.gray800 : MColor.gray300,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          height: 2.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isSelected ? MColor.primary500 : Colors.transparent,
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
      ],
    );
  }
}
