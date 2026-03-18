import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';

class MainCourseRoadmapScreen extends StatefulWidget {
  const MainCourseRoadmapScreen({super.key, required this.course});

  final CourseResponse course;

  @override
  State<MainCourseRoadmapScreen> createState() =>
      _MainCourseRoadmapScreenState();
}

class _MainCourseRoadmapScreenState extends State<MainCourseRoadmapScreen> {
  static const LatLng _defaultCenter = LatLng(37.5665, 126.9780);

  GoogleMapController? _mapController;
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final displayCourse = widget.course;
    final dayPlans = _buildCourseDayPlans(displayCourse);
    final safeSelectedIndex = dayPlans.isEmpty
        ? 0
        : _selectedDayIndex.clamp(0, dayPlans.length - 1);
    final selectedDay = dayPlans.isEmpty ? null : dayPlans[safeSelectedIndex];
    final selectedPlaces = selectedDay?.places ?? const <CoursePlaceResponse>[];
    final timelineItems = _buildCourseTimelineItems(selectedPlaces);
    final markers = _buildMapMarkers(selectedPlaces);
    final polylines = _buildMapPolylines(selectedPlaces);
    final mapCenter = _resolveMapCenter(selectedPlaces);
    final bottomPadding = MediaQuery.paddingOf(context).bottom + 24.h;

