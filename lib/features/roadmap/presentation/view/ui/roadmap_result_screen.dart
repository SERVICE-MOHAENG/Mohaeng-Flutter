import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_itinerary_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_modification_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';

class RoadmapResultScreen extends ConsumerStatefulWidget {
  const RoadmapResultScreen({super.key});

  @override
  ConsumerState<RoadmapResultScreen> createState() =>
      _RoadmapResultScreenState();
}

class _RoadmapResultScreenState extends ConsumerState<RoadmapResultScreen> {
  static const LatLng _defaultCenter = LatLng(37.5665, 126.9780);
  static const Duration _resultPollingInterval = Duration(seconds: 30);
  static const Duration _modificationPollingInterval = Duration(seconds: 30);
  static const double _inputSheetBodySpacing = 86;

  bool _isInitialized = false;
  bool _isRefreshing = false;
  bool _isModificationPolling = false;
  bool _hasShownSuccessMessage = false;
  Timer? _resultPollingTimer;
  Timer? _modificationPollingTimer;
  Timer? _dotAnimationTimer;
  String? _jobId;
  String? _modificationJobId;
  String? _lastResultStatus;
  int _dotCount = 1;
  int _selectedDayIndex = 0;
  final Map<String, List<String>> _dayPlaceOrderCache =
      <String, List<String>>{};
  late final TextEditingController _requestInputController;

  @override
  void initState() {
    super.initState();
    _requestInputController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialized) return;
    _isInitialized = true;

