import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/main/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_blogs_view_model.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_courses_view_model.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_providers.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_user_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_preference_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_preference_result_view_model.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final FlutterEarthGlobeController _globeController;
  late final PageController _coursesPageController;

  int currentIndex = 0;
  String? _lastAiRecommendationRequestKey;
  String? _lastAiRecommendationLogKey;

  @override
  void initState() {
    super.initState();
    _globeController = FlutterEarthGlobeController(
      rotationSpeed: 0.05,
      minZoom: -1.5,
      maxZoom: 5,
      zoom: 0.5,
      isRotating: true,
      isZoomEnabled: false,
      atmosphereOpacity: 0.5,
      zoomToMousePosition: false,
      isBackgroundFollowingSphereRotation: true,
      background: Image.asset('assets/images/2k_stars.jpg').image,
      surface: Image.asset('assets/images/2k_earth-day.jpg').image,
      nightSurface: Image.asset('assets/images/2k_earth-night.jpg').image,
      isDayNightCycleEnabled: false,
      dayNightBlendFactor: 0.15,
    );
    _coursesPageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainCoursesViewModelProvider.notifier).load();
      ref.read(mainBlogsViewModelProvider.notifier).load();
      ref.read(mainUserViewModelProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _globeController.dispose();
    _coursesPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesState = ref.watch(mainCoursesViewModelProvider);
    final blogsState = ref.watch(mainBlogsViewModelProvider);
    final userState = ref.watch(mainUserViewModelProvider);
    final recommendationState = ref.watch(
      roadmapPreferenceResultViewModelProvider,
    );
    final surveyJobId = ref.watch(
      roadmapSurveyViewModelProvider.select((state) => state.response?.jobId),
    );
    final itineraryJobId = ref.watch(
      roadmapItineraryViewModelProvider.select(
        (state) => state.response?.jobId,
      ),
    );
    final preferenceJobId = (surveyJobId?.trim().isNotEmpty ?? false)
        ? surveyJobId
        : itineraryJobId;
    _maybeLoadAiRecommendations(
      preferenceJobId,
      surveyJobId: surveyJobId,
      itineraryJobId: itineraryJobId,
    );

    final horizontalPadding = 20.w;
    return MLayout(
      backgroundColor: MColor.white100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(horizontalPadding),
              _buildGreetingCard(userState),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildAiSection(recommendationState),
              ),
              SizedBox(height: 12.h),
              _buildDivider(),
              SizedBox(height: 9.h),
              _buildCourseSection(coursesState),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildBlogSection(blogsState),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeLoadAiRecommendations(
    String? rawJobId, {
    String? surveyJobId,
    String? itineraryJobId,
  }) {
    final jobId = rawJobId?.trim() ?? '';
    final normalizedSurveyJobId = surveyJobId?.trim() ?? '';
    final normalizedItineraryJobId = itineraryJobId?.trim() ?? '';
    if (jobId.isEmpty) {
      const requestKey = 'me';
      if (_lastAiRecommendationRequestKey == requestKey) {
        _logMainOnce(
          key: 'same:$requestKey',
          message: 'skip preference result load: same source=me',
        );
        return;
      }

      _lastAiRecommendationLogKey = null;
      _lastAiRecommendationRequestKey = requestKey;
      final key = 'me:$normalizedSurveyJobId:$normalizedItineraryJobId';
      _logMainOnce(
        key: key,
        message:
            'trigger preference me result load: no jobId (surveyJobId=${normalizedSurveyJobId.isEmpty ? 'empty' : normalizedSurveyJobId}, itineraryJobId=${normalizedItineraryJobId.isEmpty ? 'empty' : normalizedItineraryJobId})',
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(roadmapPreferenceResultViewModelProvider.notifier).loadMine();
      });
      return;
    }

    final requestKey = 'job:$jobId';
    if (requestKey == _lastAiRecommendationRequestKey) {
      _logMainOnce(
        key: 'same:$requestKey',
        message: 'skip preference result load: same jobId=$jobId',
      );
      return;
    }

    _lastAiRecommendationLogKey = null;
    _logMain('trigger preference result load: jobId=$jobId');
    _lastAiRecommendationRequestKey = requestKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(roadmapPreferenceResultViewModelProvider.notifier).load(jobId);
    });
  }

  void _logMain(String message) {
    if (!kDebugMode) return;
    debugPrint('[MAIN][AI] $message');
  }

  void _logMainOnce({required String key, required String message}) {
    if (_lastAiRecommendationLogKey == key) return;
    _lastAiRecommendationLogKey = key;
    _logMain(message);
  }

  Widget _buildDivider() {
    return Container(
      height: 32.h,
      decoration: BoxDecoration(color: MColor.gray50),
    );
  }

  Widget _buildHero(double horizontalPadding) {
    return Container(
      height: 320.h,
      color: MColor.black100,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(top: 110.h, child: _buildGlobe()),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Text(
                  '지금 여행 일정을\n같이 계획해 볼까요?',
                  textAlign: TextAlign.center,
                  style: MTextStyles.lBodyM.copyWith(color: MColor.white100),
                ),
                SizedBox(height: 12.h),
                _buildSearchBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.roadmap);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100.r),
          color: MColor.primary500,
        ),
        child: Text(
          '바로가기',
          style: TextStyle(
            fontFamily: 'GmarketSansBold',
            fontSize: 12.sp,
            color: MColor.white100,
          ),
        ),
      ),
    );
  }

  Widget _buildGlobe() {
    final screenWidth = MediaQuery.of(context).size.width;
    final globeSize = screenWidth - 24.w;
    final globeRadius = globeSize * 0.32;
    final globeMediaQuery = MediaQuery.of(
      context,
    ).copyWith(size: Size(globeSize, globeSize));
    return SizedBox(
      width: screenWidth,
      height: globeSize,
      child: Center(
        child: SizedBox(
          width: globeSize,
          height: globeSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: globeSize,
                height: globeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFF0F2442),
                      const Color(0xFF0B3C78),
                      const Color(0xFF0F6ED3),
                      const Color(0xFF4FC3FF),
                    ],
                    stops: const [0.2, 0.5, 0.75, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: MColor.black100.withValues(alpha: 0.15),
                      blurRadius: 20.r,
                      offset: Offset(0, 10.h),
                    ),
                  ],
                ),
              ),
              MediaQuery(
                data: globeMediaQuery,
                child: FlutterEarthGlobe(
                  radius: globeRadius,
                  controller: _globeController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(MainUserState userState) {
    final name = (userState.user?.name ?? '여행자').trim();
    final greeting = userState.isLoading ? '안녕하세요...' : '안녕하세요 $name님,';
    final visitedCountries = userState.user?.visitedCountries ?? 0;

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

  Widget _buildAiSection(RoadmapPreferenceResultState recommendationState) {
    final showEmptyMessage =
        !recommendationState.isLoading &&
        recommendationState.errorMessage == null &&
        recommendationState.items.isEmpty;

    if (showEmptyMessage) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              style: MTextStyles.lBodyM.copyWith(color: MColor.gray800),
              children: [
                const TextSpan(text: '모행 AI가 사용자에게\n'),
                TextSpan(
                  text: '딱!',
                  style: MTextStyles.lBodyB.copyWith(color: MColor.primary500),
                ),
                const TextSpan(text: ' 맞는 여행지를 찾았어요!'),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '모행의 AI가 사용자님의 정보를 기반으로\n추천하는 해외 여행지입니다!',
            style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 190.h,
            child: Center(
              child: Text(
                '추천 여행지가 없습니다.',
                style: MTextStyles.labelM.copyWith(color: MColor.gray500),
              ),
            ),
          ),
        ],
      );
    }

    final destinations = _resolveAiDestinations(recommendationState.items);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: MTextStyles.lBodyM.copyWith(color: MColor.gray800),
            children: [
              const TextSpan(text: '모행 AI가 사용자에게\n'),
              TextSpan(
                text: '딱!',
                style: MTextStyles.lBodyB.copyWith(color: MColor.primary500),
              ),
              const TextSpan(text: ' 맞는 여행지를 찾았어요!'),
            ],
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          '모행의 AI가 사용자님의 정보를 기반으로\n추천하는 해외 여행지입니다!',
          style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
        ),
        SizedBox(height: 20.h),

        SizedBox(
          height: 190.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: destinations.length,
            separatorBuilder: (_, _) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return _buildDestinationCard(
                title: destination.title,
                subtitle: destination.subtitle,
                imageUrl: destination.imageUrl,
                fallbackImagePath: destination.fallbackImagePath,
              );
            },
          ),
        ),
      ],
    );
  }

  List<_AiDestinationCardData> _resolveAiDestinations(
    List<RoadmapPreferenceResultItem> items,
  ) {
    final resolved = <_AiDestinationCardData>[];
    final maxCount = items.length > 4 ? 4 : items.length;
    for (int i = 0; i < maxCount; i++) {
      final item = items[i];
      final regionName = item.regionName.trim();
      final description = _extractReadableText(item.description);
      final imageUrl = _extractImageUrl(item.imageUrl);

      resolved.add(
        _AiDestinationCardData(
          title: regionName.isEmpty ? '추천 여행지' : regionName,
          subtitle: description ?? '모행 AI가 추천한 여행지입니다.',
          imageUrl: imageUrl,
          fallbackImagePath: MImages.sibuya,
        ),
      );
    }

    return resolved;
  }

  String? _extractReadableText(Object? value) {
    if (value == null) return null;

    if (value is String) {
      final normalized = value.trim();
      if (normalized.isEmpty || normalized == '{}' || normalized == '[]') {
        return null;
      }
      return normalized;
    }

    if (value is List) {
      for (final item in value) {
        final nested = _extractReadableText(item);
        if (nested != null) {
          return nested;
        }
      }
      return null;
    }

    if (value is Map) {
      const preferredKeys = <String>[
        'description',
        'summary',
        'content',
        'text',
        'value',
        'message',
        'url',
      ];

      for (final key in preferredKeys) {
        final nested = _extractReadableText(value[key]);
        if (nested != null) {
          return nested;
        }
      }

      for (final nestedValue in value.values) {
        final nested = _extractReadableText(nestedValue);
        if (nested != null) {
          return nested;
        }
      }
      return null;
    }

    final normalized = value.toString().trim();
    if (normalized.isEmpty || normalized == '{}' || normalized == '[]') {
      return null;
    }
    return normalized;
  }

  String? _extractImageUrl(Object? value) {
    final candidate = _extractReadableText(value);
    if (candidate == null || candidate.isEmpty) return null;

    final uri = Uri.tryParse(candidate);
    if (uri == null || !uri.hasScheme) return null;
    return candidate;
  }

  Widget _buildDestinationCard({
    required String title,
    required String subtitle,
    required String fallbackImagePath,
    String? imageUrl,
  }) {
    return Container(
      width: 155.w,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: _buildDestinationImage(
              imageUrl: imageUrl,
              fallbackImagePath: fallbackImagePath,
            ),
          ),
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 14.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: MTextStyles.lBodyB.copyWith(color: Colors.white),
                ),
                SizedBox(height: 6.h),
                Text(
                  subtitle,
                  maxLines: 8,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'GmarketSansMedium',
                    fontSize: 7.sp,
                    color: MColor.white100,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDestinationImage({
    required String fallbackImagePath,
    String? imageUrl,
  }) {
    final uri = imageUrl == null ? null : Uri.tryParse(imageUrl);
    final isNetwork = uri != null && uri.hasScheme;

    if (isNetwork) {
      final url = imageUrl!;
      return Image.network(
        url,
        fit: BoxFit.fill,
        width: 160.w,
        height: 194.h,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          fallbackImagePath,
          fit: BoxFit.fill,
          width: 160.w,
          height: 194.h,
        ),
      );
    }

    return Image.asset(
      fallbackImagePath,
      fit: BoxFit.fill,
      width: 160.w,
      height: 194.h,
    );
  }

  Widget _buildCourseSection(MainCoursesState coursesState) {
    final courseContent = _buildMainCoursesContent(coursesState);
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
                        : () => _onTapCountryFilter(countries[i].code),
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
            padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 20.w),
            child: courseContent,
          ),
        ),
      ],
    );
  }

  Widget _buildBar({required bool isActive, double? width, double? height}) {
    final barWidth = width ?? 24.w;
    final barHeight = height ?? 2.h;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: barWidth,
      height: barHeight,
      decoration: BoxDecoration(
        color: isActive ? MColor.gray500 : MColor.gray100,
      ),
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

  Widget _buildMainCoursesContent(MainCoursesState coursesState) {
    if (coursesState.isLoading) {
      return SizedBox(
        height: 120.h,
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
        height: 120.h,
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
                onTap: () =>
                    _onTapCountryFilter(coursesState.selectedCountryCode),
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
        height: 120.h,
        child: Center(
          child: Text(
            '아직 표시할 코스가 없어요.',
            style: MTextStyles.labelM.copyWith(color: MColor.gray500),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 120.h,
          child: PageView.builder(
            controller: _coursesPageController,
            itemCount: coursesState.courses.length,
            onPageChanged: (i) => setState(() => currentIndex = i),
            itemBuilder: (context, index) {
              return _buildCourseCard(course: coursesState.courses[index]);
            },
          ),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(coursesState.courses.length, (i) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: _buildBar(isActive: i == currentIndex),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCourseCard({required CourseResponse course}) {
    final title = (course.title ?? '여행 코스').trim();
    final daysText = course.days == null ? '일정' : '${course.days}일 일정';
    final tags = course.tags
        .where((e) => e.trim().isNotEmpty)
        .take(2)
        .map((e) => e.startsWith('#') ? e : '#$e')
        .toList(growable: false);

    final thumbnail = _buildCourseThumbnail(course.thumbnailUrl);

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: thumbnail,
              ),
              SizedBox(width: 12.w),
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
                    SizedBox(height: 8.h),
                    Text(
                      daysText,
                      style: MTextStyles.labelM.copyWith(color: MColor.gray500),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        if (tags.isNotEmpty) ...[
                          for (int i = 0; i < tags.length; i++) ...[
                            _buildTag(tags[i]),
                            if (i != tags.length - 1) SizedBox(width: 8.w),
                          ],
                        ] else ...[
                          _buildTag('#여행코스'),
                        ],
                        Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 12.h,
                          ),
                          decoration: BoxDecoration(
                            color: MColor.primary500,
                            borderRadius: BorderRadius.circular(100.r),
                          ),
                          child: Text(
                            '바로가기',
                            style: MTextStyles.labelB.copyWith(
                              color: MColor.white100,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
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
        width: 75.w,
        height: 75.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          MImages.sibuya,
          width: 75.w,
          height: 75.h,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(MImages.sibuya, width: 75.w, height: 75.h);
  }

  Widget _buildBlogSection(MainBlogsState blogsState) {
    final blogContent = _buildMainBlogsContent(blogsState);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '여행 블로그 보기',
          style: MTextStyles.lBodyM.copyWith(color: MColor.gray800),
        ),
        SizedBox(height: 8.h),
        Text(
          '생생한 여행 후기를 들을 수 있어요!',
          style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            _buildBlogFilterChip(
              '최신순',
              isSelected: blogsState.sortBy == 'latest',
              onTap: () => _onTapBlogSort('latest'),
            ),
            SizedBox(width: 8.w),
            _buildBlogFilterChip(
              '인기순',
              isSelected: blogsState.sortBy == 'popular',
              onTap: () => _onTapBlogSort('popular'),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        blogContent,
      ],
    );
  }

  Widget _buildMainBlogsContent(MainBlogsState blogsState) {
    if (blogsState.isLoading) {
      return SizedBox(
        height: 120.h,
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

    final errorMessage = blogsState.errorMessage;
    if (errorMessage != null) {
      return SizedBox(
        height: 120.h,
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
                onTap: () =>
                    ref.read(mainBlogsViewModelProvider.notifier).load(),
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

    if (blogsState.blogs.isEmpty) {
      return SizedBox(
        height: 120.h,
        child: Center(
          child: Text(
            '아직 표시할 블로그가 없어요.',
            style: MTextStyles.labelM.copyWith(color: MColor.gray500),
          ),
        ),
      );
    }

    return Column(
      children: [
        for (int i = 0; i < blogsState.blogs.length; i++) ...[
          _buildBlogListItem(blog: blogsState.blogs[i]),
          if (i != blogsState.blogs.length - 1) SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildBlogListItem({required BlogResponse blog}) {
    final title = (blog.title ?? '여행 블로그').trim();
    final description = (blog.description ?? '').trim();
    final tags = blog.tags
        .where((e) => e.trim().isNotEmpty)
        .take(2)
        .map((e) => e.startsWith('#') ? e : '#$e')
        .toList(growable: false);
    final likeCountText = (blog.likeCount ?? 0).toString();

    return _buildBlogItem(
      title: title,
      description: description.isEmpty ? '내용이 없어요.' : description,
      tags: tags.isEmpty ? const ['#여행후기'] : tags,
      likeCountText: likeCountText,
      thumbnailUrl: blog.thumbnailUrl,
    );
  }

  Widget _buildBlogItem({
    required String title,
    required String description,
    required List<String> tags,
    required String likeCountText,
    String? thumbnailUrl,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: _buildBlogThumbnail(thumbnailUrl),
          ),
          SizedBox(width: 20.w),
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
                SizedBox(height: 6.h),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    for (int i = 0; i < tags.length; i++) ...[
                      _buildBlogTag(tags[i]),
                      if (i != tags.length - 1) SizedBox(width: 6.w),
                    ],
                    Spacer(),
                    Icon(
                      Icons.favorite_border,
                      size: 14.w,
                      color: MColor.gray300,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      likeCountText,
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
        width: 75.w,
        height: 75.w,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Image.asset(
          'assets/images/country/sibuya.png',
          width: 75.w,
          height: 75.w,
          fit: BoxFit.cover,
        ),
      );
    }

    return Image.asset(
      'assets/images/country/sibuya.png',
      width: 75.w,
      height: 75.w,
      fit: BoxFit.cover,
    );
  }

  Widget _buildBlogFilterChip(
    String label, {
    bool isSelected = false,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 29.w, vertical: 12.h),
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

  Widget _buildBlogTag(String text) {
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

  Widget _buildTag(String text, {bool dense = false}) {
    return Container(
      padding: dense
          ? EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h)
          : EdgeInsets.all(4.w.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(width: 0.5.w, color: MColor.gray100),
      ),
      child: Text(
        text,
        style: MTextStyles.sLabelM.copyWith(color: MColor.primary500),
      ),
    );
  }

  void _onTapCountryFilter(String countryCode) {
    setState(() => currentIndex = 0);
    if (_coursesPageController.hasClients) {
      _coursesPageController.jumpToPage(0);
    }
    ref
        .read(mainCoursesViewModelProvider.notifier)
        .load(countryCode: countryCode);
  }

  void _onTapBlogSort(String sortBy) {
    ref.read(mainBlogsViewModelProvider.notifier).load(sortBy: sortBy);
  }
}

@immutable
class _AiDestinationCardData {
  const _AiDestinationCardData({
    required this.title,
    required this.subtitle,
    required this.fallbackImagePath,
    this.imageUrl,
  });

  final String title;
  final String subtitle;
  final String fallbackImagePath;
  final String? imageUrl;
}
