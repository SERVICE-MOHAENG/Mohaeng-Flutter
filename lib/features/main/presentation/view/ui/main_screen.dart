import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final FlutterEarthGlobeController _globeController;

  int currentIndex = 0;

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
      backgroundColor: MColor.white100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHero(horizontalPadding),
              _buildGreetingCard(),
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: _buildAiSection(),
              ),
              SizedBox(height: 12.h),
              _buildDivider(),
              SizedBox(height: 9.h),
              _buildCourseSection(),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: MColor.black100,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(width: 1.w, color: MColor.gray500),
        boxShadow: _cardShadow(),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '여행일정을 짜고 싶으신가요?',
              style: MTextStyles.bodyM.copyWith(color: MColor.gray200),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: MColor.primary500,
              border: Border.all(width: 1.w, color: MColor.gray200),
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: Image.asset(MImages.sendIcon, width: 25.w, height: 25.h),
          ),
        ],
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
      padding: EdgeInsets.only(bottom: 28.h, left: 20.w, top: 20.h),
      decoration: BoxDecoration(color: MColor.gray50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '안녕하세요 김모행님,',
            style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
          ),
          Text.rich(
            TextSpan(
              style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
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

  Widget _buildAiSection() {
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
            itemCount: 4,
            separatorBuilder: (_, __) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildDestinationCard(
                  title: '일본 도쿄',
                  subtitle:
                      '전통과 현대가 공존하는 일본의 수도. 시부야, 신주쿠, 아키하바라 등 다채로운 명소와 맛있는 스시, 라멘을 즐길 수 있는 도시',
                  imagePath: MImages.japan,
                );
              }
              return _buildDestinationCard(
                title: '미국 뉴욕',
                subtitle:
                    '잠들지 않는 도시. 자유의 여신상, 타임스퀘어, 센트럴파크 등 상징적인 명소와 브로드웨이 뮤지컬, 다양한 문화가 공존하는 대도시',
                imagePath: MImages.america,
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
    required String imagePath,
  }) {
    return Container(
      width: 155.w,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r)),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.asset(
              imagePath,
              fit: BoxFit.fill,
              width: 160.w,
              height: 194.h,
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

  Widget _buildCourseSection() {
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
        ),
        SizedBox(height: 12.h),
        Container(
          width: 1.sw,
          decoration: BoxDecoration(color: MColor.gray50),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildCourseCard(),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (i) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: _buildBar(isActive: i == currentIndex),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBar({required bool isActive, double? width, double? height}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      width: 24.w,
      height: 2.h,
      decoration: BoxDecoration(
        color: isActive ? MColor.gray500 : MColor.gray100,
      ),
    );
  }

  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
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
    );
  }

  Widget _buildCourseCard() {
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
                child: Image.asset(MImages.sibuya, width: 75.w, height: 75.h),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '시부야 밤거리',
                      style: MTextStyles.labelB.copyWith(color: MColor.gray800),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '1일 일정',
                      style: MTextStyles.labelM.copyWith(color: MColor.gray500),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        _buildTag('#힐링코스'),
                        SizedBox(width: 8.w),
                        _buildTag('#친구'),
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

  Widget _buildBlogSection() {
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
            _buildBlogFilterChip('최신순', isSelected: true),
            SizedBox(width: 8.w),
            _buildBlogFilterChip('인기순'),
          ],
        ),
        SizedBox(height: 16.h),
        _buildBlogItem(
          title: '시부야 깨끗한 첫 착용',
          description: '오늘은 친구들과 같이 시부야에서 밥기를 하러 가는 날이다. 친구와 머리합에 같이 ...',
          tags: const ['#당일치기', '#친구'],
          likeCount: 1002,
          imagePath: 'assets/images/country/sibuya.png',
        ),
        SizedBox(height: 12.h),
        _buildBlogItem(
          title: '시부야 깨끗한 첫 착용',
          description: '오늘은 친구들과 같이 시부야에서 밥기를 하러 가는 날이다. 친구와 머리합에 같이 ...',
          tags: const ['#당일치기', '#친구'],
          likeCount: 1002,
          imagePath: 'assets/images/country/sibuya.png',
        ),
        SizedBox(height: 12.h),
        _buildBlogItem(
          title: '시부야 깨끗한 첫 착용',
          description: '오늘은 친구들과 같이 시부야에서 밥기를 하러 가는 날이다. 친구와 머리합에 같이 ...',
          tags: const ['#당일치기', '#친구'],
          likeCount: 1002,
          imagePath: 'assets/images/country/sibuya.png',
        ),
      ],
    );
  }

  Widget _buildBlogItem({
    required String title,
    required String description,
    required List<String> tags,
    required int likeCount,
    required String imagePath,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: Image.asset(imagePath, width: 58.w, height: 58.w),
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
                SizedBox(height: 6.h),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    for (int i = 0; i < tags.length; i++) ...[
                      _buildBlogTag(tags[i]),
                      if (i != tags.length - 1) SizedBox(width: 6.w),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 14.w,
                    color: MColor.gray300,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    likeCount.toString(),
                    style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBlogFilterChip(String label, {bool isSelected = false}) {
    return Container(
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
      padding: EdgeInsets.all(4.w.h),
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
