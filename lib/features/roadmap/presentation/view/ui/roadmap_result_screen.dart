import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class RoadmapResultScreen extends StatelessWidget {
  const RoadmapResultScreen({super.key});

  static const LatLng _defaultCenter = LatLng(37.5665, 126.9780);

  @override
  Widget build(BuildContext context) {
    final items = _dummySchedule;

    return MLayout(
      backgroundColor: MColor.white100,
      body: Column(
        children: [
          SizedBox(
            height: 440.h,
            width: double.infinity,
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _defaultCenter,
                zoom: 12.5,
              ),
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              markers: {
                const Marker(
                  markerId: MarkerId('start'),
                  position: _defaultCenter,
                  infoWindow: InfoWindow(title: '출발 위치'),
                ),
              },
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MColor.white100,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16.r,
                    offset: Offset(0, -6.h),
                  ),
                ],
              ),
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(20.w, 28.h, 20.w, 24.h),
                itemCount: items.length,
                separatorBuilder: (_, __) => SizedBox(height: 18.h),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return _ScheduleRow(
                    order: item.order,
                    title: item.title,
                    time: item.time,
                    description: item.description,
                    isLast: index == items.length - 1,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  const _ScheduleRow({
    required this.order,
    required this.title,
    required this.time,
    required this.description,
    required this.isLast,
  });

  final int order;
  final String title;
  final String time;
  final String description;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: MColor.primary500,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                '$order',
                style: MTextStyles.bodyB.copyWith(color: MColor.white100),
              ),
            ),
            if (!isLast)
              Container(
                margin: EdgeInsets.only(top: 10.h),
                width: 2.w,
                height: 30.h,
                decoration: BoxDecoration(
                  color: MColor.primary300,
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
          ],
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: MTextStyles.bodyB.copyWith(color: MColor.black100),
              ),
              SizedBox(height: 4.h),
              Text(
                time,
                style: MTextStyles.labelM.copyWith(color: MColor.gray400),
              ),
              SizedBox(height: 6.h),
              Text(
                description,
                style: MTextStyles.labelM.copyWith(color: MColor.gray600),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleItem {
  const _ScheduleItem({
    required this.order,
    required this.title,
    required this.time,
    required this.description,
  });

  final int order;
  final String title;
  final String time;
  final String description;
}

const _dummySchedule = <_ScheduleItem>[
  _ScheduleItem(
    order: 1,
    title: '호텔 조식',
    time: '08:00',
    description: '호텔 루프탑 레스토랑 뷔페',
  ),
  _ScheduleItem(
    order: 2,
    title: '해변 산책',
    time: '10:00',
    description: '오션뷰 산책로 따라 이동',
  ),
  _ScheduleItem(
    order: 3,
    title: '시티 투어',
    time: '12:30',
    description: '랜드마크 3곳 방문',
  ),
  _ScheduleItem(
    order: 4,
    title: '카페 휴식',
    time: '15:00',
    description: '현지 베이커리 카페',
  ),
  _ScheduleItem(
    order: 5,
    title: '야경 감상',
    time: '19:30',
    description: '전망대 야경 포인트',
  ),
];
