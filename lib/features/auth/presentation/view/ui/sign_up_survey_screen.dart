// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/app_snack_bar.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view_model/auth_providers.dart';

class SignUpSurveyScreen extends ConsumerStatefulWidget {
  const SignUpSurveyScreen({super.key, required this.userName});

  final String userName;

  @override
  ConsumerState<SignUpSurveyScreen> createState() => _SignUpSurveyScreenState();
}

class _SignUpSurveyScreenState extends ConsumerState<SignUpSurveyScreen> {
  final PageController _pageController = PageController();

  late final List<_SurveyQuestion> _questions = [
    _SurveyQuestion(
      field: _SurveyField.weather,
      title: 'Q1. 선호하시는 기후와 풍경을\n알려주세요!',
      prompt: '지금 이 순간, 당신의 오감을 깨우는\n가장 이상적인 날씨와 풍경은 무엇인가요?',
      options: const [
        _SurveyOption(
          label: '쨍한 햇살 아래 끝없이 펼쳐진\n에메랄드빛 바다와 부드러운 모래사장',
          value: WeatherPreference.OCEAN_BEACH,
        ),
        _SurveyOption(
          label: '코끝을 스치는 쌀쌀한 공기와\n눈 덮인 산등성이가 보이는 따뜻한 노천탕',
          value: WeatherPreference.SNOW_HOT_SPRING,
        ),
        _SurveyOption(
          label: '덥지도 춥지도 않은 선선한 바람을\n맞으며 걷기 좋은 깨끗한 도시의 거리',
          value: WeatherPreference.CLEAN_CITY_BREEZE,
        ),
        _SurveyOption(
          label: '날씨와 상관없이 화려한 조명과\n에너지가 넘치는 실내 랜드마크',
          value: WeatherPreference.INDOOR_LANDMARK,
        ),
      ],
    ),
    _SurveyQuestion(
      field: _SurveyField.travelRange,
      title: 'Q2. 이동 범위 및 비행 한계',
      prompt: '이번 여행을 위해 기꺼이 감수할 수 있는\n비행 시간의 한계는 어느 정도인가요?',
      options: const [
        _SurveyOption(
          label: '주말을 활용하여 가볍게\n다녀올 수 있는 4시간 이내의 단거리',
          value: TravelRangePreference.SHORT_HAUL,
        ),
        _SurveyOption(
          label: '기분 전환을 확실히\n할 수 있는 5~8시간 정도의 중거리',
          value: TravelRangePreference.MEDIUM_HAUL,
        ),
        _SurveyOption(
          label: '완전한 이국적 정취를\n위해 10시간 이상의 장거리',
          value: TravelRangePreference.LONG_HAUL,
        ),
      ],
    ),
    _SurveyQuestion(
      field: _SurveyField.travelStyle,
      title: 'Q3. 공간의 분위기와 감성',
      prompt: "당신이 머무는 공간에서\n가장 중요하게 느끼고 싶은 '감성'은 무엇인가요?",
      options: const [
        _SurveyOption(
          label: '세련된 디자인의 건축물과 트렌디한\n팝업 스토어가 가득한 현대적 감각',
          value: TravelStylePreference.MODERN_TRENDY,
        ),
        _SurveyOption(
          label: '수백 년의 세월을 간직한 유적지와\n시간이 멈춘 듯한 고즈넉한 역사적 분위기',
          value: TravelStylePreference.HISTORIC_RELAXED,
        ),
        _SurveyOption(
          label: '인공적인 소음 없이 오직 파도 소리와\n새소리만 들리는 압도적인 대자연',
          value: TravelStylePreference.PURE_NATURE,
        ),
      ],
    ),
    _SurveyQuestion(
      field: _SurveyField.budgetLevel,
      title: 'Q4. 소비 성향과 가치',
      prompt: '여행지에서의 소비에 대해 당신은\n어떤 철학을 가지고 계신가요?',
      options: const [
        _SurveyOption(
          label: '최소한의 비용으로도 현지의\n본질을 경험하는 합리적인 가성비 여행',
          value: BudgetLevelPreference.COST_EFFECTIVE,
        ),
        _SurveyOption(
          label: '평소에는 아끼더라도 여행지의 특별한\n순간에는 기꺼이 지불하는 균형 잡힌 소비',
          value: BudgetLevelPreference.BALANCED,
        ),
        _SurveyOption(
          label: '비용에 구애받지 않고 오직 최고의\n서비스와 품질만을 지향하는 프리미엄 경험',
          value: BudgetLevelPreference.PREMIUM_LUXURY,
        ),
      ],
    ),
    _SurveyQuestion(
      field: _SurveyField.foodPersonality,
      title: 'Q5. 식도락의 깊이',
      prompt: "당신에게 '여행의 맛'이란 무엇을 의미하나요?",
      multiSelect: true,
      options: const [
        _SurveyOption(
          label: '현지인들만 아는 골목 안쪽의\n투박하지만 진실된 로컬 맛집 탐방',
          value: FoodPersonalityPreference.LOCAL_HIDDEN_GEM,
        ),
        _SurveyOption(
          label: '전 세계적으로 검증된\n미슐랭 가이드 맛집이나 쾌적한 파인 다이닝',
          value: FoodPersonalityPreference.FINE_DINING,
        ),
        _SurveyOption(
          label: '맛은 기본, 공간의 인테리어와\n플레이팅이 완벽한 인스타 감성 카페 투어',
          value: FoodPersonalityPreference.INSTAGRAMMABLE,
        ),
      ],
    ),
    _SurveyQuestion(
      field: _SurveyField.mainInterests,
      title: 'Q6. 핵심 활동과 목적',
      prompt: '이번 여행의 단 하나의 목표를 정한다면,\n당신은 무엇을 선택하시겠습니까?',
      multiSelect: true,
      options: const [
        _SurveyOption(
          label: '유명 브랜드와 로컬 편집숍을\n넘나드는 감각적인 쇼핑 투어',
          value: MainInterestPreference.SHOPPING_TOUR,
        ),
        _SurveyOption(
          label: '서핑, 스키, 등산 등 온몸으로\n자연을 느끼는 역동적인 액티비티',
          value: MainInterestPreference.DYNAMIC_ACTIVITY,
        ),
        _SurveyOption(
          label: '미술관과 박물관을 조용히\n관람하며 예술적 영감을 채우는 시간',
          value: MainInterestPreference.ART_AND_CULTURE,
        ),
      ],
    ),
  ];