    _jobId = _resolveJobId();
    if (_jobId != null) {
      _logResult('initial fetch with jobId=$_jobId');
      _scheduleInitialFetch();
    } else {
      _logResult('cannot fetch: jobId is null');
    }
  }

  void _scheduleInitialFetch() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startDotAnimation();
      _startResultPolling();
      unawaited(_fetchRoadmapResult(isManualRefresh: false));
    });
  }

  @override
  void dispose() {
    _requestInputController.dispose();
    _stopModificationPolling();
    _stopDotAnimation();
    _stopResultPolling();
    super.dispose();
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

  void _startResultPolling() {
    _resultPollingTimer?.cancel();
    _resultPollingTimer = Timer.periodic(_resultPollingInterval, (_) {
      if (!mounted) return;
      _logResult(
        'result polling tick: interval=${_resultPollingInterval.inSeconds}s, jobId=${_jobId ?? 'null'}',
      );
      unawaited(_fetchRoadmapResult(isManualRefresh: false));
    });
    _logResult('result polling started: interval=30s');
  }

  void _stopResultPolling() {
    _resultPollingTimer?.cancel();
    _resultPollingTimer = null;
    _logResult('result polling stopped');
  }

  void _startModificationPolling(String jobId) {
    final normalized = jobId.trim();
    if (normalized.isEmpty) return;

    _modificationPollingTimer?.cancel();
    _modificationJobId = normalized;
    setState(() {
      _isModificationPolling = true;
    });
    _modificationPollingTimer = Timer.periodic(_modificationPollingInterval, (
      _,
    ) {
      if (!mounted) return;
      _logResult(
        'modification polling tick: interval=${_modificationPollingInterval.inSeconds}s, jobId=$_modificationJobId',
      );
      unawaited(_pollModificationStatus());
    });
    _logResult('modification polling started: jobId=$normalized');
    unawaited(_pollModificationStatus());
  }

  void _stopModificationPolling() {
    _modificationPollingTimer?.cancel();
    _modificationPollingTimer = null;
    _modificationJobId = null;
    if (mounted) {
      setState(() {
        _isModificationPolling = false;
      });
    } else {
      _isModificationPolling = false;
    }
    _logResult('modification polling stopped');
  }

  void _startDotAnimation() {
    _dotAnimationTimer?.cancel();
    _dotAnimationTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() {
        _dotCount = _dotCount >= 3 ? 1 : _dotCount + 1;
      });
    });
  }

  void _stopDotAnimation() {
    _dotAnimationTimer?.cancel();
    _dotAnimationTimer = null;
  }

  Future<void> _fetchRoadmapResult({required bool isManualRefresh}) async {
    if (_isRefreshing) {
      _logResult('skip fetch: already in progress');
      return;
    }

    final jobId = _resolveJobId();
    if (jobId == null || jobId.isEmpty) {
      _logResult('skip fetch: resolved jobId is empty');
      return;
    }
    if (_jobId != null && _jobId != jobId) {
      _dayPlaceOrderCache.clear();
    }
    _jobId = jobId;

    final resultNotifier = ref.read(
      roadmapItineraryResultViewModelProvider.notifier,
    );

    setState(() {
      _isRefreshing = true;
    });
    _logResult('fetch started: jobId=$jobId, isManualRefresh=$isManualRefresh');

    if (!mounted) return;
    await resultNotifier.load(jobId);
    if (!mounted) return;

    final resultState = ref.read(roadmapItineraryResultViewModelProvider);
    _lastResultStatus = resultState.result?.status;
    _logResult(
      'fetch finished: status=${_lastResultStatus ?? 'null'}, error=${resultState.errorMessage}',
    );
    _handleResultStatus(status: _lastResultStatus);

    setState(() {
      _isRefreshing = false;
    });
  }

  void _handleResultStatus({required String? status}) {
    final normalizedStatus = status?.trim().toLowerCase();
    if (normalizedStatus == null || normalizedStatus.isEmpty) return;

    if (_isSuccessStatus(normalizedStatus)) {
      _stopResultPolling();
      _stopDotAnimation();
      if (!_hasShownSuccessMessage && mounted) {
        _hasShownSuccessMessage = true;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('로드맵 생성 완료하였습니다.')));
      }
      return;
    }

    if (_isFailedStatus(normalizedStatus)) {
      _stopResultPolling();
      _stopDotAnimation();
    }
  }

  bool _isSuccessStatus(String status) {
    return status == 'success' ||
        status == 'completed' ||
        status == 'succeeded' ||
        status == 'done';
  }

  bool _isFailedStatus(String status) {
    return status == 'failed' ||
        status == 'timeout' ||
        status == 'error' ||
        status == 'cancelled';
  }

  String _resolveEmptyMessage({
    required bool isLoading,
    required String? resultStatus,
  }) {
    if (isLoading) {
      return _buildingMessage();
    }

    final normalizedStatus = resultStatus?.trim().toLowerCase();
    if (normalizedStatus != null && normalizedStatus.isNotEmpty) {
      if (_isSuccessStatus(normalizedStatus)) {
        return '일정 데이터를 불러오지 못했어요.';
      }
      if (_isFailedStatus(normalizedStatus)) {
        return '시간초과 되었습니다.';
      }
      return _buildingMessage();
    }

    if (_jobId == null) {
      return '작업 ID가 없어 결과를 조회할 수 없어요.';
    }

    return _buildingMessage();
  }

  String _buildingMessage() => '생성중${'.' * _dotCount}';

  void _goToHome() {
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.root, (_) => false);
  }

  void _logResult(String message) {
    final line = '[ROADMAP][RESULT] $message';
    debugPrint(line);
    developer.log(line, name: 'ROADMAP');
  }

  String? _resolveItineraryIdForChat(RoadmapItineraryResultResponse? result) {
    final travelCourseId = result?.travelCourseId?.trim();
    if (travelCourseId != null && travelCourseId.isNotEmpty) {
      return travelCourseId;
    }

    final fallback = _jobId?.trim();
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }

    return null;
  }

  Future<void> _pollModificationStatus() async {
    final jobId = _modificationJobId?.trim();
    if (jobId == null || jobId.isEmpty) return;

    final loaded = await ref
        .read(roadmapModificationStatusViewModelProvider.notifier)
        .load(jobId);

    if (!mounted) return;
    if (!loaded) {
      _logResult('modification polling load failed: jobId=$jobId');
      return;
    }

    final statusState = ref.read(roadmapModificationStatusViewModelProvider);
    final status = statusState.status?.status.trim().toLowerCase();
    final intent = statusState.status?.intentStatus?.trim().toLowerCase();
    _logResult('modification polling status=$status, intent=$intent');

    if (status == null || status.isEmpty) return;

    if (_isSuccessStatus(status)) {
      _stopModificationPolling();

      final nextTravelCourseId = _extractTravelCourseId(statusState.status);
      if (nextTravelCourseId != null && nextTravelCourseId.isNotEmpty) {
        if (_jobId != nextTravelCourseId) {
          _dayPlaceOrderCache.clear();
        }
        _jobId = nextTravelCourseId;
      }

      final successMessage =
          _extractStatusMessage(statusState.status?.message) ??
          '로드맵 수정이 반영되었습니다.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(successMessage)));

      await _fetchRoadmapResult(isManualRefresh: true);
      return;
    }

    if (_isFailedStatus(status)) {
      _stopModificationPolling();

      final failureMessage =
          _extractStatusMessage(statusState.status?.errorMessage) ??
          '로드맵 수정 작업이 실패했습니다.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failureMessage)));
    }
  }

  String? _extractTravelCourseId(RoadmapModificationStatusResponse? status) {
    final value = status?.travelCourseId;
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    if (value is Map) {
      for (final entry in value.entries) {
        final raw = entry.value;
        if (raw is String && raw.trim().isNotEmpty) {
          return raw.trim();
        }
      }
    }
    return null;
  }

  String? _extractStatusMessage(Object? value) {
    if (value == null) return null;
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
    if (value is num || value is bool) {
      return value.toString();
    }
    if (value is Map) {
      for (final key in const ['message', 'detail', 'reason']) {
        final raw = value[key];
        if (raw is String && raw.trim().isNotEmpty) {
          return raw.trim();
        }
      }
    }
    return null;
  }

  Future<void> _submitRoadmapModification() async {
    final chatState = ref.read(roadmapChatViewModelProvider);
    if (chatState.isLoading || _isModificationPolling) return;

    final message = _requestInputController.text.trim();
    if (message.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('수정 요청 내용을 입력해주세요.')));
      return;
    }

    final result = ref.read(roadmapItineraryResultViewModelProvider).result;
    final itineraryId = _resolveItineraryIdForChat(result);
    if (itineraryId == null || itineraryId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로드맵 ID를 확인하지 못했어요.')));
      return;
    }

    final isSuccess = await ref
        .read(roadmapChatViewModelProvider.notifier)
        .submit(itineraryId: itineraryId, message: message);

    if (!mounted) return;

    if (!isSuccess) {
      final errorMessage =
          ref.read(roadmapChatViewModelProvider).errorMessage ??
          '로드맵 수정 요청을 전송하지 못했어요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    final response = ref.read(roadmapChatViewModelProvider).response;
    final successMessage = response?.message.trim();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          successMessage != null && successMessage.isNotEmpty
              ? successMessage
              : '로드맵 수정 요청을 전송했어요.',
        ),
      ),
    );
    _requestInputController.clear();
    FocusScope.of(context).unfocus();

    final modificationJobId = response?.jobId.trim();
    if (modificationJobId != null && modificationJobId.isNotEmpty) {
      _startModificationPolling(modificationJobId);
    }
  }

  Widget _buildRequestBottomSheet(
    BuildContext context, {
    required bool isSending,
  }) {
    final viewInsetsBottom = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: viewInsetsBottom),
      child: Container(
        color: MColor.white100,
        padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 10.h + safeBottom),
        child: Container(
          height: 44.h,
          decoration: BoxDecoration(
            color: const Color(0xFFEDEEF2),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _requestInputController,
                  enabled: !isSending,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (isSending) return;
                    _submitRoadmapModification();
                  },
                  style: MTextStyles.labelM.copyWith(color: MColor.gray700),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                    hintText: '원하는 일정 수정 내용을 입력해주세요.',
                    hintStyle: MTextStyles.labelM.copyWith(
                      color: MColor.gray300,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 6.w),
                child: Material(
                  color: isSending ? MColor.gray200 : MColor.primary500,
                  borderRadius: BorderRadius.circular(9.r),
                  child: InkWell(
                    onTap: isSending ? null : _submitRoadmapModification,
                    borderRadius: BorderRadius.circular(9.r),
                    child: SizedBox(
                      width: 32.w,
                      height: 32.w,
                      child: Center(
                        child: isSending
                            ? SizedBox(
                                width: 14.w,
                                height: 14.w,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                Icons.arrow_upward_rounded,
                                size: 18.sp,
                                color: MColor.white100,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _syncSelectedDayIndex(int dayCount) {
    final nextIndex = switch (dayCount) {
      <= 0 => 0,
      _ => _selectedDayIndex.clamp(0, dayCount - 1),
    };
    if (nextIndex == _selectedDayIndex) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _selectedDayIndex = nextIndex);
    });
  }

  String _dayOrderKey(_DayPlan dayPlan) {
    final day = dayPlan.dayNumber;
    final date = dayPlan.date?.toIso8601String() ?? 'none';
    return '$day:$date';
  }

  String _placeOrderKey(RoadmapItineraryPlace place, int index) {
    final placeId = place.placeId?.trim() ?? '';
    final name = place.placeName?.trim() ?? '';
    final address = place.address?.trim() ?? '';
    final visitTime = _formatVisitTime(place.visitTime);
    final latitude = place.latitude?.toString() ?? '';
    final longitude = place.longitude?.toString() ?? '';
    final sequence = place.visitSequence?.toString() ?? '';
    final baseKey = placeId.isNotEmpty
        ? 'id:$placeId'
        : 'fallback:$sequence:$name:$address:$visitTime:$latitude:$longitude';
    return '$baseKey:$index';
  }

  List<String> _buildPlaceOrderKeys(List<RoadmapItineraryPlace> places) {
    return [
      for (int i = 0; i < places.length; i++) _placeOrderKey(places[i], i),
    ];
  }

  void _syncDayPlaceOrderCache(List<_DayPlan> dayPlans) {
    final validDayKeys = dayPlans.map(_dayOrderKey).toSet();
    _dayPlaceOrderCache.removeWhere((key, _) => !validDayKeys.contains(key));

    for (final dayPlan in dayPlans) {
      final dayKey = _dayOrderKey(dayPlan);
      final latestOrderKeys = _buildPlaceOrderKeys(dayPlan.places);
      final cachedOrderKeys = _dayPlaceOrderCache[dayKey];
      if (cachedOrderKeys == null) {
        _dayPlaceOrderCache[dayKey] = latestOrderKeys;
        continue;
      }

      final nextOrderKeys = <String>[];
      for (final key in cachedOrderKeys) {
        if (latestOrderKeys.contains(key) && !nextOrderKeys.contains(key)) {
          nextOrderKeys.add(key);
        }
      }
      for (final key in latestOrderKeys) {
        if (!nextOrderKeys.contains(key)) {
          nextOrderKeys.add(key);
        }
      }
      _dayPlaceOrderCache[dayKey] = nextOrderKeys;
    }
  }

  List<RoadmapItineraryPlace> _resolveOrderedPlaces(_DayPlan dayPlan) {
    if (dayPlan.places.isEmpty) {
      return const <RoadmapItineraryPlace>[];
    }

    final dayKey = _dayOrderKey(dayPlan);
    final currentOrderKeys = _buildPlaceOrderKeys(dayPlan.places);
    final cachedOrderKeys = _dayPlaceOrderCache[dayKey] ?? currentOrderKeys;

    final placeByKey = <String, RoadmapItineraryPlace>{
      for (int i = 0; i < dayPlan.places.length; i++)
        _placeOrderKey(dayPlan.places[i], i): dayPlan.places[i],
    };

    final orderedPlaces = <RoadmapItineraryPlace>[];
    final resolvedKeys = <String>[];
    for (final key in cachedOrderKeys) {
      final place = placeByKey[key];
      if (place == null) continue;
      if (resolvedKeys.contains(key)) continue;
      resolvedKeys.add(key);
      orderedPlaces.add(place);
    }

    for (int i = 0; i < dayPlan.places.length; i++) {
      final key = _placeOrderKey(dayPlan.places[i], i);
      if (resolvedKeys.contains(key)) continue;
      resolvedKeys.add(key);
      orderedPlaces.add(dayPlan.places[i]);
    }

    _dayPlaceOrderCache[dayKey] = resolvedKeys;
    return orderedPlaces;
  }

  void _reorderPlaces(_DayPlan dayPlan, int oldIndex, int newIndex) {
    final dayKey = _dayOrderKey(dayPlan);
    final currentOrderKeys =
        List<String>.from(
          _dayPlaceOrderCache[dayKey] ?? _buildPlaceOrderKeys(dayPlan.places),
        );

    if (oldIndex < 0 || oldIndex >= currentOrderKeys.length) {
      return;
    }

    var targetIndex = newIndex;
    if (targetIndex > oldIndex) {
      targetIndex -= 1;
    }
    if (targetIndex < 0) {
      targetIndex = 0;
    }
    if (targetIndex >= currentOrderKeys.length) {
      targetIndex = currentOrderKeys.length - 1;
    }

    setState(() {
      final moved = currentOrderKeys.removeAt(oldIndex);
      currentOrderKeys.insert(targetIndex, moved);
      _dayPlaceOrderCache[dayKey] = currentOrderKeys;
    });
  }

  @override
  Widget build(BuildContext context) {
    final resultState = ref.watch(roadmapItineraryResultViewModelProvider);
    final chatState = ref.watch(roadmapChatViewModelProvider);
    final modificationState = ref.watch(
      roadmapModificationStatusViewModelProvider,
    );
    final isLoading = _isRefreshing || resultState.isLoading;
    final status = resultState.result?.status ?? _lastResultStatus;
    final normalizedStatus = status?.trim().toLowerCase();
    final isSuccessStatus =
        normalizedStatus != null && _isSuccessStatus(normalizedStatus);
    final isFailedStatus =
        normalizedStatus != null && _isFailedStatus(normalizedStatus);
    final isPollingStage =
        _resultPollingTimer != null &&
        !isSuccessStatus &&
        !isFailedStatus &&
        (_jobId?.isNotEmpty ?? false);
    final shouldShowPollingIndicator = isLoading || isPollingStage;
    final roadmapData = resultState.result?.data;
    final dayPlans = isSuccessStatus
        ? _buildDayPlans(roadmapData?.itinerary)
        : const <_DayPlan>[];

    _syncDayPlaceOrderCache(dayPlans);

    _syncSelectedDayIndex(dayPlans.length);
    final selectedDay = dayPlans.isEmpty
        ? null
        : dayPlans[_selectedDayIndex.clamp(0, dayPlans.length - 1)];
    final timelineItems = selectedDay == null
        ? const <_TimelineItem>[]
        : _buildTimelineItems(_resolveOrderedPlaces(selectedDay));
    final selectedPlaces =
        selectedDay == null
        ? const <RoadmapItineraryPlace>[]
        : _resolveOrderedPlaces(selectedDay);
    final markers = _buildMapMarkers(
      isSuccessStatus: isSuccessStatus,
      places: selectedPlaces,
    );
    final mapCenter = _resolveMapCenter(selectedPlaces);
    final emptyMessage = _resolveEmptyMessage(
      isLoading: isLoading,
      resultStatus: status,
    );

    return MLayout(
      backgroundColor: MColor.white100,
      bottomSheet: _buildRequestBottomSheet(
        context,
        isSending: chatState.isLoading || _isModificationPolling,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _MapSection(
              center: mapCenter,
              markers: markers,
              data: roadmapData,
              mapKey: 'map_${selectedDay?.dayNumber ?? 0}_${markers.length}',
            ),
            SizedBox(height: 14.h),
            if (isSuccessStatus && dayPlans.isNotEmpty)
              _DayTabs(
                dayPlans: dayPlans,
                selectedIndex: _selectedDayIndex.clamp(0, dayPlans.length - 1),
                onChanged: (index) {
                  if (_selectedDayIndex == index) return;
                  setState(() => _selectedDayIndex = index);
                },
              )
            else
              SizedBox(height: 80.h),
            if (isSuccessStatus && dayPlans.length > 1)
              _PageDots(
                count: dayPlans.length,
                selectedIndex: _selectedDayIndex.clamp(0, dayPlans.length - 1),
              )
            else
              SizedBox(height: 10.h),
            if (_isModificationPolling)
              Padding(
                padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
                child: _ModificationPollingBanner(
                  status:
                      (modificationState.status?.status.trim().isNotEmpty ??
                          false)
                      ? modificationState.status!.status.trim().toUpperCase()
                      : 'PENDING',
                ),
              ),
            SizedBox(height: 10.h),
            Expanded(
              child: _TimelinePanel(
                isSuccessStatus: isSuccessStatus,
                isFailedStatus: isFailedStatus,
                shouldShowPollingIndicator: shouldShowPollingIndicator,
                emptyMessage: emptyMessage,
                timelineItems: timelineItems,
                onReorder: selectedDay == null
                    ? null
                    : (oldIndex, newIndex) =>
                          _reorderPlaces(selectedDay, oldIndex, newIndex),
                onTapHome: _goToHome,
                bottomPadding:
                    _inputSheetBodySpacing.h +
                    MediaQuery.paddingOf(context).bottom,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Set<Marker> _buildMapMarkers({
    required bool isSuccessStatus,
    required List<RoadmapItineraryPlace> places,
  }) {
    if (!isSuccessStatus || places.isEmpty) {
      return {
        const Marker(
          markerId: MarkerId('start'),
          position: _defaultCenter,
          infoWindow: InfoWindow(title: '출발 위치'),
        ),
      };
    }

    final markers = <Marker>{};
    for (var i = 0; i < places.length; i++) {
      final place = places[i];
      final lat = place.latitude;
      final lng = place.longitude;
      if (lat == null || lng == null) continue;
      if (!_isValidCoordinate(lat, lng)) continue;

      final markerId =
          (place.placeId != null && place.placeId!.trim().isNotEmpty)
          ? place.placeId!.trim()
          : 'place_$i';
      markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: LatLng(lat, lng),
          infoWindow: InfoWindow(
            title: place.placeName ?? '방문 장소',
            snippet: _formatVisitTime(place.visitTime),
          ),
        ),
      );
    }

    if (markers.isEmpty) {
      return {
        const Marker(
          markerId: MarkerId('start'),
          position: _defaultCenter,
          infoWindow: InfoWindow(title: '출발 위치'),
        ),
      };
    }

    return markers;
  }

  LatLng _resolveMapCenter(List<RoadmapItineraryPlace> places) {
    for (final place in places) {
      final lat = place.latitude;
      final lng = place.longitude;
      if (lat == null || lng == null) continue;
      if (!_isValidCoordinate(lat, lng)) continue;
      return LatLng(lat, lng);
    }
    return _defaultCenter;
  }

  bool _isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}

class _ModificationPollingBanner extends StatelessWidget {
  const _ModificationPollingBanner({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: MColor.primary500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 14.w,
            height: 14.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              '수정 요청 반영 중... (상태: $status)',
              style: MTextStyles.sLabelM.copyWith(color: MColor.primary500),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapSection extends StatelessWidget {
  const _MapSection({
    required this.center,
    required this.markers,
    required this.data,
    required this.mapKey,
  });

  final LatLng center;
  final Set<Marker> markers;
  final RoadmapItineraryData? data;
  final String mapKey;

  @override
  Widget build(BuildContext context) {
    final title = _resolveTitle(data);
    final period = _formatPeriod(data?.startDate, data?.endDate);
    final meta = _formatTripMeta(data);
    final summary = _resolveSummaryText(data);
    final tags = _resolveTags(data?.tags);
    final topPadding = MediaQuery.paddingOf(context).top + 10.h;

    return SizedBox(
      height: 430.h,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30.r),
              ),
              child: GoogleMap(
                key: ValueKey(mapKey),
                initialCameraPosition: CameraPosition(
                  target: center,
                  zoom: 12.5,
                ),
                myLocationButtonEnabled: false,
                mapToolbarEnabled: false,
                zoomControlsEnabled: false,
                markers: markers,
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(30.r),
                  ),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.38, 1],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: topPadding,
            left: 12.w,
            right: 12.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _WhiteChip(text: title),
                    if (period.isNotEmpty || meta.isNotEmpty)
                      _WhiteChip(
                        text: [
                          period,
                          meta,
                        ].where((text) => text.trim().isNotEmpty).join('   '),
                      ),
                  ],
                ),
                if (summary != null) ...[
                  SizedBox(height: 8.h),
                  _WhiteChip(text: summary),
                ],
                if (tags.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [for (final tag in tags) _TagChip(text: tag)],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WhiteChip extends StatelessWidget {
  const _WhiteChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: MColor.white100.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(22.r),
      ),
      child: Text(
        text,
        style: MTextStyles.sLabelM.copyWith(color: MColor.gray700),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: MColor.primary500.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        text,
        style: MTextStyles.sLabelM.copyWith(color: MColor.white100),
      ),
    );
  }
}

class _DayTabs extends StatelessWidget {
  const _DayTabs({
    required this.dayPlans,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<_DayPlan> dayPlans;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(7.w),
        decoration: BoxDecoration(
          color: MColor.gray50,
          borderRadius: BorderRadius.circular(14.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: Row(
          children: [
            for (int i = 0; i < dayPlans.length; i++) ...[
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: i == selectedIndex
                          ? MColor.primary500
                          : MColor.gray50,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Day ${dayPlans[i].dayNumber}',
                          style: MTextStyles.sLabelM.copyWith(
                            color: i == selectedIndex
                                ? MColor.white100
                                : MColor.gray300,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _formatDateWithWeekday(dayPlans[i].date),
                          style: MTextStyles.sLabelM.copyWith(
                            color: i == selectedIndex
                                ? MColor.white100
                                : MColor.gray500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (i != dayPlans.length - 1) SizedBox(width: 6.w),
            ],
          ],
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
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < count; i++) ...[
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: i == selectedIndex ? 24.w : 16.w,
              height: 3.h,
              decoration: BoxDecoration(
                color: i == selectedIndex ? MColor.gray600 : MColor.gray200,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            if (i != count - 1) SizedBox(width: 6.w),
          ],
        ],
      ),
    );
  }
}

class _TimelinePanel extends StatelessWidget {
  const _TimelinePanel({
    required this.isSuccessStatus,
    required this.isFailedStatus,
    required this.shouldShowPollingIndicator,
    required this.emptyMessage,
    required this.timelineItems,
    required this.onReorder,
    required this.onTapHome,
    required this.bottomPadding,
  });

  final bool isSuccessStatus;
  final bool isFailedStatus;
  final bool shouldShowPollingIndicator;
  final String emptyMessage;
  final List<_TimelineItem> timelineItems;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final VoidCallback onTapHome;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final canReorder = onReorder != null && timelineItems.length > 1;

    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, bottomPadding),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: !isSuccessStatus || timelineItems.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 24.h,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (shouldShowPollingIndicator)
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
                      if (isFailedStatus)
                        Padding(
                          padding: EdgeInsets.only(top: 16.h),
                          child: SizedBox(
                            width: 180.w,
                            height: 44.h,
                            child: ElevatedButton(
                              onPressed: onTapHome,
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: MColor.primary500,
                                foregroundColor: MColor.white100,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                '홈 화면으로 가기',
                                style: MTextStyles.labelM.copyWith(
                                  color: MColor.white100,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              )
            : canReorder
            ? ReorderableListView.builder(
                padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 20.h),
                buildDefaultDragHandles: false,
                itemCount: timelineItems.length,
                onReorder: onReorder!,
                itemBuilder: (context, index) {
                  final item = timelineItems[index];
                  return Padding(
                    key: ValueKey(item.id),
                    padding: EdgeInsets.only(
                      bottom: index == timelineItems.length - 1 ? 0 : 8.h,
                    ),
                    child: _TimelineRow(
                      item: item,
                      isLast: index == timelineItems.length - 1,
                      dragIndex: index,
                    ),
                  );
                },
              )
            : ListView.separated(
                padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 20.h),
                itemCount: timelineItems.length,
                separatorBuilder: (_, index) => SizedBox(height: 8.h),
                itemBuilder: (context, index) {
                  final item = timelineItems[index];
                  return _TimelineRow(
                    key: ValueKey(item.id),
                    item: item,
                    isLast: index == timelineItems.length - 1,
                  );
                },
              ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    super.key,
    required this.item,
    required this.isLast,
    this.dragIndex,
  });

  final _TimelineItem item;
  final bool isLast;
  final int? dragIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52.w,
          child: Column(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: MColor.primary500,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8.r,
                      offset: Offset(0, 3.h),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${item.order}',
                  style: MTextStyles.bodyB.copyWith(color: MColor.white100),
                ),
              ),
              if (!isLast)
                Container(
                  margin: EdgeInsets.only(top: 8.h),
                  width: 2.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    color: MColor.primary500.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(1.r),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: MTextStyles.bodyB.copyWith(color: MColor.gray800),
                ),
                SizedBox(height: 4.h),
                if (item.time.isNotEmpty)
                  Text(
                    item.time,
                    style: MTextStyles.bodyM.copyWith(color: MColor.gray300),
                  ),
                if (item.description.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item.description,
                    style: MTextStyles.bodyM.copyWith(color: MColor.gray700),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (dragIndex != null)
          ReorderableDragStartListener(
            index: dragIndex!,
            child: Padding(
              padding: EdgeInsets.only(top: 6.h, left: 10.w),
              child: Icon(
                Icons.drag_indicator_rounded,
                size: 20.sp,
                color: MColor.gray300,
              ),
            ),
          ),
      ],
    );
  }
}

class _DayPlan {
  const _DayPlan({
    required this.dayNumber,
    required this.date,
    required this.places,
  });

  final int dayNumber;
  final DateTime? date;
  final List<RoadmapItineraryPlace> places;
}

class _TimelineItem {
  const _TimelineItem({
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

List<_DayPlan> _buildDayPlans(List<RoadmapDailyItinerary>? itinerary) {
  if (itinerary == null || itinerary.isEmpty) {
    return const [];
  }

  final plans = itinerary.map((daily) {
    final places = [...(daily.places ?? const <RoadmapItineraryPlace>[])];
    places.sort((a, b) {
      final aSeq = a.visitSequence ?? 999;
      final bSeq = b.visitSequence ?? 999;
      return aSeq.compareTo(bSeq);
    });

    return _DayPlan(
      dayNumber: daily.dayNumber ?? 0,
      date: daily.dailyDate,
      places: places,
    );
  }).toList();

  plans.sort((a, b) {
    final byDayNumber = a.dayNumber.compareTo(b.dayNumber);
    if (byDayNumber != 0) return byDayNumber;
    if (a.date == null && b.date == null) return 0;
    if (a.date == null) return 1;
    if (b.date == null) return -1;
    return a.date!.compareTo(b.date!);
  });

  return plans;
}

List<_TimelineItem> _buildTimelineItems(List<RoadmapItineraryPlace> places) {
  if (places.isEmpty) return const [];

  final timeline = <_TimelineItem>[];
  for (int i = 0; i < places.length; i++) {
    final place = places[i];
    final order = i + 1;
    final placeId = place.placeId?.trim() ?? '';
    final idBase = placeId.isNotEmpty
        ? 'id:$placeId'
        : 'timeline:${place.placeName ?? ''}:${place.address ?? ''}:${_formatVisitTime(place.visitTime)}';
    final id = '$idBase:$i';

    timeline.add(
      _TimelineItem(
        id: id,
        order: order,
        title: place.placeName?.trim().isNotEmpty == true
            ? place.placeName!.trim()
            : '방문 장소',
        time: _formatVisitTime(place.visitTime),
        description: place.description?.trim().isNotEmpty == true
            ? place.description!.trim()
            : (place.address?.trim() ?? ''),
      ),
    );
  }

  return timeline;
}

String _resolveTitle(RoadmapItineraryData? data) {
  final title = data?.title?.trim();
  if (title != null && title.isNotEmpty) {
    return title;
  }

  final regionNames =
      data?.regions
          ?.map((region) => region.regionName?.trim() ?? '')
          .where((name) => name.isNotEmpty)
          .toList() ??
      const <String>[];
  if (regionNames.isNotEmpty) {
    return '${regionNames.join(' · ')} 여행';
  }

  return '내 여행 일정';
}

String? _resolveSummaryText(RoadmapItineraryData? data) {
  final summary = data?.summary;
  if (summary is String && summary.trim().isNotEmpty) {
    return summary.trim();
  }

  final firstCommentary = _extractFirstCommentaryLine(data?.llmCommentary);
  if (firstCommentary != null) return firstCommentary;

  return null;
}

String? _extractFirstCommentaryLine(Object? commentary) {
  if (commentary == null) return null;

  if (commentary is String) {
    final normalized = commentary
        .split('\n')
        .map((line) => line.trim())
        .firstWhere((line) => line.isNotEmpty, orElse: () => '');
    return normalized.isEmpty ? null : normalized;
  }

  if (commentary is List) {
    for (final item in commentary) {
      final line = item?.toString().trim() ?? '';
      if (line.isNotEmpty) return line;
    }
  }

  return null;
}

String _formatPeriod(DateTime? startDate, DateTime? endDate) {
  if (startDate == null && endDate == null) return '';
  if (startDate != null && endDate != null) {
    return '${_formatYmd(startDate)} - ${_formatYmd(endDate)}';
  }
  return _formatYmd(startDate ?? endDate!);
}

String _formatTripMeta(RoadmapItineraryData? data) {
  final parts = <String>[];
  final nights = data?.nights;
  final days = data?.tripDays;
  final people = data?.peopleCount;

  if (nights != null && days != null) {
    parts.add('$nights박 $days일');
  } else if (days != null) {
    parts.add('$days일');
  }

  if (people != null) {
    parts.add('$people명');
  }

  return parts.join('   ');
}

List<String> _resolveTags(List<String>? source) {
  if (source == null || source.isEmpty) return const [];

  final tags = <String>[];
  for (final raw in source) {
    final text = raw.trim();
    if (text.isEmpty) continue;
    tags.add(text.startsWith('#') ? text : '#$text');
  }

  return tags.take(4).toList();
}

String _formatYmd(DateTime date) {
  final y = date.year.toString().padLeft(4, '0');
  final m = date.month.toString().padLeft(2, '0');
  final d = date.day.toString().padLeft(2, '0');
  return '$y.$m.$d';
}

String _formatDateWithWeekday(DateTime? date) {
  if (date == null) return '-';
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
  return '${_formatYmd(date)} (${weekdays[date.weekday - 1]})';
}

String _formatVisitTime(Object? value) {
  if (value == null) return '';

  if (value is String) {
    final normalized = value.trim();
    if (normalized.isEmpty) return '';
    final match = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(normalized);
    if (match != null) {
      final h = (int.tryParse(match.group(1) ?? '') ?? 0).toString().padLeft(
        2,
        '0',
      );
      final m = match.group(2) ?? '00';
      return '$h:$m';
    }
    return normalized;
  }

  if (value is num) {
    return value.toString();
  }

  return value.toString();
}
