import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';

class RoadmapResultScreen extends ConsumerWidget {
  const RoadmapResultScreen({super.key});

  static const LatLng _defaultCenter = LatLng(37.5665, 126.9780);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultState = ref.watch(roadmapItineraryResultViewModelProvider);
    final items = _buildScheduleItems(resultState.result?.data?.itinerary);

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
                itemCount: items.isEmpty ? 1 : items.length,
                separatorBuilder: (_, __) => SizedBox(height: 18.h),
                itemBuilder: (context, index) {
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Text(
                          '일정을 불러오는 중이거나\n표시할 일정이 없어요.',
                          textAlign: TextAlign.center,
                          style: MTextStyles.labelM.copyWith(
                            color: MColor.gray400,
                          ),
                        ),
                      ),
                    );
                  }
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

List<_ScheduleItem> _buildScheduleItems(
  List<RoadmapDailyItinerary>? itinerary,
) {
  if (itinerary == null || itinerary.isEmpty) {
    return const [];
  }

  final entries = <_ScheduleEntry>[];
  for (final daily in itinerary) {
    final dayNumber = daily.dayNumber ?? 0;
    final places = daily.places ?? const <RoadmapItineraryPlace>[];
    for (final place in places) {
      entries.add(
        _ScheduleEntry(
          dayNumber: dayNumber,
          sequence: place.visitSequence ?? 0,
          place: place,
        ),
      );
    }
  }

  entries.sort((a, b) {
    final byDay = a.dayNumber.compareTo(b.dayNumber);
    if (byDay != 0) return byDay;
    return a.sequence.compareTo(b.sequence);
  });

  var order = 1;
  return entries.map((entry) {
    final place = entry.place;
    return _ScheduleItem(
      order: order++,
      title: place.placeName ?? '방문 장소',
      time: _formatVisitTime(place.visitTime),
      description: place.description ?? place.address ?? '',
    );
  }).toList();
}

String _formatVisitTime(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  if (value is num) return value.toString();
  return value.toString();
}

class _ScheduleEntry {
  const _ScheduleEntry({
    required this.dayNumber,
    required this.sequence,
    required this.place,
  });

  final int dayNumber;
  final int sequence;
  final RoadmapItineraryPlace place;
}