  WeatherPreference? _weather;
  TravelRangePreference? _travelRange;
  TravelStylePreference? _travelStyle;
  BudgetLevelPreference? _budgetLevel;
  final Set<FoodPersonalityPreference> _foodPersonality =
      <FoodPersonalityPreference>{};
  final Set<MainInterestPreference> _mainInterests = <MainInterestPreference>{};

  int _pageIndex = 0;

  int get _lastPageIndex => _questions.length + 1;

  bool get _isIntro => _pageIndex == 0;

  bool get _isComplete => _pageIndex == _lastPageIndex;

  int get _questionIndex => _pageIndex - 1;

  bool get _isNextEnabled {
    if (_isIntro || _isComplete) {
      return true;
    }
    return _isQuestionAnswered(_questions[_questionIndex]);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    setState(() {
      _pageIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _showSnack(
    String message, {
    String fallbackMessage = '요청을 처리하지 못했어요. 잠시 후 다시 시도해주세요.',
  }) {
    if (!mounted) {
      return;
    }
    showAppSnackBar(
      context,
      message: message,
      fallbackMessage: fallbackMessage,
    );
  }

  Future<bool> _submitPreferences() async {
    _SurveyPayload payload;
    try {
      payload = _buildSurveyPayload();
    } on StateError {
      _showSnack('설문 응답을 다시 확인해주세요.');
      return false;
    }

    final result = await ref
        .read(signUpViewModelProvider.notifier)
        .submitPreferences(
          weather: payload.weather,
          travelRange: payload.travelRange,
          travelStyle: payload.travelStyle,
          foodPersonality: payload.foodPersonality,
          mainInterests: payload.mainInterests,
          budgetLevel: payload.budgetLevel,
        );

    if (!mounted) {
      return false;
    }

    if (result.isSuccess) {
      return true;
    }

    _showSnack(
      result.message ?? '선호도 저장에 실패했어요.',
      fallbackMessage: '선호도 저장에 실패했어요.',
    );
    return false;
  }

  Future<void> _handleNext() async {
    if (_isComplete) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.root, (_) => false);
      return;
    }
    if (_isIntro) {
      _goToPage(1);
      return;
    }
    if (_pageIndex < _questions.length) {
      _goToPage(_pageIndex + 1);
      return;
    }

    final isSuccess = await _submitPreferences();
    if (!mounted || !isSuccess) {
      return;
    }
    _goToPage(_lastPageIndex);
  }

  bool _isQuestionAnswered(_SurveyQuestion question) {
    return switch (question.field) {
      _SurveyField.weather => _weather != null,
      _SurveyField.travelRange => _travelRange != null,
      _SurveyField.travelStyle => _travelStyle != null,
      _SurveyField.budgetLevel => _budgetLevel != null,
      _SurveyField.foodPersonality => _foodPersonality.isNotEmpty,
      _SurveyField.mainInterests => _mainInterests.isNotEmpty,
    };
  }

  bool _isOptionSelected(_SurveyQuestion question, Object value) {
    return switch (question.field) {
      _SurveyField.weather => _weather == value,
      _SurveyField.travelRange => _travelRange == value,
      _SurveyField.travelStyle => _travelStyle == value,
      _SurveyField.budgetLevel => _budgetLevel == value,
      _SurveyField.foodPersonality => _foodPersonality.contains(value),
      _SurveyField.mainInterests => _mainInterests.contains(value),
    };
  }

  void _selectOption(_SurveyQuestion question, Object value) {
    setState(() {
      switch (question.field) {
        case _SurveyField.weather:
          _weather = value as WeatherPreference;
          break;
        case _SurveyField.travelRange:
          _travelRange = value as TravelRangePreference;
          break;
        case _SurveyField.travelStyle:
          _travelStyle = value as TravelStylePreference;
          break;
        case _SurveyField.budgetLevel:
          _budgetLevel = value as BudgetLevelPreference;
          break;
        case _SurveyField.foodPersonality:
          final selected = value as FoodPersonalityPreference;
          if (_foodPersonality.contains(selected)) {
            _foodPersonality.remove(selected);
          } else {
            _foodPersonality.add(selected);
          }
          break;
        case _SurveyField.mainInterests:
          final selected = value as MainInterestPreference;
          if (_mainInterests.contains(selected)) {
            _mainInterests.remove(selected);
          } else {
            _mainInterests.add(selected);
          }
          break;
      }
    });
  }

  _SurveyPayload _buildSurveyPayload() {
    final weather = _weather;
    final travelRange = _travelRange;
    final travelStyle = _travelStyle;
    final budgetLevel = _budgetLevel;
    if (weather == null ||
        travelRange == null ||
        travelStyle == null ||
        budgetLevel == null) {
      throw StateError(
        'Survey payload cannot be built before completing all questions.',
      );
    }

    final foodValues = FoodPersonalityPreference.values
        .where(_foodPersonality.contains)
        .map((value) => value.apiValue)
        .toList(growable: false);
    final interestValues = MainInterestPreference.values
        .where(_mainInterests.contains)
        .map((value) => value.apiValue)
        .toList(growable: false);

    return _SurveyPayload(
      weather: weather.apiValue,
      travelRange: travelRange.apiValue,
      travelStyle: travelStyle.apiValue,
      foodPersonality: foodValues,
      mainInterests: interestValues,
      budgetLevel: budgetLevel.apiValue,
    );
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpViewModelProvider);
    final isSubmittingPreference = signUpState.isPreferenceSubmitting;
    final label = isSubmittingPreference
        ? '전송 중...'
        : (_isIntro || _isComplete
              ? '시작하기'
              : (_pageIndex == _questions.length ? '완료' : '다음'));
    final isEnabled = _isNextEnabled && !isSubmittingPreference;

    return MLayout(
      backgroundColor: MColor.white100,
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 16.w),
        child: _buildBottomButton(label: label, isEnabled: isEnabled),
      ),
      body: SafeArea(
        child: PageView.builder(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _lastPageIndex + 1,
          onPageChanged: (index) => setState(() => _pageIndex = index),
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildIntro();
            }
            if (index == _lastPageIndex) {
              return _buildComplete();
            }
            final question = _questions[index - 1];
            return _buildQuestion(question);
          },
        ),
      ),
    );
  }

  Widget _buildBottomButton({required String label, required bool isEnabled}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isEnabled ? _handleNext : null,
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
          label,
          style: MTextStyles.labelM.copyWith(
            color: isEnabled ? MColor.white100 : MColor.gray300,
          ),
        ),
      ),
    );
  }

  Widget _buildIntro() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Text(
          '${widget.userName}님의 취향을 분석하기 위해\n간단한 설문 조사를 시작할게요!',
          textAlign: TextAlign.center,
          style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
        ),
      ),
    );
  }

  Widget _buildComplete() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92.r,
            height: 92.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MColor.primary500,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 52.r,
              color: MColor.white100,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            '${widget.userName}님,\n취향을 확실히 분석했어요!',
            textAlign: TextAlign.center,
            style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestion(_SurveyQuestion question) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 36.h,
        bottom: 180.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.title,
            style: MTextStyles.lBodyM.copyWith(color: MColor.black100),
          ),
          Text(
            question.prompt,
            style: MTextStyles.labelM.copyWith(color: MColor.gray400),
          ),
          if (question.multiSelect) ...[
            SizedBox(height: 6.h),
            Text(
              '(중복 선택 가능)',
              style: MTextStyles.labelM.copyWith(color: MColor.gray400),
            ),
          ],
          const Spacer(),
          Column(
            children: [
              for (var i = 0; i < question.options.length; i++) ...[
                _SurveyOptionTile(
                  label: question.options[i].label,
                  selected: _isOptionSelected(
                    question,
                    question.options[i].value,
                  ),
                  multiSelect: question.multiSelect,
                  onTap: () =>
                      _selectOption(question, question.options[i].value),
                ),
                if (i != question.options.length - 1) SizedBox(height: 12.h),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

enum WeatherPreference {
  OCEAN_BEACH,
  SNOW_HOT_SPRING,
  CLEAN_CITY_BREEZE,
  INDOOR_LANDMARK;

  String get apiValue => name;
}

enum TravelRangePreference {
  SHORT_HAUL,
  MEDIUM_HAUL,
  LONG_HAUL;

  String get apiValue => name;
}

enum TravelStylePreference {
  MODERN_TRENDY,
  HISTORIC_RELAXED,
  PURE_NATURE;

  String get apiValue => name;
}

enum FoodPersonalityPreference {
  LOCAL_HIDDEN_GEM,
  FINE_DINING,
  INSTAGRAMMABLE;

  String get apiValue => name;
}

enum MainInterestPreference {
  SHOPPING_TOUR,
  DYNAMIC_ACTIVITY,
  ART_AND_CULTURE;

  String get apiValue => name;
}

enum BudgetLevelPreference {
  COST_EFFECTIVE,
  BALANCED,
  PREMIUM_LUXURY;

  String get apiValue => name;
}

enum _SurveyField {
  weather,
  travelRange,
  travelStyle,
  foodPersonality,
  mainInterests,
  budgetLevel,
}

class _SurveyQuestion {
  const _SurveyQuestion({
    required this.field,
    required this.title,
    required this.prompt,
    required this.options,
    this.multiSelect = false,
  });

  final _SurveyField field;
  final String title;
  final String prompt;
  final List<_SurveyOption> options;
  final bool multiSelect;
}

class _SurveyOption {
  const _SurveyOption({required this.label, required this.value});

  final String label;
  final Object value;
}

class _SurveyPayload {
  const _SurveyPayload({
    required this.weather,
    required this.travelRange,
    required this.travelStyle,
    required this.foodPersonality,
    required this.mainInterests,
    required this.budgetLevel,
  });

  final String weather;
  final String travelRange;
  final String travelStyle;
  final List<String> foodPersonality;
  final List<String> mainInterests;
  final String budgetLevel;
}

class _SurveyOptionTile extends StatelessWidget {
  const _SurveyOptionTile({
    required this.label,
    required this.selected,
    required this.multiSelect,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool multiSelect;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? MColor.primary50 : MColor.gray50;
    final borderColor = selected ? MColor.primary500 : MColor.gray100;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderColor, width: 1.2.w),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SurveySelectionMarker(
                selected: selected,
                multiSelect: multiSelect,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: MTextStyles.labelM.copyWith(color: MColor.black100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SurveySelectionMarker extends StatelessWidget {
  const _SurveySelectionMarker({
    required this.selected,
    required this.multiSelect,
  });

  final bool selected;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    if (multiSelect) {
      return Container(
        width: 20.r,
        height: 20.r,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4.r),
          color: selected ? MColor.primary500 : MColor.white100,
          border: Border.all(
            color: selected ? MColor.primary500 : MColor.gray200,
            width: 1.2.w,
          ),
        ),
        child: selected
            ? Icon(Icons.check_rounded, size: 12.r, color: MColor.white100)
            : null,
      );
    }

    return Container(
      width: 20.r,
      height: 20.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? MColor.primary500 : MColor.white100,
        border: Border.all(
          color: selected ? MColor.primary500 : MColor.gray200,
          width: 1.2.w,
        ),
      ),
      child: selected
          ? Icon(Icons.check_rounded, size: 12.r, color: MColor.white100)
          : null,
    );
  }
}
