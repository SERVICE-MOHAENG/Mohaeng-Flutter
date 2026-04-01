import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/ui/main_course_roadmap_list_screen.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/ui/main_course_roadmap_screen.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/widget/main_ai_recommendation_section.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/widget/main_blog_section.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/widget/main_course_section.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/widget/main_greeting_card.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/widget/main_hero_section.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_providers.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_preference_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final FlutterEarthGlobeController _globeController;
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mainCoursesViewModelProvider.notifier).load();
      ref.read(mainBlogsViewModelProvider.notifier).load();
      ref.read(mainUserViewModelProvider.notifier).load();
    });
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

    _maybeLoadAiRecommendations(
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
              MainHeroSection(
                horizontalPadding: horizontalPadding,
                globeController: _globeController,
              ),
              MainGreetingCard(userState: userState),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: MainAiRecommendationSection(
                  recommendationState: recommendationState,
                  onToggleLike: _onToggleAiRecommendationLike,
                ),
              ),
              SizedBox(height: 12.h),
              _buildDivider(),
              SizedBox(height: 9.h),
              MainCourseSection(
                coursesState: coursesState,
                onSelectCountry: _onTapCountryFilter,
                onToggleLike: _onToggleCourseLike,
                onOpenRoadmap: _onOpenCourseRoadmapList,
                onOpenCourseDetail: _onOpenCourseRoadmapDetail,
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: MainBlogSection(
                  blogsState: blogsState,
                  onRetry: _reloadBlogs,
                  onWrite: _openBlogWriteScreen,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _maybeLoadAiRecommendations({
    String? surveyJobId,
    String? itineraryJobId,
  }) {
    final normalizedSurveyJobId = surveyJobId?.trim() ?? '';
    final normalizedItineraryJobId = itineraryJobId?.trim() ?? '';
    final requestKey = 'me:$normalizedSurveyJobId:$normalizedItineraryJobId';
    if (requestKey == _lastAiRecommendationRequestKey) {
      _logMainOnce(
        key: 'same:$requestKey',
        message:
            'skip preference me result load: same refresh key (surveyJobId=${normalizedSurveyJobId.isEmpty ? 'empty' : normalizedSurveyJobId}, itineraryJobId=${normalizedItineraryJobId.isEmpty ? 'empty' : normalizedItineraryJobId})',
      );
      return;
    }

    _lastAiRecommendationLogKey = null;
    _lastAiRecommendationRequestKey = requestKey;
    final shouldForceRefresh =
        normalizedSurveyJobId.isNotEmpty || normalizedItineraryJobId.isNotEmpty;
    _logMain(
      'trigger preference me result load: surveyJobId=${normalizedSurveyJobId.isEmpty ? 'empty' : normalizedSurveyJobId}, itineraryJobId=${normalizedItineraryJobId.isEmpty ? 'empty' : normalizedItineraryJobId}, force=$shouldForceRefresh',
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(roadmapPreferenceResultViewModelProvider.notifier)
          .loadMine(force: shouldForceRefresh);
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

  void _onTapCountryFilter(String countryCode) {
    ref
        .read(mainCoursesViewModelProvider.notifier)
        .load(countryCode: countryCode);
  }

  void _onToggleCourseLike(CourseResponse course) {
    ref.read(mainCoursesViewModelProvider.notifier).toggleLike(course);
  }

  void _onOpenCourseRoadmapList() {
    final courses = ref.read(mainCoursesViewModelProvider).courses;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MainCourseRoadmapListScreen(
          courses: courses,
          onOpenCourseDetail: _onOpenCourseRoadmapDetail,
        ),
      ),
    );
  }

  void _onOpenCourseRoadmapDetail(CourseResponse course) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MainCourseRoadmapScreen(course: course),
      ),
    );
  }

  void _onToggleAiRecommendationLike(RoadmapPreferenceResultItem item) {
    ref
        .read(roadmapPreferenceResultViewModelProvider.notifier)
        .toggleLike(item);
  }

  void _reloadBlogs() {
    ref.read(mainBlogsViewModelProvider.notifier).load();
  }

  void _openBlogWriteScreen() {
    Navigator.of(context).pushNamed(AppRoutes.blogWrite);
  }
}
