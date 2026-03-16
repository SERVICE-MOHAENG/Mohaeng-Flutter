import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

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
  static const Duration _modificationResponsePreviewDuration = Duration(
    milliseconds: 1200,
  );
  static const double _inputSheetBodySpacing = 86;
  static const double _timelineRowHeight = 88;
  static const int _conversationPanelPageIndex = 0;
  static const int _timelinePanelPageIndex = 1;

  bool _isInitialized = false;
  bool _isRefreshing = false;
  bool _isModificationPolling = false;
  bool _isAwaitingModifiedTimeline = false;
  bool _hasShownSuccessMessage = false;
  Timer? _resultPollingTimer;
  Timer? _modificationPollingTimer;
  Timer? _dotAnimationTimer;
  String? _jobId;
  String? _travelCourseId;
  String? _modificationJobId;
  String? _lastResultStatus;
  int _dotCount = 1;
  int _bottomPanelPageIndex = _timelinePanelPageIndex;
  int _selectedDayIndex = 0;
  int _focusedTimelineIndex = 0;
  final Map<String, List<String>> _dayPlaceOrderCache =
      <String, List<String>>{};
  late final PageController _bottomPanelPageController;
  late final TextEditingController _requestInputController;
  late final ScrollController _timelineScrollController;
  GoogleMapController? _mapController;
  String? _currentTimelineDayKey;
  bool _isModificationAssistantTyping = false;
  List<_ModificationConversationEntry> _modificationConversation =
      const <_ModificationConversationEntry>[];
  List<RoadmapItineraryPlace> _currentTimelinePlaces =
      const <RoadmapItineraryPlace>[];

  @override
  void initState() {
    super.initState();
    _bottomPanelPageController = PageController(
      initialPage: _timelinePanelPageIndex,
    );
    _requestInputController = TextEditingController();
    _timelineScrollController = ScrollController()
      ..addListener(_handleTimelineScroll);
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
    _bottomPanelPageController.dispose();
    _requestInputController.dispose();
    _timelineScrollController
      ..removeListener(_handleTimelineScroll)
      ..dispose();
    _stopModificationPolling();
    _stopDotAnimation();
    _stopResultPolling();
    super.dispose();
  }

  void _handleTimelineScroll() {
    if (!_timelineScrollController.hasClients ||
        _currentTimelinePlaces.isEmpty) {
      return;
    }

    final rowHeight = _timelineRowHeight.h;
    if (rowHeight <= 0) return;

    final nextIndex =
        ((_timelineScrollController.offset + (rowHeight * 0.5)) / rowHeight)
            .floor()
            .clamp(0, _currentTimelinePlaces.length - 1);

    if (nextIndex == _focusedTimelineIndex) return;
    _focusedTimelineIndex = nextIndex;
    unawaited(_focusMapOnTimelineIndex(nextIndex));
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

  void _jumpToBottomPanelPage(int pageIndex, {bool animate = true}) {
    void movePage() {
      if (!_bottomPanelPageController.hasClients) return;
      if (animate) {
        unawaited(
          _bottomPanelPageController.animateToPage(
            pageIndex,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          ),
        );
        return;
      }
      _bottomPanelPageController.jumpToPage(pageIndex);
    }

    if (_bottomPanelPageController.hasClients) {
      movePage();
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      movePage();
    });
  }

  void _onBottomPanelPageChanged(int pageIndex) {
    if (_bottomPanelPageIndex == pageIndex) return;
    setState(() {
      _bottomPanelPageIndex = pageIndex;
    });
  }

  void _showBottomPanel(int pageIndex) {
    if (_bottomPanelPageIndex != pageIndex) {
      setState(() {
        _bottomPanelPageIndex = pageIndex;
      });
    }
    _jumpToBottomPanelPage(pageIndex);
  }

  void _beginModificationConversation(String requestMessage) {
    setState(() {
      _isAwaitingModifiedTimeline = true;
      _isModificationAssistantTyping = true;
      _bottomPanelPageIndex = _conversationPanelPageIndex;
      _modificationConversation = <_ModificationConversationEntry>[
        ..._modificationConversation,
        _ModificationConversationEntry.user(requestMessage),
      ];
    });
    _jumpToBottomPanelPage(_conversationPanelPageIndex);
  }

  void _appendModificationAssistantMessage(String responseMessage) {
    if (mounted) {
      setState(() {
        _isModificationAssistantTyping = false;
        _modificationConversation = <_ModificationConversationEntry>[
          ..._modificationConversation,
          _ModificationConversationEntry.assistant(responseMessage),
        ];
      });
      return;
    }
    _isModificationAssistantTyping = false;
    _modificationConversation = <_ModificationConversationEntry>[
      ..._modificationConversation,
      _ModificationConversationEntry.assistant(responseMessage),
    ];
  }

  void _restoreModificationConversation({
    required List<_ModificationConversationEntry> messages,
    required bool isAwaitingTimeline,
    required bool isAssistantTyping,
  }) {
    _modificationConversation = messages;
    _isAwaitingModifiedTimeline = isAwaitingTimeline;
    _isModificationAssistantTyping = isAssistantTyping;
  }

  void _finishModificationConversationWaiting() {
    _isAwaitingModifiedTimeline = false;
    _isModificationAssistantTyping = false;
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
    final nextTravelCourseId = resultState.result?.travelCourseId?.trim();
    if (nextTravelCourseId != null && nextTravelCourseId.isNotEmpty) {
      _travelCourseId = nextTravelCourseId;
    }
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

    final cachedTravelCourseId = _travelCourseId?.trim();
    if (cachedTravelCourseId != null && cachedTravelCourseId.isNotEmpty) {
      return cachedTravelCourseId;
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

      final nextJobId = statusState.status?.jobId.trim();
      if (nextJobId != null && nextJobId.isNotEmpty) {
        if (_jobId != nextJobId) {
          _dayPlaceOrderCache.clear();
        }
        _jobId = nextJobId;
      }

      final nextTravelCourseId = _extractTravelCourseId(statusState.status);
      if (nextTravelCourseId != null && nextTravelCourseId.isNotEmpty) {
        _travelCourseId = nextTravelCourseId;
      }

      final successMessage =
          _extractStatusMessage(statusState.status?.message) ??
          '로드맵 수정이 반영되었습니다.';
      _appendModificationAssistantMessage(successMessage);

      if (intent == 'ask_clarification') {
        if (mounted) {
          setState(_finishModificationConversationWaiting);
        } else {
          _finishModificationConversationWaiting();
        }
        return;
      }

      await Future<void>.delayed(_modificationResponsePreviewDuration);
      if (!mounted) return;

      await _fetchRoadmapResult(isManualRefresh: true);
      if (mounted) {
        setState(_finishModificationConversationWaiting);
      } else {
        _finishModificationConversationWaiting();
      }
      return;
    }

    if (_isFailedStatus(status)) {
      _stopModificationPolling();
      if (mounted) {
        setState(_finishModificationConversationWaiting);
      } else {
        _finishModificationConversationWaiting();
      }

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

    final previousConversation = List<_ModificationConversationEntry>.from(
      _modificationConversation,
    );
    final previousAwaitingTimeline = _isAwaitingModifiedTimeline;
    final previousAssistantTyping = _isModificationAssistantTyping;

    _beginModificationConversation(message);

    final isSuccess = await ref
        .read(roadmapChatViewModelProvider.notifier)
        .submit(itineraryId: itineraryId, message: message);

    if (!mounted) return;

    if (!isSuccess) {
      setState(() {
        _restoreModificationConversation(
          messages: previousConversation,
          isAwaitingTimeline: previousAwaitingTimeline,
          isAssistantTyping: previousAssistantTyping,
        );
      });
      final errorMessage =
          ref.read(roadmapChatViewModelProvider).errorMessage ??
          '로드맵 수정 요청을 전송하지 못했어요.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    final response = ref.read(roadmapChatViewModelProvider).response;
    _requestInputController.clear();
    FocusScope.of(context).unfocus();

    final modificationJobId = response?.jobId.trim();
    if (modificationJobId != null && modificationJobId.isNotEmpty) {
      _startModificationPolling(modificationJobId);
      return;
    }

    setState(() {
      _restoreModificationConversation(
        messages: previousConversation,
        isAwaitingTimeline: previousAwaitingTimeline,
        isAssistantTyping: previousAssistantTyping,
      );
    });
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

  void _syncTimelineContext({
    required String? dayKey,
    required List<RoadmapItineraryPlace> places,
  }) {
    final dayChanged = _currentTimelineDayKey != dayKey;
    _currentTimelineDayKey = dayKey;
    _currentTimelinePlaces = places;

    if (places.isEmpty) {
      _focusedTimelineIndex = 0;
      return;
    }

    if (dayChanged) {
      _focusedTimelineIndex = 0;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_timelineScrollController.hasClients) {
          _timelineScrollController.jumpTo(0);
        }
        unawaited(_focusMapOnTimelineIndex(0, animate: false));
      });
      return;
    }

    final clampedIndex = _focusedTimelineIndex.clamp(0, places.length - 1);
    if (clampedIndex == _focusedTimelineIndex) return;

    _focusedTimelineIndex = clampedIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(
        _focusMapOnTimelineIndex(_focusedTimelineIndex, animate: false),
      );
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

  int? _findNearestMappablePlaceIndex(
    List<RoadmapItineraryPlace> places,
    int preferredIndex,
  ) {
    if (places.isEmpty) return null;

    final start = preferredIndex.clamp(0, places.length - 1);
    for (int distance = 0; distance < places.length; distance++) {
      final left = start - distance;
      if (left >= 0 && _placeHasValidCoordinate(places[left])) {
        return left;
      }

      final right = start + distance;
      if (distance != 0 &&
          right < places.length &&
          _placeHasValidCoordinate(places[right])) {
        return right;
      }
    }

    return null;
  }

  bool _placeHasValidCoordinate(RoadmapItineraryPlace place) {
    final latitude = place.latitude;
    final longitude = place.longitude;
    if (latitude == null || longitude == null) return false;
    return _isValidCoordinate(latitude, longitude);
  }

  String _markerIdForPlace(RoadmapItineraryPlace place, int index) {
    final placeId = place.placeId?.trim();
    if (placeId != null && placeId.isNotEmpty) {
      return placeId;
    }
    return 'place_$index';
  }

  Future<void> _focusMapOnTimelineIndex(
    int index, {
    bool animate = true,
  }) async {
    final controller = _mapController;
    if (controller == null || _currentTimelinePlaces.isEmpty) return;

    final targetIndex = _findNearestMappablePlaceIndex(
      _currentTimelinePlaces,
      index,
    );
    if (targetIndex == null) return;

    final place = _currentTimelinePlaces[targetIndex];
    final latitude = place.latitude;
    final longitude = place.longitude;
    if (latitude == null || longitude == null) return;

    final target = LatLng(latitude, longitude);
    try {
      final update = CameraUpdate.newLatLng(target);
      if (animate) {
        await controller.animateCamera(update);
      } else {
        await controller.moveCamera(update);
      }
      await controller.showMarkerInfoWindow(
        MarkerId(_markerIdForPlace(place, targetIndex)),
      );
    } catch (_) {
      // Ignore camera sync failures from disposed or not-yet-ready map views.
    }
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
    final selectedDayKey = selectedDay == null
        ? null
        : _dayOrderKey(selectedDay);
    final timelineItems = selectedDay == null
        ? const <_TimelineItem>[]
        : _buildTimelineItems(_resolveOrderedPlaces(selectedDay));
    final selectedPlaces = selectedDay == null
        ? const <RoadmapItineraryPlace>[]
        : _resolveOrderedPlaces(selectedDay);
    final hasConversationPanel =
        _isAwaitingModifiedTimeline || _modificationConversation.isNotEmpty;
    _syncTimelineContext(dayKey: selectedDayKey, places: selectedPlaces);
    final markers = _buildMapMarkers(
      isSuccessStatus: isSuccessStatus,
      places: selectedPlaces,
    );
    final polylines = _buildMapPolylines(
      isSuccessStatus: isSuccessStatus,
      places: selectedPlaces,
    );
    final mapCenter = _resolveMapCenter(selectedPlaces);
    final emptyMessage = _resolveEmptyMessage(
      isLoading: isLoading,
      resultStatus: status,
    );
    final modificationPollingStatus =
        (modificationState.status?.status.trim().isNotEmpty ?? false)
        ? modificationState.status!.status.trim().toUpperCase()
        : 'PENDING';
    final bottomPanelPadding =
        _inputSheetBodySpacing.h + MediaQuery.paddingOf(context).bottom;

    return MLayout(
      backgroundColor: MColor.gray50,
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
              polylines: polylines,
              data: roadmapData,
              mapKey: 'map_${selectedDay?.dayNumber ?? 0}_${markers.length}',
              onMapCreated: (controller) {
                _mapController = controller;
                unawaited(
                  _focusMapOnTimelineIndex(
                    _focusedTimelineIndex,
                    animate: false,
                  ),
                );
              },
            ),
            Expanded(
              child: ColoredBox(
                color: MColor.white100,
                child: hasConversationPanel
                    ? Column(
                        children: [
                          SizedBox(height: 16.h),
                          _BottomPanelSwitcher(
                            selectedIndex: _bottomPanelPageIndex,
                            onChanged: _showBottomPanel,
                          ),
                          SizedBox(height: 16.h),
                          Expanded(
                            child: PageView(
                              controller: _bottomPanelPageController,
                              onPageChanged: _onBottomPanelPageChanged,
                              children: [
                                _ConversationPanel(
                                  modificationConversation:
                                      _modificationConversation,
                                  isAssistantTyping:
                                      _isModificationAssistantTyping,
                                  typingDotCount: _dotCount,
                                  bottomPadding: bottomPanelPadding,
                                ),
                                _TimelinePanelPage(
                                  topSpacing: 0,
                                  isSuccessStatus: isSuccessStatus,
                                  isFailedStatus: isFailedStatus,
                                  shouldShowPollingIndicator:
                                      shouldShowPollingIndicator,
                                  emptyMessage: emptyMessage,
                                  dayPlans: dayPlans,
                                  selectedDayIndex: _selectedDayIndex,
                                  onDayChanged: (index) {
                                    if (_selectedDayIndex == index) return;
                                    setState(() => _selectedDayIndex = index);
                                  },
                                  showModificationPollingBanner:
                                      _isModificationPolling,
                                  modificationPollingStatus:
                                      modificationPollingStatus,
                                  timelineItems: timelineItems,
                                  onReorder: null,
                                  onTapHome: _goToHome,
                                  scrollController: _timelineScrollController,
                                  bottomPadding: bottomPanelPadding,
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : _TimelinePanelPage(
                        topSpacing: 16.h,
                        isSuccessStatus: isSuccessStatus,
                        isFailedStatus: isFailedStatus,
                        shouldShowPollingIndicator: shouldShowPollingIndicator,
                        emptyMessage: emptyMessage,
                        dayPlans: dayPlans,
                        selectedDayIndex: _selectedDayIndex,
                        onDayChanged: (index) {
                          if (_selectedDayIndex == index) return;
                          setState(() => _selectedDayIndex = index);
                        },
                        showModificationPollingBanner: _isModificationPolling,
                        modificationPollingStatus: modificationPollingStatus,
                        timelineItems: timelineItems,
                        onReorder: null,
                        onTapHome: _goToHome,
                        scrollController: _timelineScrollController,
                        bottomPadding: bottomPanelPadding,
                      ),
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

      final markerId = _markerIdForPlace(place, i);
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

  Set<Polyline> _buildMapPolylines({
    required bool isSuccessStatus,
    required List<RoadmapItineraryPlace> places,
  }) {
    if (!isSuccessStatus || places.length < 2) {
      return const <Polyline>{};
    }

    final points = <LatLng>[];
    for (final place in places) {
      final lat = place.latitude;
      final lng = place.longitude;
      if (lat == null || lng == null) continue;
      if (!_isValidCoordinate(lat, lng)) continue;
      points.add(LatLng(lat, lng));
    }

    if (points.length < 2) {
      return const <Polyline>{};
    }

    return {
      Polyline(
        polylineId: const PolylineId('selected_day_route'),
        points: points,
        color: MColor.primary500.withValues(alpha: 0.88),
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      ),
    };
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
    required this.polylines,
    required this.data,
    required this.mapKey,
    required this.onMapCreated,
  });

  final LatLng center;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final RoadmapItineraryData? data;
  final String mapKey;
  final ValueChanged<GoogleMapController> onMapCreated;

  @override
  Widget build(BuildContext context) {
    final title = _resolveTitle(data);
    final period = _formatPeriod(data?.startDate, data?.endDate);
    final meta = _formatTripMeta(data).replaceAll('   ', ' · ');
    final summary = _resolveSummaryText(data);
    final tags = _resolveTags(data?.tags);
    final tripMeta = [
      period,
      meta,
    ].where((text) => text.trim().isNotEmpty).join('   ');
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
                      Colors.black.withValues(alpha: 0.06),
                      Colors.transparent,
                    ],
                    stops: const [0, 0.46, 1],
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
            child: SizedBox(
              width: 280.w,
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
                        maxWidth: 124.w,
                      ),
                      if (tripMeta.isNotEmpty)
                        _OverlayChip(
                          text: tripMeta,
                          textColor: MColor.gray600,
                          horizontalPadding: 10.w,
                          verticalPadding: 6.h,
                          maxWidth: 165.w,
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
                            maxWidth: 124.w,
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
                                'Day ${dayPlans[i].dayNumber <= 0 ? i + 1 : dayPlans[i].dayNumber}',
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

class _BottomPanelSwitcher extends StatelessWidget {
  const _BottomPanelSwitcher({
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    const labels = <String>['AI 채팅', '일정표'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: MColor.gray50,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: MColor.gray100, width: 1),
        ),
        child: Row(
          children: [
            for (int i = 0; i < labels.length; i++) ...[
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    decoration: BoxDecoration(
                      color: i == selectedIndex
                          ? MColor.white100
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: i == selectedIndex
                          ? [
                              BoxShadow(
                                color: MColor.gray900.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Text(
                      labels[i],
                      textAlign: TextAlign.center,
                      style: MTextStyles.labelM.copyWith(
                        color: i == selectedIndex
                            ? MColor.gray900
                            : MColor.gray400,
                      ),
                    ),
                  ),
                ),
              ),
              if (i != labels.length - 1) SizedBox(width: 6.w),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelinePanelPage extends StatelessWidget {
  const _TimelinePanelPage({
    required this.topSpacing,
    required this.isSuccessStatus,
    required this.isFailedStatus,
    required this.shouldShowPollingIndicator,
    required this.emptyMessage,
    required this.dayPlans,
    required this.selectedDayIndex,
    required this.onDayChanged,
    required this.showModificationPollingBanner,
    required this.modificationPollingStatus,
    required this.timelineItems,
    required this.onReorder,
    required this.onTapHome,
    required this.scrollController,
    required this.bottomPadding,
  });

  final double topSpacing;
  final bool isSuccessStatus;
  final bool isFailedStatus;
  final bool shouldShowPollingIndicator;
  final String emptyMessage;
  final List<_DayPlan> dayPlans;
  final int selectedDayIndex;
  final ValueChanged<int> onDayChanged;
  final bool showModificationPollingBanner;
  final String modificationPollingStatus;
  final List<_TimelineItem> timelineItems;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final VoidCallback onTapHome;
  final ScrollController scrollController;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: topSpacing),
        if (isSuccessStatus && dayPlans.isNotEmpty)
          _DayTabs(
            dayPlans: dayPlans,
            selectedIndex: selectedDayIndex.clamp(0, dayPlans.length - 1),
            onChanged: onDayChanged,
          )
        else
          SizedBox(height: 58.h),
        SizedBox(height: 16.h),
        if (isSuccessStatus && dayPlans.length > 1)
          _PageDots(
            count: dayPlans.length,
            selectedIndex: selectedDayIndex.clamp(0, dayPlans.length - 1),
          )
        else
          SizedBox(height: 2.h),
        SizedBox(height: 20.h),
        if (showModificationPollingBanner)
          Padding(
            padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 10.h),
            child: _ModificationPollingBanner(
              status: modificationPollingStatus,
            ),
          ),
        SizedBox(height: showModificationPollingBanner ? 10.h : 0),
        Expanded(
          child: _TimelinePanel(
            isSuccessStatus: isSuccessStatus,
            isFailedStatus: isFailedStatus,
            shouldShowPollingIndicator: shouldShowPollingIndicator,
            emptyMessage: emptyMessage,
            timelineItems: timelineItems,
            onReorder: onReorder,
            onTapHome: onTapHome,
            scrollController: scrollController,
            bottomPadding: bottomPadding,
          ),
        ),
      ],
    );
  }
}

class _ConversationPanel extends StatelessWidget {
  const _ConversationPanel({
    required this.modificationConversation,
    required this.isAssistantTyping,
    required this.typingDotCount,
    required this.bottomPadding,
  });

  final List<_ModificationConversationEntry> modificationConversation;
  final bool isAssistantTyping;
  final int typingDotCount;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, bottomPadding),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (modificationConversation.isEmpty && !isAssistantTyping)
              _ConversationBubble(
                roleLabel: '모행',
                message:
                    '원하는 일정 수정을 자유롭게 말씀해 주세요.\n장소 변경, 동선 조정, 시간 여유 확보도 도와드릴게요.',
                alignment: Alignment.centerLeft,
                backgroundColor: MColor.gray50,
                textColor: MColor.gray800,
                borderColor: MColor.gray100,
              ),
            for (int i = 0; i < modificationConversation.length; i++) ...[
              _ConversationBubble(
                roleLabel: modificationConversation[i].speaker.label,
                message: modificationConversation[i].message,
                alignment: modificationConversation[i].speaker.isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                backgroundColor: modificationConversation[i].speaker.isUser
                    ? MColor.primary500
                    : MColor.gray50,
                textColor: modificationConversation[i].speaker.isUser
                    ? MColor.white100
                    : MColor.gray800,
                borderColor: modificationConversation[i].speaker.isUser
                    ? null
                    : MColor.gray100,
              ),
              if (i != modificationConversation.length - 1 || isAssistantTyping)
                SizedBox(height: 14.h),
            ],
            if (isAssistantTyping)
              _TypingConversationBubble(dotCount: typingDotCount),
          ],
        ),
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
    required this.scrollController,
    required this.bottomPadding,
  });

  final bool isSuccessStatus;
  final bool isFailedStatus;
  final bool shouldShowPollingIndicator;
  final String emptyMessage;
  final List<_TimelineItem> timelineItems;
  final void Function(int oldIndex, int newIndex)? onReorder;
  final VoidCallback onTapHome;
  final ScrollController scrollController;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final canReorder = onReorder != null && timelineItems.length > 1;

    if (!isSuccessStatus || timelineItems.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, bottomPadding),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (shouldShowPollingIndicator)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: MTextStyles.labelM.copyWith(color: MColor.gray400),
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
        ),
      );
    }

    if (canReorder) {
      return ReorderableListView.builder(
        scrollController: scrollController,
        padding: EdgeInsets.only(top: 4.h, bottom: 88.832.h),
        buildDefaultDragHandles: false,
        itemCount: timelineItems.length,
        onReorder: onReorder!,
        itemBuilder: (context, index) {
          final item = timelineItems[index];
          return _TimelineRow(
            key: ValueKey(item.id),
            item: item,
            isLast: index == timelineItems.length - 1,
            dragIndex: index,
          );
        },
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.only(top: 4.h, bottom: 88.832.h),
      itemCount: timelineItems.length,
      itemBuilder: (context, index) {
        final item = timelineItems[index];
        return _TimelineRow(
          key: ValueKey(item.id),
          item: item,
          isLast: index == timelineItems.length - 1,
        );
      },
    );
  }
}

enum _ModificationConversationSpeaker {
  user,
  assistant;

  bool get isUser => this == _ModificationConversationSpeaker.user;

  String get label => switch (this) {
    _ModificationConversationSpeaker.user => '나',
    _ModificationConversationSpeaker.assistant => '모행',
  };
}

class _ModificationConversationEntry {
  const _ModificationConversationEntry({
    required this.speaker,
    required this.message,
  });

  const _ModificationConversationEntry.user(String message)
    : this(speaker: _ModificationConversationSpeaker.user, message: message);

  const _ModificationConversationEntry.assistant(String message)
    : this(
        speaker: _ModificationConversationSpeaker.assistant,
        message: message,
      );

  final _ModificationConversationSpeaker speaker;
  final String message;
}

class _ConversationBubble extends StatelessWidget {
  const _ConversationBubble({
    required this.roleLabel,
    required this.message,
    required this.alignment,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
  });

  final String roleLabel;
  final String message;
  final Alignment alignment;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final isRightAligned = alignment == Alignment.centerRight;
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 263.w),
        child: Column(
          crossAxisAlignment: isRightAligned
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                roleLabel,
                style: MTextStyles.sLabelM.copyWith(color: MColor.gray300),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(isRightAligned ? 18.r : 4.r),
                  bottomRight: Radius.circular(isRightAligned ? 4.r : 18.r),
                ),
                border: borderColor == null
                    ? null
                    : Border.all(color: borderColor!, width: 1),
              ),
              child: Text(
                message,
                style: MTextStyles.labelM.copyWith(
                  color: textColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingConversationBubble extends StatelessWidget {
  const _TypingConversationBubble({required this.dotCount});

  final int dotCount;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 180.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                '모행',
                style: MTextStyles.sLabelM.copyWith(color: MColor.gray300),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: MColor.gray50,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.r),
                  topRight: Radius.circular(18.r),
                  bottomLeft: Radius.circular(4.r),
                  bottomRight: Radius.circular(18.r),
                ),
                border: Border.all(color: MColor.gray100, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int i = 0; i < 3; i++) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: i < dotCount
                            ? MColor.primary500
                            : MColor.gray100,
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i != 2) SizedBox(width: 6.w),
                  ],
                ],
              ),
            ),
          ],
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
            if (dragIndex != null)
              ReorderableDragStartListener(
                index: dragIndex!,
                child: Padding(
                  padding: EdgeInsets.only(top: 8.h, left: 10.w),
                  child: Icon(
                    Icons.drag_indicator_rounded,
                    size: 20.sp,
                    color: MColor.gray300,
                  ),
                ),
              ),
          ],
        ),
      ),
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
