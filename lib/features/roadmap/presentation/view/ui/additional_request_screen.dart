import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/app_snack_bar.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';

class AdditionalRequestScreen extends ConsumerStatefulWidget {
  const AdditionalRequestScreen({super.key});

  @override
  ConsumerState<AdditionalRequestScreen> createState() =>
      _AdditionalRequestScreenState();
}

class _AdditionalRequestScreenState
    extends ConsumerState<AdditionalRequestScreen> {
  late final TextEditingController _requestController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _requestController = TextEditingController();
  }

  @override
  void dispose() {
    _requestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final surveyState = ref.watch(roadmapSurveyViewModelProvider);
    final itineraryState = ref.watch(roadmapItineraryViewModelProvider);
    final isLoading =
        _isSubmitting || surveyState.isLoading || itineraryState.isLoading;

    return MLayout(
      backgroundColor: MColor.white100,
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 16.w),
        child: _buildCompleteButton(isLoading: isLoading),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 6.h),
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 40.h,
                  bottom: 180.h,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDescription(),
                    SizedBox(height: 52.h),
                    _buildSectionLabel('요청 사항'),
                    SizedBox(height: 8.h),
                    _buildRequestField(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SizedBox(
      height: 44.h,
      child: Align(
        alignment: Alignment.centerLeft,
        child: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
          color: MColor.black100,
          splashRadius: 22.r,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          Text(
            '추가 요청 사항',
            textAlign: TextAlign.center,
            style: MTextStyles.lBodyM.copyWith(color: MColor.black100),
          ),
          SizedBox(height: 16.h),
          Text(
            '여행에서 중요시 생각하거나,\n희망하시는 것을 자유롭게 작성해주세요!',
            textAlign: TextAlign.center,
            style: MTextStyles.labelM.copyWith(color: MColor.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: MTextStyles.bodyM.copyWith(color: MColor.black100),
    );
  }

  Widget _buildRequestField() {
    return SizedBox(
      height: 278.h,
      child: TextFormField(
        controller: _requestController,
        onChanged: (value) => ref
            .read(additionalRequestViewModelProvider.notifier)
            .setRequest(value),
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        inputFormatters: [LengthLimitingTextInputFormatter(1000)],
        style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: MColor.white100,
          hintText: '자유롭게 작성해주세요! (최대 1000자)',
          hintStyle: MTextStyles.labelM.copyWith(color: MColor.gray300),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 10.w,
            vertical: 12.h,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(color: MColor.gray200, width: 1.w),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6.r),
            borderSide: BorderSide(color: MColor.gray200, width: 1.w),
          ),
        ),
      ),
    );
  }

  Widget _buildCompleteButton({required bool isLoading}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _onTapComplete,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: MColor.primary500,
          disabledBackgroundColor: MColor.gray100,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Text(
          isLoading ? '로드맵 생성 중...' : '완료',
          style: MTextStyles.labelM.copyWith(
            color: isLoading ? MColor.gray300 : MColor.white100,
          ),
        ),
      ),
    );
  }

  Future<void> _onTapComplete() async {
    if (_isSubmitting) return;

    setState(() => _isSubmitting = true);

    final schedule = ref.read(scheduleSelectViewModelProvider);
    final region = ref.read(regionSelectViewModelProvider);
    final people = ref.read(peopleSelectViewModelProvider);
    final companion = ref.read(companionSelectViewModelProvider);
    final concept = ref.read(conceptSelectViewModelProvider);
    final style = ref.read(travelStyleSelectViewModelProvider);
    final budget = ref.read(budgetRangeViewModelProvider);
    final additional = ref.read(additionalRequestViewModelProvider);

    final isSurveySuccess = await ref
        .read(roadmapSurveyViewModelProvider.notifier)
        .submitFromSelections(
          schedule: schedule,
          region: region,
          people: people,
          companion: companion,
          concept: concept,
          style: style,
          budget: budget,
          additional: additional,
        );

    if (!mounted) return;

    if (!isSurveySuccess) {
      final message =
          ref.read(roadmapSurveyViewModelProvider).errorMessage ??
          '로드맵 설문을 저장하지 못했어요.';
      showAppSnackBar(
        context,
        message: message,
        fallbackMessage: '로드맵 설문을 저장하지 못했어요.',
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final surveyResponse = ref.read(roadmapSurveyViewModelProvider).response;
    if (surveyResponse == null || surveyResponse.surveyId.trim().isEmpty) {
      showAppSnackBar(
        context,
        message: '설문 생성 결과를 확인하지 못했어요.',
        fallbackMessage: '설문 생성 결과를 확인하지 못했어요.',
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final isItinerarySuccess = await ref
        .read(roadmapItineraryViewModelProvider.notifier)
        .submit(surveyResponse.surveyId);

    if (!mounted) return;

    if (!isItinerarySuccess) {
      final itineraryState = ref.read(roadmapItineraryViewModelProvider);
      final fallbackJobId = surveyResponse.jobId.trim();
      final canOpenExistingJob =
          fallbackJobId.isNotEmpty &&
          (itineraryState.statusCode == 409 ||
              _looksLikeAlreadyProcessing(itineraryState.errorMessage));

      if (canOpenExistingJob) {
        setState(() => _isSubmitting = false);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.roadmapResult,
          ModalRoute.withName(AppRoutes.root),
          arguments: fallbackJobId,
        );
        return;
      }

      final message = itineraryState.errorMessage ?? '로드맵 생성을 시작하지 못했어요.';
      showAppSnackBar(
        context,
        message: message,
        fallbackMessage: '로드맵 생성을 시작하지 못했어요.',
      );
      setState(() => _isSubmitting = false);
      return;
    }

    final itineraryJobId = ref
        .read(roadmapItineraryViewModelProvider)
        .response
        ?.jobId;
    if (itineraryJobId == null || itineraryJobId.trim().isEmpty) {
      showAppSnackBar(
        context,
        message: '로드맵 작업 ID를 확인하지 못했어요.',
        fallbackMessage: '로드맵 작업 ID를 확인하지 못했어요.',
      );
      setState(() => _isSubmitting = false);
      return;
    }

    setState(() => _isSubmitting = false);
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.roadmapResult,
      ModalRoute.withName(AppRoutes.root),
      arguments: itineraryJobId.trim(),
    );
  }

  bool _looksLikeAlreadyProcessing(String? message) {
    if (message == null) return false;

    final normalized = message.trim().toLowerCase();
    if (normalized.isEmpty) return false;

    return normalized.contains('already') ||
        normalized.contains('processing') ||
        normalized.contains('in progress') ||
        normalized.contains('진행 중') ||
        normalized.contains('처리 중') ||
        normalized.contains('이미');
  }
}
