import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final FlutterEarthGlobeController _globeController;

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
  }

  @override
  void dispose() {
    _globeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 20.w;
    return MLayout(
      backgroundColor: MColor.gray50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(horizontalPadding),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildGreetingCard(),
              ),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildAiSection(),
              ),
              SizedBox(height: 18.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildCourseSection(),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildBlogSection(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(double horizontalPadding) {
    return Container(
      height: 320.h,
      color: MColor.black100,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 110.h,
            child: _buildGlobe(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: 8.h),
                Text(
                  '지금 여행 일정을\n같이 알아볼까요?',
                  textAlign: TextAlign.center,
                  style: MTextStyles.lBodyM.copyWith(color: MColor.white100),
                ),
                SizedBox(height: 14.h),
                _buildSearchBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: _cardShadow(),
      ),
      child: Row(
        children: [
          Icon(Icons.search, size: 16.r, color: MColor.gray400),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '대만 여행지...',
              style: MTextStyles.bodyM.copyWith(color: MColor.gray200),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: MColor.primary500,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '검색',
              style: MTextStyles.labelB.copyWith(color: MColor.white100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobe() {
    final screenWidth = MediaQuery.of(context).size.width;
    final globeSize = screenWidth - 24.w;
    final globeRadius = globeSize * 0.32;
    final globeMediaQuery = MediaQuery.of(context).copyWith(
      size: Size(globeSize, globeSize),
    );
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
                      color: MColor.black100.withOpacity(0.15),
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

  Widget _buildGreetingCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: _cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요 김모행님,',
            style: MTextStyles.bodyM.copyWith(color: MColor.gray600),
          ),
          SizedBox(height: 6.h),
          Text.rich(
            TextSpan(
              style: MTextStyles.bodyB.copyWith(color: MColor.gray700),
              children: [
                const TextSpan(text: '지금까지 '),
                TextSpan(
                  text: '14개국',
                  style: MTextStyles.bodyB.copyWith(color: MColor.primary500),
                ),
                const TextSpan(text: '을 여행했어요!'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: MTextStyles.bodyB.copyWith(color: MColor.gray800),
            children: [
              const TextSpan(text: '모행 AI가 사용자에게\n'),
              TextSpan(
                text: '딱!',
                style: MTextStyles.bodyB.copyWith(color: MColor.primary500),
              ),
              const TextSpan(text: ' 맞는 여행지를 찾았어요!'),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 190.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 2,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildDestinationCard(
                  title: '일본 도쿄',
                  subtitle: '밤거리부터 벚꽃까지\n도쿄의 로망 가득',
                  colors: const [
                    Color(0xFFE7C9C3),
                    Color(0xFFD29AA5),
                    Color(0xFF9C6A78),
                  ],
                );
              }
              return _buildDestinationCard(
                title: '미국 뉴욕',
                subtitle: '영화 같은 스카이라인\n뉴욕의 하루',
                colors: const [
                  Color(0xFF2F3648),
                  Color(0xFF4C5670),
                  Color(0xFF7C86A2),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDestinationCard({
    required String title,
    required String subtitle,
    required List<Color> colors,
  }) {
    return Container(
      width: 155.w,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: _cardShadow(),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12.w,
            right: 12.w,
            bottom: 14.h,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: MTextStyles.labelB.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: MTextStyles.sLabelM.copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '사람들이 선정한 인기있는 여행코스에요!',
          style: MTextStyles.bodyB.copyWith(color: MColor.gray800),
        ),
        SizedBox(height: 4.h),
        Text(
          '여행이 처음이라면 한번 확인해 보세요!',
          style: MTextStyles.labelM.copyWith(color: MColor.gray500),
        ),
        SizedBox(height: 12.h),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('전체', isSelected: true),
              SizedBox(width: 8.w),
              _buildFilterChip('힐링'),
              SizedBox(width: 8.w),
              _buildFilterChip('익스트림'),
              SizedBox(width: 8.w),
              _buildFilterChip('관광'),
              SizedBox(width: 8.w),
              _buildFilterChip('휴양'),
              SizedBox(width: 8.w),
              _buildFilterChip('맛집'),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        _buildCourseCard(),
      ],
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isSelected ? MColor.primary500 : MColor.white100,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isSelected ? MColor.primary500 : MColor.gray200,
          width: 1.w,
        ),
        boxShadow: isSelected ? _cardShadow() : null,
      ),
      child: Text(
        label,
        style: MTextStyles.labelM.copyWith(
          color: isSelected ? MColor.white100 : MColor.gray600,
        ),
      ),
    );
  }

  Widget _buildCourseCard() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: _cardShadow(),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              width: 68.w,
              height: 68.w,
              decoration: const BoxDecoration(
                backgroundBlendMode: BlendMode.srcOver,
                gradient: LinearGradient(
                  colors: [Color(0xFF7DD6D6), Color(0xFF3B82F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '시내를 만끽하는 여행',
                  style: MTextStyles.bodyB.copyWith(color: MColor.gray800),
                ),
                SizedBox(height: 6.h),
                Text(
                  '3박 4일간의 여행코스',
                  style: MTextStyles.labelM.copyWith(color: MColor.gray500),
                ),
                SizedBox(height: 6.h),
                _buildTag('힐링코스'),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: MColor.primary500,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '바로가기',
              style: MTextStyles.sLabelB.copyWith(color: MColor.white100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '여행 블로그 보기',
          style: MTextStyles.bodyB.copyWith(color: MColor.gray800),
        ),
        SizedBox(height: 4.h),
        Text(
          '생생한 여행기를 남겨보아요',
          style: MTextStyles.labelM.copyWith(color: MColor.gray500),
        ),
        SizedBox(height: 12.h),
        _buildBlogItem(
          title: '서른의 계절을 전부 담은 유럽기행',
          tag: '배낭여행',
          date: '10/02',
        ),
        SizedBox(height: 10.h),
        _buildBlogItem(
          title: '서해안 로드트립, 노을과 함께',
          tag: '힐링여행',
          date: '10/02',
        ),
        SizedBox(height: 10.h),
        _buildBlogItem(
          title: '시내에서 즐기는 하루 미식 투어',
          tag: '맛집여행',
          date: '10/02',
        ),
      ],
    );
  }

  Widget _buildBlogItem({
    required String title,
    required String tag,
    required String date,
  }) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: MColor.white100,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: _cardShadow(),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Container(
              width: 58.w,
              height: 58.w,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.labelB.copyWith(color: MColor.gray800),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    _buildTag(tag, dense: true),
                    SizedBox(width: 6.w),
                    Text(
                      date,
                      style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
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

  Widget _buildTag(String text, {bool dense = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8.w : 10.w,
        vertical: dense ? 3.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: MColor.primary100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        text,
        style: MTextStyles.sLabelB.copyWith(color: MColor.primary700),
      ),
    );
  }

  List<BoxShadow> _cardShadow() {
    return [
      BoxShadow(
        color: MColor.black100.withOpacity(0.08),
        blurRadius: 12.r,
        offset: Offset(0, 6.h),
      ),
    ];
  }
}
