import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_types.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/travel_style_select_view_model.dart';

class TravelStyleSelectScreen extends ConsumerStatefulWidget {
  const TravelStyleSelectScreen({super.key});

  @override
  ConsumerState<TravelStyleSelectScreen> createState() =>
      _TravelStyleSelectScreenState();
}

class _TravelStyleSelectScreenState
    extends ConsumerState<TravelStyleSelectScreen> {
  final PageController _pageController = PageController();

  late final List<_StyleQuestion> _questions = [
    _StyleQuestion.twoChoice(
      id: TravelStyleQuestion.pace,
      title: '여행 스타일',
      prompt: '원하시는 여행 스타일을 선택해주세요!',
      vsLabel: '빡빡하게  VS  널널하게',
      left: _StyleOption(
        value: PacePreference.DENSE,
        label: '빡빡하게',
        fallbackEmoji: '⏱️',
        imagePath: MImages.travelStyleTight,
      ),
      right: _StyleOption(
        value: PacePreference.RELAXED,
        label: '널널하게',
        fallbackEmoji: '☕️',
        imagePath: MImages.travelStyleRelaxed,
      ),
    ),
    _StyleQuestion.twoChoice(
      id: TravelStyleQuestion.planning,
      title: '여행 스타일',
      prompt: '원하시는 여행 스타일을 선택해주세요!',
      vsLabel: '계획형  VS  즉흥형',
      left: _StyleOption(
        value: PlanningPreference.PLANNED,
        label: '계획형',
        fallbackEmoji: '📒',
        imagePath: MImages.travelStylePlanner,
      ),
      right: _StyleOption(
        value: PlanningPreference.SPONTANEOUS,
        label: '즉흥형',
        fallbackEmoji: '🎲',
        imagePath: MImages.travelStyleSpontaneous,
      ),
    ),
    _StyleQuestion.twoChoice(
      id: TravelStyleQuestion.destination,
      title: '여행 스타일',
      prompt: '원하시는 여행 스타일을 선택해주세요!',
      vsLabel: '관광지 위주  VS  로컬 위주',
      left: _StyleOption(
        value: DestinationPreference.TOURIST_SPOTS,
        label: '관광지 위주',
        fallbackEmoji: '🚠',
        imagePath: MImages.travelStyleTourist,
      ),
      right: _StyleOption(
        value: DestinationPreference.LOCAL_EXPERIENCE,
        label: '로컬 위주',
        fallbackEmoji: '🚌',
        imagePath: MImages.travelStyleLocal,
      ),
    ),
    _StyleQuestion.twoChoice(
      id: TravelStyleQuestion.activity,
      title: '여행 스타일',
      prompt: '원하시는 여행 스타일을 선택해주세요!',
      vsLabel: '활동 중심  VS  휴식 중심',
      left: _StyleOption(
        value: ActivityPreference.ACTIVE,
        label: '활동 중심',
        fallbackEmoji: '🔥',
        imagePath: MImages.travelStyleActive,
      ),
      right: _StyleOption(
        value: ActivityPreference.REST_FOCUSED,
        label: '휴식 중심',
        fallbackEmoji: '💗',
        imagePath: MImages.travelStyleRest,
      ),
    ),
    _StyleQuestion.twoChoice(
      id: TravelStyleQuestion.priority,
      title: '여행 스타일',
      prompt: '원하시는 여행 스타일을 선택해주세요!',
      vsLabel: '효율  VS  감성',
      left: _StyleOption(
        value: PriorityPreference.EFFICIENCY,
        label: '효율',
        fallbackEmoji: '📊',
        imagePath: MImages.travelStyleEfficient,
      ),
      right: _StyleOption(
        value: PriorityPreference.EMOTIONAL,
        label: '감성',
        fallbackEmoji: '🧭',
        imagePath: MImages.travelStyleEmotional,
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final styleState = ref.watch(travelStyleSelectViewModelProvider);
    final question = _questions[styleState.pageIndex];
    final enabled = styleState.isAnswered(question.id);

    return MLayout(
      backgroundColor: MColor.white100,
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 16.w),
        child: _buildNextButton(enabled: enabled),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 6.h),
            _buildTopBar(),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _questions.length,
                onPageChanged: (index) => ref
                    .read(travelStyleSelectViewModelProvider.notifier)
                    .setPageIndex(index),
                itemBuilder: (context, index) {
                  final q = _questions[index];
                  return SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      top: 40.h,
                      bottom: 180.h,
                    ),
                    child: Column(
                      children: [
                        _buildDescription(q),
                        SizedBox(height: 56.h),
                        _buildOptions(q, styleState),
                      ],
                    ),
                  );
                },
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
          onPressed: _onTapBack,
          icon: Icon(Icons.arrow_back_ios_new, size: 20.sp),
          color: MColor.black100,
          splashRadius: 22.r,
        ),
      ),
    );
  }

  Widget _buildDescription(_StyleQuestion question) {
    final children = <Widget>[
      Text(
        question.title,
        textAlign: TextAlign.center,
        style: MTextStyles.sTitleM.copyWith(color: MColor.black100),
      ),
      SizedBox(height: 12.h),
      Text(
        question.prompt,
        textAlign: TextAlign.center,
        style: MTextStyles.labelM.copyWith(color: MColor.gray400),
      ),
    ];

    if (question.vsLabel != null) {
      children.add(SizedBox(height: 8.h));
      children.add(
        Text(
          question.vsLabel!,
          textAlign: TextAlign.center,
          style: MTextStyles.labelM.copyWith(color: MColor.gray400),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(children: children),
    );
  }

  Widget _buildOptions(
    _StyleQuestion question,
    TravelStyleSelectState styleState,
  ) {
    return Row(
      children: [
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.05,
            child: _OptionCard(
              option: question.options[0],
              selected:
                  styleState.selectedValue(question.id) ==
                  question.options[0].value,
              onTap: () => _select(
                questionId: question.id,
                value: question.options[0].value,
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: AspectRatio(
            aspectRatio: 1.05,
            child: _OptionCard(
              option: question.options[1],
              selected:
                  styleState.selectedValue(question.id) ==
                  question.options[1].value,
              onTap: () => _select(
                questionId: question.id,
                value: question.options[1].value,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton({required bool enabled}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? _onTapNext : null,
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
          '다음',
          style: MTextStyles.labelM.copyWith(
            color: enabled ? MColor.white100 : MColor.gray300,
          ),
        ),
      ),
    );
  }

  void _select({
    required TravelStyleQuestion questionId,
    required Object value,
  }) {
    ref
        .read(travelStyleSelectViewModelProvider.notifier)
        .selectAnswer(question: questionId, value: value);
  }

  void _onTapBack() {
    final styleState = ref.read(travelStyleSelectViewModelProvider);
    if (styleState.pageIndex == 0) {
      Navigator.pop(context);
      return;
    }

    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _onTapNext() {
    final styleState = ref.read(travelStyleSelectViewModelProvider);
    if (styleState.pageIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      return;
    }

    Navigator.pushNamed(context, AppRoutes.roadmapBudgetRange);
  }
}

class _StyleQuestion {
  _StyleQuestion._({
    required this.id,
    required this.title,
    required this.prompt,
    required this.options,
    this.vsLabel,
  });

  final TravelStyleQuestion id;
  final String title;
  final String prompt;
  final String? vsLabel;
  final List<_StyleOption> options;

  _StyleQuestion.twoChoice({
    required TravelStyleQuestion id,
    required String title,
    required String prompt,
    required String vsLabel,
    required _StyleOption left,
    required _StyleOption right,
  }) : this._(
         id: id,
         title: title,
         prompt: prompt,
         vsLabel: vsLabel,
         options: [left, right],
       );
}

class _StyleOption {
  const _StyleOption({
    required this.value,
    required this.label,
    required this.fallbackEmoji,
    this.imagePath,
  });

  final Object value;
  final String label;
  final String fallbackEmoji;
  final String? imagePath;
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _StyleOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? MColor.primary50 : MColor.white100;
    final borderWidth = selected ? 3.w : 1.5.w;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: MColor.primary500, width: borderWidth),
          ),
          child: Column(
            children: [
              SizedBox(height: 16.h),
              Expanded(
                child: Center(child: _OptionImage(option: option)),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  option.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: MTextStyles.labelM.copyWith(color: MColor.black100),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionImage extends StatelessWidget {
  const _OptionImage({required this.option});

  final _StyleOption option;

  @override
  Widget build(BuildContext context) {
    final imagePath = option.imagePath;
    if (imagePath == null || imagePath.isEmpty) {
      return Text(
        option.fallbackEmoji,
        style: TextStyle(fontSize: 64.sp, height: 1),
      );
    }

    return Image.asset(
      imagePath,
      width: 92.w,
      height: 92.w,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          option.fallbackEmoji,
          style: TextStyle(fontSize: 64.sp, height: 1),
        );
      },
    );
  }
}