    return MLayout(
      backgroundColor: MColor.gray50,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _CourseRoadmapMapSection(
              course: displayCourse,
              center: mapCenter,
              markers: markers,
              polylines: polylines,
              mapKey:
                  'course_map_${displayCourse.id ?? displayCourse.title ?? 'unknown'}_$safeSelectedIndex',
              onMapCreated: (controller) {
                _mapController = controller;
                _focusMapOnPlaces(selectedPlaces, animate: false);
              },
            ),
            Expanded(
              child: ColoredBox(
                color: MColor.white100,
                child: Column(
                  children: [
                    SizedBox(height: 16.h),
                    if (dayPlans.length > 1)
                      _CourseDayTabs(
                        dayPlans: dayPlans,
                        selectedIndex: safeSelectedIndex,
                        onChanged: (index) => _onDayChanged(index, dayPlans),
                      )
                    else
                      SizedBox(height: 58.h),
                    SizedBox(height: 16.h),
                    if (dayPlans.length > 1)
                      _PageDots(
                        count: dayPlans.length,
                        selectedIndex: safeSelectedIndex,
                      )
                    else
                      SizedBox(height: 2.h),
                    SizedBox(height: 20.h),
                    _CoursePanelHeader(
                      title: dayPlans.length > 1
                          ? 'Day ${selectedDay?.dayNumber ?? safeSelectedIndex + 1} 로드맵'
                          : '로드맵',
                      subtitle: _buildPanelSubtitle(
                        date: selectedDay?.date,
                        placeCount: selectedPlaces.length,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Expanded(
                      child: _CourseTimelinePanel(
                        timelineItems: timelineItems,
                        emptyMessage: '등록된 장소 정보가 없어요.',
                        bottomPadding: bottomPadding,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onDayChanged(int index, List<_CourseDayPlan> dayPlans) {
    if (_selectedDayIndex == index) return;
    setState(() {
      _selectedDayIndex = index;
    });
    _focusMapOnPlaces(dayPlans[index].places);
  }

  Future<void> _focusMapOnPlaces(
    List<CoursePlaceResponse> places, {
    bool animate = true,
  }) async {
    final controller = _mapController;
    if (controller == null) return;

    final coordinates = places
        .map(_resolvePlaceLatLng)
        .whereType<LatLng>()
        .toList(growable: false);
    if (coordinates.isEmpty) return;

    final update = _cameraUpdateForCoordinates(coordinates);
    if (update == null) return;

    try {
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
    } catch (_) {
      // Ignore camera sync errors from unmounted or not-yet-ready maps.
    }
  }
}

class _CourseRoadmapMapSection extends StatelessWidget {
  const _CourseRoadmapMapSection({
    required this.course,
    required this.center,
    required this.markers,
    required this.polylines,
    required this.mapKey,
    required this.onMapCreated,
  });

  final CourseResponse course;
  final LatLng center;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final String mapKey;
  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  Widget build(BuildContext context) {
    final title = _resolveCourseRoadmapTitle(course);
    final tripMeta = _buildTripMeta(course);
    final summary = _resolveCourseRoadmapSummary(course);
    final tags = _resolveCourseRoadmapTags(course.tags);
    final topInset = MediaQuery.paddingOf(context).top;

    return SizedBox(
      height: 417.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: GoogleMap(
              key: ValueKey(mapKey),
              initialCameraPosition: CameraPosition(target: center, zoom: 12.5),
              onMapCreated: onMapCreated,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              zoomControlsEnabled: false,
              markers: markers,
              polylines: polylines,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(color: const Color(0x33262626)),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.22),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.48, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16.w,
            top: topInset + 2.h,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).maybePop(),
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.sp,
                    color: MColor.gray900,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topInset + 40.h,
            left: 16.w,
            right: 16.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _OverlayChip(
                      text: title,
                      textColor: MColor.gray800,
                      horizontalPadding: 12.w,
                      verticalPadding: 7.h,
                      maxWidth: 172.w,
                    ),
                    if (tripMeta.isNotEmpty)
                      _OverlayChip(
                        text: tripMeta,
                        textColor: MColor.gray600,
                        horizontalPadding: 10.w,
                        verticalPadding: 6.h,
                        maxWidth: 170.w,
                        textStyle: MTextStyles.sLabelM.copyWith(
                          fontSize: 8.sp,
                          height: 1.2,
                          color: MColor.gray600,
                        ),
                      ),
                  ],
                ),
                if (summary != null || tags.isNotEmpty) SizedBox(height: 8.h),
                if (summary != null || tags.isNotEmpty)
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      if (summary != null)
                        _OverlayChip(
                          text: summary,
                          textColor: MColor.gray600,
                          horizontalPadding: 10.w,
                          verticalPadding: 6.h,
                          maxWidth: 226.w,
                          textStyle: MTextStyles.sLabelM.copyWith(
                            fontSize: 8.sp,
                            height: 1.2,
                            color: MColor.gray600,
                          ),
                        ),
                      for (final tag in tags.take(2)) _HashTagChip(text: tag),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayChip extends StatelessWidget {
  const _OverlayChip({
    required this.text,
    required this.textColor,
    required this.horizontalPadding,
    required this.verticalPadding,
    this.maxWidth,
    this.textStyle,
  });

  final String text;
  final Color textColor;
  final double horizontalPadding;
  final double verticalPadding;
  final double? maxWidth;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(4999.r);
    return Container(
      constraints: maxWidth == null
          ? null
          : BoxConstraints(maxWidth: maxWidth!),
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 7.5.r,
            offset: Offset(0, 5.h),
            spreadRadius: -1.5,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 3.r,
            offset: Offset(0, 2.h),
            spreadRadius: -2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            color: MColor.white100.withValues(alpha: 0.9),
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  textStyle ??
                  MTextStyles.sLabelM.copyWith(color: textColor, height: 1.2),
            ),
          ),
        ),
      ),
    );
  }
}

class _HashTagChip extends StatelessWidget {
  const _HashTagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(7499.25.r);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 11.25.r,
            offset: Offset(0, 7.5.h),
            spreadRadius: -2.25,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4.5.r,
            offset: Offset(0, 3.h),
            spreadRadius: -3,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 6.h),
            color: MColor.primary500,
            child: Text(
              text,
              style: MTextStyles.sLabelM.copyWith(
                fontSize: 9.sp,
                height: 1.2,
                color: MColor.white100,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CourseDayTabs extends StatelessWidget {
  const _CourseDayTabs({
    required this.dayPlans,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<_CourseDayPlan> dayPlans;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Container(
        width: double.infinity,
        height: 58.h,
        decoration: BoxDecoration(
          color: MColor.white100.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(11.833.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 36.978.r,
              spreadRadius: -8.875,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11.833.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 4.437, sigmaY: 4.437),
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Row(
                children: [
                  for (int i = 0; i < dayPlans.length; i++) ...[
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onChanged(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: i == selectedIndex
                                ? MColor.primary500
                                : MColor.gray50,
                            borderRadius: BorderRadius.circular(8.875.r),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Day ${dayPlans[i].dayNumber}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: MTextStyles.sLabelM.copyWith(
                                  color: i == selectedIndex
                                      ? MColor.white100.withValues(alpha: 0.75)
                                      : MColor.gray400.withValues(alpha: 0.75),
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                _formatDateWithWeekday(dayPlans[i].date),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: MTextStyles.sLabelM.copyWith(
                                  color: i == selectedIndex
                                      ? MColor.white100
                                      : MColor.gray600,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (i != dayPlans.length - 1) SizedBox(width: 8.w),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.selectedIndex});

  final int count;
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < count; i++) ...[
          Container(
            width: 24.w,
            height: 2.h,
            decoration: BoxDecoration(
              color: i == selectedIndex ? MColor.gray500 : MColor.gray100,
            ),
          ),
          if (i != count - 1) SizedBox(width: 7.w),
        ],
      ],
    );
  }
}

class _CoursePanelHeader extends StatelessWidget {
  const _CoursePanelHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: MTextStyles.labelB.copyWith(color: MColor.gray900),
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: MTextStyles.sLabelM.copyWith(color: MColor.gray400),
            ),
        ],
      ),
    );
  }
}

class _CourseTimelinePanel extends StatelessWidget {
  const _CourseTimelinePanel({
    required this.timelineItems,
    required this.emptyMessage,
    required this.bottomPadding,
  });

  final List<_CourseTimelineItem> timelineItems;
  final String emptyMessage;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    if (timelineItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, bottomPadding),
        child: Center(
          child: Text(
            emptyMessage,
            textAlign: TextAlign.center,
            style: MTextStyles.labelM.copyWith(color: MColor.gray400),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 4.h, bottom: bottomPadding),
      itemCount: timelineItems.length,
      itemBuilder: (context, index) {
        final item = timelineItems[index];
        return _CourseTimelineRow(
          item: item,
          isLast: index == timelineItems.length - 1,
        );
      },
    );
  }
}

class _CourseTimelineRow extends StatelessWidget {
  const _CourseTimelineRow({required this.item, required this.isLast});

  final _CourseTimelineItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88.h,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 48.w,
              child: Column(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: MColor.primary500,
                      borderRadius: BorderRadius.circular(13.952.r),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFFBFDBFE),
                          blurRadius: 5.232,
                          spreadRadius: -0.872,
                          offset: Offset(0, 3.488),
                        ),
                        BoxShadow(
                          color: Color(0xFFBFDBFE),
                          blurRadius: 3.488,
                          spreadRadius: -1.744,
                          offset: Offset(0, 1.744),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${item.order}',
                      style: MTextStyles.bodyB.copyWith(
                        color: MColor.white100,
                        fontSize: 17.44.sp,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (!isLast) ...[
                    SizedBox(height: 5.h),
                    Container(
                      width: 1.744.w,
                      height: 20.928.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999.r),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [MColor.primary500, MColor.primary100],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 14.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 1.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MTextStyles.labelB.copyWith(
                        color: MColor.gray800,
                        height: 1,
                      ),
                    ),
                    if (item.time.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        item.time,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MTextStyles.labelM.copyWith(
                          color: MColor.gray300,
                          height: 1.33,
                        ),
                      ),
                    ],
                    if (item.description.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        item.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MTextStyles.labelM.copyWith(
                          color: MColor.gray800,
                          height: 1.33,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CourseDayPlan {
  const _CourseDayPlan({
    required this.dayNumber,
    required this.date,
    required this.places,
  });

  final int dayNumber;
  final DateTime? date;
  final List<CoursePlaceResponse> places;
}

class _CourseTimelineItem {
  const _CourseTimelineItem({
    required this.id,
    required this.order,
    required this.title,
    required this.time,
    required this.description,
  });

  final String id;
  final int order;
  final String title;
  final String time;
  final String description;
}

List<_CourseDayPlan> _buildCourseDayPlans(CourseResponse course) {
  final sortedPlaces = _sortCoursePlaces(course.places);
  if (sortedPlaces.isEmpty) {
    return const <_CourseDayPlan>[];
  }

  final dayNumbers = sortedPlaces
      .map((place) => place.dayNumber)
      .whereType<int>()
      .where((dayNumber) => dayNumber > 0)
      .toSet();
  if (dayNumbers.isNotEmpty) {
    final grouped = <int, List<CoursePlaceResponse>>{};
    for (final place in sortedPlaces) {
      final dayNumber = place.dayNumber ?? 1;
      grouped.putIfAbsent(dayNumber, () => <CoursePlaceResponse>[]).add(place);
    }

    final entries = grouped.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));

    return [
      for (final entry in entries)
        _CourseDayPlan(
          dayNumber: entry.key,
          date: _parseVisitedDate(entry.value.first.visitedAt),
          places: entry.value,
        ),
    ];
  }

  final parsedDates = sortedPlaces
      .map((place) => _parseVisitedDate(place.visitedAt))
      .toList(growable: false);
  final hasCompleteDateInfo = parsedDates.every((date) => date != null);
  final distinctDates = hasCompleteDateInfo
      ? parsedDates
            .whereType<DateTime>()
            .map((date) => DateTime(date.year, date.month, date.day))
            .toSet()
      : const <DateTime>{};

  if (hasCompleteDateInfo && distinctDates.length > 1) {
    final grouped = <DateTime, List<CoursePlaceResponse>>{};
    for (int i = 0; i < sortedPlaces.length; i++) {
      final date = parsedDates[i]!;
      final key = DateTime(date.year, date.month, date.day);
      grouped
          .putIfAbsent(key, () => <CoursePlaceResponse>[])
          .add(sortedPlaces[i]);
    }

    final entries = grouped.entries.toList()
      ..sort((left, right) => left.key.compareTo(right.key));

    return [
      for (int i = 0; i < entries.length; i++)
        _CourseDayPlan(
          dayNumber: i + 1,
          date: entries[i].key,
          places: entries[i].value,
        ),
    ];
  }

  final date = _parseVisitedDate(sortedPlaces.first.visitedAt);
  return [_CourseDayPlan(dayNumber: 1, date: date, places: sortedPlaces)];
}

List<CoursePlaceResponse> _sortCoursePlaces(List<CoursePlaceResponse> places) {
  final indexed = places.indexed.toList(growable: false);
  indexed.sort((left, right) {
    final byDayNumber = (left.$2.dayNumber ?? 1 << 20).compareTo(
      right.$2.dayNumber ?? 1 << 20,
    );
    if (byDayNumber != 0) return byDayNumber;

    final byOrder = (left.$2.order ?? 1 << 20).compareTo(
      right.$2.order ?? 1 << 20,
    );
    if (byOrder != 0) return byOrder;

    final leftVisited = _parseVisitedDate(left.$2.visitedAt);
    final rightVisited = _parseVisitedDate(right.$2.visitedAt);
    if (leftVisited != null && rightVisited != null) {
      final byVisited = leftVisited.compareTo(rightVisited);
      if (byVisited != 0) return byVisited;
    }

    return left.$1.compareTo(right.$1);
  });

  return indexed.map((entry) => entry.$2).toList(growable: false);
}

List<_CourseTimelineItem> _buildCourseTimelineItems(
  List<CoursePlaceResponse> places,
) {
  if (places.isEmpty) return const <_CourseTimelineItem>[];

  return [
    for (int i = 0; i < places.length; i++)
      _CourseTimelineItem(
        id: 'course_timeline:${places[i].placeId ?? places[i].id ?? i}:${places[i].name ?? ''}:${places[i].visitedAt ?? ''}',
        order: i + 1,
        title: (places[i].name ?? '').trim().isEmpty
            ? '방문 장소'
            : places[i].name!.trim(),
        time: _formatVisitedTime(places[i].visitedAt),
        description: (places[i].address ?? '').trim(),
      ),
  ];
}

Set<Marker> _buildMapMarkers(List<CoursePlaceResponse> places) {
  final markers = <Marker>{};
  for (int i = 0; i < places.length; i++) {
    final coordinate = _resolvePlaceLatLng(places[i]);
    if (coordinate == null) continue;

    markers.add(
      Marker(
        markerId: MarkerId(
          'course_place_${places[i].placeId ?? places[i].id ?? i}',
        ),
        position: coordinate,
        infoWindow: InfoWindow(
          title: (places[i].name ?? '').trim().isEmpty
              ? '방문 장소'
              : places[i].name!.trim(),
          snippet: _formatVisitedTime(places[i].visitedAt),
        ),
      ),
    );
  }

  if (markers.isNotEmpty) return markers;

  return {
    const Marker(
      markerId: MarkerId('default'),
      position: _MainCourseRoadmapScreenState._defaultCenter,
      infoWindow: InfoWindow(title: '여행 코스'),
    ),
  };
}

Set<Polyline> _buildMapPolylines(List<CoursePlaceResponse> places) {
  final points = places
      .map(_resolvePlaceLatLng)
      .whereType<LatLng>()
      .toList(growable: false);
  if (points.length < 2) return const <Polyline>{};

  return {
    Polyline(
      polylineId: const PolylineId('course_route'),
      points: points,
      color: MColor.primary500.withValues(alpha: 0.88),
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    ),
  };
}

LatLng _resolveMapCenter(List<CoursePlaceResponse> places) {
  for (final place in places) {
    final coordinate = _resolvePlaceLatLng(place);
    if (coordinate != null) return coordinate;
  }
  return _MainCourseRoadmapScreenState._defaultCenter;
}

LatLng? _resolvePlaceLatLng(CoursePlaceResponse place) {
  final latitude = place.latitude;
  final longitude = place.longitude;
  if (latitude == null || longitude == null) return null;
  if (latitude < -90 || latitude > 90) return null;
  if (longitude < -180 || longitude > 180) return null;
  return LatLng(latitude, longitude);
}

CameraUpdate? _cameraUpdateForCoordinates(List<LatLng> coordinates) {
  if (coordinates.isEmpty) return null;
  if (coordinates.length == 1 || _allCoordinatesMatch(coordinates)) {
    return CameraUpdate.newCameraPosition(
      CameraPosition(target: coordinates.first, zoom: 12.5),
    );
  }

  final latitudes = coordinates.map((point) => point.latitude);
  final longitudes = coordinates.map((point) => point.longitude);
  final south = latitudes.reduce((left, right) => left < right ? left : right);
  final north = latitudes.reduce((left, right) => left > right ? left : right);
  final west = longitudes.reduce((left, right) => left < right ? left : right);
  final east = longitudes.reduce((left, right) => left > right ? left : right);

  return CameraUpdate.newLatLngBounds(
    LatLngBounds(
      southwest: LatLng(south, west),
      northeast: LatLng(north, east),
    ),
    56,
  );
}

bool _allCoordinatesMatch(List<LatLng> coordinates) {
  final first = coordinates.first;
  for (final coordinate in coordinates.skip(1)) {
    if (coordinate.latitude != first.latitude ||
        coordinate.longitude != first.longitude) {
      return false;
    }
  }
  return true;
}

String _resolveCourseRoadmapTitle(CourseResponse course) {
  final title = (course.title ?? '').trim();
  if (title.isNotEmpty) return title;

  final regionName = course.regionNames.firstWhere(
    (region) => region.trim().isNotEmpty,
    orElse: () => '',
  );
  if (regionName.isNotEmpty) {
    return '$regionName 코스';
  }

  for (final place in course.places) {
    final name = (place.name ?? '').trim();
    if (name.isNotEmpty) {
      return '$name 중심 코스';
    }
  }

  return '${_countryLabel(course.countryCode)} 인기 코스';
}

String _buildTripMeta(CourseResponse course) {
  final parts = <String>[];
  final country = _resolveCountryDisplayLabel(course);
  if (country.isNotEmpty && country != '여행') {
    parts.add(country);
  }

  final nights = course.nights;
  final days = course.days;
  if (nights != null && nights >= 0 && days != null && days > 0) {
    parts.add('$nights박 $days일');
  } else if (days != null && days > 0) {
    parts.add('$days일 코스');
  }

  if (course.places.isNotEmpty) {
    parts.add('스팟 ${course.places.length}');
  }

  return parts.join(' · ');
}

String? _resolveCourseRoadmapSummary(CourseResponse course) {
  final description = (course.description ?? '').trim();
  if (description.isNotEmpty) {
    return description;
  }

  final placeNames = course.places
      .map((place) => (place.name ?? '').trim())
      .where((name) => name.isNotEmpty)
      .take(3)
      .toList(growable: false);
  if (placeNames.isNotEmpty) {
    return '${placeNames.join(', ')} 중심으로 짜여진 인기 여행 코스';
  }

  final tagNames = _resolveCourseRoadmapTags(course.tags);
  if (tagNames.isNotEmpty) {
    return '${tagNames.take(2).join(' · ')} 테마 코스';
  }

  return null;
}

List<String> _resolveCourseRoadmapTags(List<String> tags) {
  return tags
      .map((tag) => tag.trim())
      .where((tag) => tag.isNotEmpty)
      .map((tag) => tag.startsWith('#') ? tag : '#$tag')
      .toList(growable: false);
}

String _buildPanelSubtitle({required DateTime? date, required int placeCount}) {
  final parts = <String>[];
  if (date != null) {
    parts.add(_formatDateWithWeekday(date));
  }
  if (placeCount > 0) {
    parts.add('$placeCount개의 장소');
  }
  return parts.join(' · ');
}

DateTime? _parseVisitedDate(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return null;
  return DateTime.tryParse(normalized);
}

String _formatVisitedTime(String? value) {
  final normalized = value?.trim();
  if (normalized == null || normalized.isEmpty) return '';

  final parsed = DateTime.tryParse(normalized);
  if (parsed != null) {
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(normalized);
  if (match != null) {
    final hour = (int.tryParse(match.group(1) ?? '') ?? 0).toString().padLeft(
      2,
      '0',
    );
    final minute = match.group(2) ?? '00';
    return '$hour:$minute';
  }

  return normalized;
}

String _countryLabel(String? countryCode) {
  return switch ((countryCode ?? '').trim().toUpperCase()) {
    'JP' => '일본',
    'US' => '미국',
    'FR' => '프랑스',
    'EG' => '이집트',
    'DE' => '독일',
    _ => '여행',
  };
}

String _resolveCountryDisplayLabel(CourseResponse course) {
  final countries = course.countries
      .map((country) => country.trim())
      .where((country) => country.isNotEmpty)
      .toList(growable: false);
  if (countries.isNotEmpty) {
    return countries.first;
  }

  return _countryLabel(course.countryCode);
}

String _formatYmd(DateTime date) {
  final year = date.year.toString().padLeft(4, '0');
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$year.$month.$day';
}

String _formatDateWithWeekday(DateTime? date) {
  if (date == null) return '-';
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${_formatYmd(date)} (${weekdays[date.weekday - 1]})';
}
