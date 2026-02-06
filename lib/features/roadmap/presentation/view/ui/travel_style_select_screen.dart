import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class TravelStyleSelectScreen extends StatefulWidget {
  const TravelStyleSelectScreen({super.key});

  @override
  State<TravelStyleSelectScreen> createState() => _TravelStyleSelectScreenState();
}

class _TravelStyleSelectScreenState extends State<TravelStyleSelectScreen> {
  final PageController _pageController = PageController();

  int _pageIndex = 0;
  final Map<String, String> _answers = {};

  late final List<_StyleQuestion> _questions = [
    _StyleQuestion.twoChoice(
      id: 'pace',
      title: '여행 스타일',
      prompt: '원하시는 여행 스타일을 선택해주세요!',
      vsLabel: '빡빡하게  VS  널널하게',
      left: _StyleOption(
        id: 'tight',
        label: '빡빡하게',
        fallbackEmoji: '⏱️',
        imagePath: MImages.travelStyleTight,
      ),
      right: _StyleOption(
        id: 'relaxed',
        label: '널널하게',
        fallbackEmoji: '☕️',
        imagePath: MImages.travelStyleRelaxed,
      ),
    ),
    _StyleQuestion.twoChoice(
      id: 'planning',
      title: '여행 스타일',
      prompt: '원하시는 여행 스타일을 선택해주세요!',
      vsLabel: '계획형  VS  즉흥형',
      left: _StyleOption(
        id: 'planner',
        label: '계획형',
        fallbackEmoji: '📒',
        imagePath: MImages.travelStylePlanner,
      ),
      right: _StyleOption(
        id: 'spontaneous',
        label: '즉흥형',
        fallbackEmoji: '🎲',
        imagePath: MImages.travelStyleSpontaneous,
      ),
    ),
    _StyleQuestion.twoChoice(
      id: 'focus',
      title: '여행 스타일',
      prompt: '원하시는 여행 스타일을 선택해주세요!',
      vsLabel: '관광지 위주  VS  로컬 위주',
      left: _StyleOption(
        id: 'tourist',
        label: '관광지 위주',
        fallbackEmoji: '🚠',
        imagePath: MImages.travelStyleTourist,
      ),
      right: _StyleOption(
        id: 'local',
        label: '로컬 위주',
        fallbackEmoji: '🚌',
        imagePath: MImages.travelStyleLocal,
      ),
    ),
    _StyleQuestion.twoChoice(
      id: 'energy',
      title: '여행 스타일',
      prompt: '원하시는 여행 스타일을 선택해주세요!',
      vsLabel: '활동 중심  VS  휴식 중심',
      left: _StyleOption(
        id: 'active',
        label: '활동 중심',
        fallbackEmoji: '🔥',
        imagePath: MImages.travelStyleActive,
      ),
      right: _StyleOption(
        id: 'rest',
        label: '휴식 중심',
        fallbackEmoji: '💗',
        imagePath: MImages.travelStyleRest,
      ),
    ),
    _StyleQuestion.twoChoice(
      id: 'value',
      title: '여행 스타일',
      prompt: '원하시는 여행 스타일을 선택해주세요!',
      vsLabel: '효율  VS  감성',
      left: _StyleOption(
        id: 'efficient',
        label: '효율',
        fallbackEmoji: '📊',
        imagePath: MImages.travelStyleEfficient,
      ),
      right: _StyleOption(
        id: 'emotional',
        label: '감성',
        fallbackEmoji: '🧭',
        imagePath: MImages.travelStyleEmotional,
      ),
    ),
    _StyleQuestion.grid(
      id: 'budget',
      title: '예산 범위',
      prompt: '어느 정도의 예산으로 여행을 준비하고 계신가요?',
      options: [
        _StyleOption(
          id: 'value',
          label: '가성비',
          fallbackEmoji: '⚖️',
          imagePath: MImages.travelBudgetValue,
        ),
        _StyleOption(
          id: 'basic',
          label: '기본',
          fallbackEmoji: '✈️',
          imagePath: MImages.travelBudgetBasic,
        ),
        _StyleOption(
          id: 'premium',
          label: '프리미엄',
          fallbackEmoji: '💰',
          imagePath: MImages.travelBudgetPremium,
        ),
        _StyleOption(
          id: 'luxury',
          label: '럭셔리',
          fallbackEmoji: '💵',
          imagePath: MImages.travelBudgetLuxury,
        ),
      ],
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_pageIndex];
    final enabled = _answers.containsKey(question.id);

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
                onPageChanged: (index) => setState(() => _pageIndex = index),
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
                        _buildOptions(q),
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

  Widget _buildOptions(_StyleQuestion question) {
    return switch (question.layout) {
      _QuestionLayout.twoChoice => Row(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.05,
                child: _OptionCard(
                  option: question.options[0],
                  selected: _answers[question.id] == question.options[0].id,
                  onTap: () => _select(questionId: question.id, optionId: question.options[0].id),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.05,
                child: _OptionCard(
                  option: question.options[1],
                  selected: _answers[question.id] == question.options[1].id,
                  onTap: () => _select(questionId: question.id, optionId: question.options[1].id),
                ),
              ),
            ),
          ],
        ),
      _QuestionLayout.grid => GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: question.options.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final option = question.options[index];
            return _OptionCard(
              option: option,
              selected: _answers[question.id] == option.id,
              onTap: () => _select(questionId: question.id, optionId: option.id),
            );
          },
        ),
    };
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

  void _select({required String questionId, required String optionId}) {
    setState(() => _answers[questionId] = optionId);
  }

  void _onTapBack() {
    if (_pageIndex == 0) {
      Navigator.pop(context);
      return;
    }

    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _onTapNext() {
    if (_pageIndex < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
      return;
    }

    // TODO: 다음 단계 화면이 결정되면 라우팅을 붙여주세요.
    Navigator.pop(context, _answers);
  }
}

enum _QuestionLayout { twoChoice, grid }

class _StyleQuestion {
  _StyleQuestion._({
    required this.id,
    required this.title,
    required this.prompt,
    required this.layout,
    required this.options,
    this.vsLabel,
  });

  final String id;
  final String title;
  final String prompt;
  final String? vsLabel;
  final _QuestionLayout layout;
  final List<_StyleOption> options;

  _StyleQuestion.twoChoice({
    required String id,
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
          layout: _QuestionLayout.twoChoice,
          options: [left, right],
        );

  _StyleQuestion.grid({
    required String id,
    required String title,
    required String prompt,
    required List<_StyleOption> options,
  }) : this._(
          id: id,
          title: title,
          prompt: prompt,
          layout: _QuestionLayout.grid,
          options: options,
        );
}

class _StyleOption {
  const _StyleOption({
    required this.id,
    required this.label,
    required this.fallbackEmoji,
    this.imagePath,
  });

  final String id;
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
                child: Center(
                  child: _OptionImage(option: option),
                ),
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
