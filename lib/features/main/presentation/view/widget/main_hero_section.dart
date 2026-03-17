import 'package:flutter/material.dart';
import 'package:flutter_earth_globe/flutter_earth_globe.dart';
import 'package:flutter_earth_globe/flutter_earth_globe_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';

class MainHeroSection extends StatelessWidget {
  const MainHeroSection({
    super.key,
    required this.horizontalPadding,
    required this.globeController,
  });

  final double horizontalPadding;
  final FlutterEarthGlobeController globeController;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320.h,
      color: MColor.black100,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(top: 110.h, child: _buildGlobe(context)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              children: [
                SizedBox(height: 24.h),
                Text(
                  '지금 여행 일정을\n같이 계획해 볼까요?',
                  textAlign: TextAlign.center,
                  style: MTextStyles.lBodyM.copyWith(color: MColor.white100),
                ),
                SizedBox(height: 12.h),
                _buildSearchBar(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
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

  Widget _buildGlobe(BuildContext context) {
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
                  controller: globeController,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
