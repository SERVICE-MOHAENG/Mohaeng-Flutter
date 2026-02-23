import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';

class RoadmapResultScreen extends ConsumerStatefulWidget {
  const RoadmapResultScreen({super.key});

  @override
  ConsumerState<RoadmapResultScreen> createState() =>
      _RoadmapResultScreenState();
}

class _RoadmapResultScreenState extends ConsumerState<RoadmapResultScreen> {
  static const LatLng _defaultCenter = LatLng(37.5665, 126.9780);
  static const int _maxStatusPollingCount = 40;
  static const Duration _statusPollingInterval = Duration(seconds: 2);

  bool _isInitialized = false;
  bool _isPolling = false;
  bool _isPollingTimedOut = false;
  int _pollingAttempt = 0;
  String? _jobId;
  String? _lastKnownStatus;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    _isInitialized = true;

    _jobId = _resolveJobId();
    if (_jobId != null) {
      _logPolling('start polling with jobId=$_jobId');
      _scheduleInitialPolling();
    } else {
      _logPolling('cannot start polling: jobId is null');
    }
  }

  void _scheduleInitialPolling() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_loadRoadmapResult());
    });
  }

  String? _resolveJobId() {
    if (_jobId != null && _jobId!.trim().isNotEmpty) {
      return _jobId!.trim();
    }

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is String && args.trim().isNotEmpty) {
      return args.trim();
    }

    final itineraryJobId = ref
        .read(roadmapItineraryViewModelProvider)
        .response
        ?.jobId
        .trim();
    if (itineraryJobId != null && itineraryJobId.isNotEmpty) {
      return itineraryJobId;
    }

    final surveyJobId = ref
        .read(roadmapSurveyViewModelProvider)
        .response
        ?.jobId
        .trim();
    if (surveyJobId != null && surveyJobId.isNotEmpty) {
      return surveyJobId;
    }

    return null;
  }

  Future<void> _loadRoadmapResult() async {
    if (_isPolling) {
      _logPolling('skip polling: already in progress');
      return;
    }

    final jobId = _resolveJobId();
    if (jobId == null || jobId.isEmpty) {
      _logPolling('skip polling: resolved jobId is empty');
      return;
    }
    _jobId = jobId;

    final statusNotifier = ref.read(
      roadmapItineraryStatusViewModelProvider.notifier,
    );
    final resultNotifier = ref.read(
      roadmapItineraryResultViewModelProvider.notifier,
    );

    setState(() {
      _isPolling = true;
      _isPollingTimedOut = false;
      _pollingAttempt = 0;
    });
    _logPolling('polling started: jobId=$jobId');

    var reachedTerminalStatus = false;

    for (var attempt = 0; attempt < _maxStatusPollingCount; attempt++) {
      if (!mounted) return;

      setState(() {
        _pollingAttempt = attempt + 1;
      });

      final loaded = await statusNotifier.load(jobId);
      if (!mounted) return;
      if (!loaded) {
        final errorMessage = ref
            .read(roadmapItineraryStatusViewModelProvider)
            .errorMessage;
        _logPolling(
          'status load failed: attempt=${attempt + 1}/$_maxStatusPollingCount, error=$errorMessage',
        );
        setState(() => _isPolling = false);
        return;
      }

      final normalizedStatus =
          ref
              .read(roadmapItineraryStatusViewModelProvider)
              .status
              ?.status
              .trim()
              .toLowerCase() ??
          '';
      _logPolling(
        'status loaded: attempt=${attempt + 1}/$_maxStatusPollingCount, status=$normalizedStatus',
      );

      _lastKnownStatus = normalizedStatus;

      if (_isCompletedStatus(normalizedStatus)) {
        _logPolling('terminal status reached: completed');
        reachedTerminalStatus = true;
        break;
      }
      if (_isFailedStatus(normalizedStatus)) {
        _logPolling('terminal status reached: failed($normalizedStatus)');
        reachedTerminalStatus = true;
        setState(() => _isPolling = false);
        return;
      }

      await Future<void>.delayed(_statusPollingInterval);
    }

    if (!mounted) return;
    await resultNotifier.load(jobId);
    if (!mounted) return;

    final hasItinerary =
        (ref
                    .read(roadmapItineraryResultViewModelProvider)
                    .result
                    ?.data
                    ?.itinerary ??
                const <RoadmapDailyItinerary>[])
            .isNotEmpty;
    _logPolling(
      'result loaded: hasItinerary=$hasItinerary, reachedTerminalStatus=$reachedTerminalStatus',
    );

    setState(() {
      _isPolling = false;
      _isPollingTimedOut = !reachedTerminalStatus && !hasItinerary;
    });
    if (_isPollingTimedOut) {
      _logPolling('polling timed out');
    } else {
      _logPolling('polling finished');
    }
  }

  bool _isCompletedStatus(String status) {
    return status == 'completed' ||
        status == 'done' ||
        status == 'success' ||
        status == 'succeeded' ||
        status == 'finished';
  }

  bool _isFailedStatus(String status) {
    return status == 'failed' || status == 'error' || status == 'cancelled';
  }

  String _resolveEmptyMessage({
    required bool isLoading,
    required String? status,
    required String? statusError,
    required String? resultError,
  }) {
    if (resultError != null && resultError.trim().isNotEmpty) {
      return resultError;
    }
    if (statusError != null && statusError.trim().isNotEmpty) {
      return statusError;
    }
    if (_isPollingTimedOut) {
      return '로드맵 생성이 진행 중이에요.\n잠시 후 다시 조회해주세요.';
    }

    if (isLoading) {
      return '로드맵 생성 상태를 확인하고 있어요.\n($_pollingAttempt/$_maxStatusPollingCount)';
    }

    final normalizedStatus = status?.trim().toLowerCase();
    if (normalizedStatus != null && normalizedStatus.isNotEmpty) {
      if (_isFailedStatus(normalizedStatus)) {
        return '로드맵 생성에 실패했어요.\n다시 시도해주세요.';
      }
      if (!_isCompletedStatus(normalizedStatus)) {
        return '로드맵 생성 중이에요. ($status)';
      }
    }

    if (_jobId == null) {
      return '작업 ID가 없어 결과를 조회할 수 없어요.';
    }

    return '표시할 일정이 없어요.';
  }

  void _logPolling(String message) {
    if (!kDebugMode) return;
    debugPrint('[ROADMAP][POLLING] $message');
  }

  @override
  Widget build(BuildContext context) {
    final resultState = ref.watch(roadmapItineraryResultViewModelProvider);
    final statusState = ref.watch(roadmapItineraryStatusViewModelProvider);
    final items = _buildScheduleItems(resultState.result?.data?.itinerary);
    final isLoading =
        _isPolling || statusState.isLoading || resultState.isLoading;
    final status = statusState.status?.status ?? _lastKnownStatus;
    final emptyMessage = _resolveEmptyMessage(
      isLoading: isLoading,
      status: status,
      statusError: statusState.errorMessage,
      resultError: resultState.errorMessage,
    );

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
                separatorBuilder: (context, index) => SizedBox(height: 18.h),
                itemBuilder: (context, index) {
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isLoading)
                              Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            Text(
                              emptyMessage,
                              textAlign: TextAlign.center,
                              style: MTextStyles.labelM.copyWith(
                                color: MColor.gray400,
                              ),
                            ),
                            if (!isLoading && _jobId != null) ...[
                              SizedBox(height: 14.h),
                              OutlinedButton(
                                onPressed: _loadRoadmapResult,
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: MColor.primary500,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '다시 조회',
                                  style: MTextStyles.labelM.copyWith(
                                    color: MColor.primary500,
                                  ),
                                ),
                              ),
                            ],
                          ],
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
