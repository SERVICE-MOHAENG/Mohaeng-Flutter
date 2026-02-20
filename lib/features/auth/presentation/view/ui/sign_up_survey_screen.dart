import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class SignUpSurveyScreen extends StatefulWidget {
  const SignUpSurveyScreen({super.key, required this.userName});

  final String userName;

  @override
  State<SignUpSurveyScreen> createState() => _SignUpSurveyScreenState();
}

class _SignUpSurveyScreenState extends State<SignUpSurveyScreen> {
  final PageController _pageController = PageController();

  late final List<_SurveyQuestion> _questions = [
    _SurveyQuestion(
      title: 'Q1. 선호하시는 기후와 풍경을\n알려주세요!',
      prompt: '지금 이 순간, 당신의 오감을 깨우는\n가장 이상적인 날씨와 풍경은 무엇인가요?',
      options: const [
        '쨍한 햇살 아래 끝없이 펼쳐진\n에메랄드빛 바다와 부드러운 모래사장',
        '코끝을 스치는 쌀쌀한 공기와\n눈 덮인 산등성이가 보이는 따뜻한 노천탕',
        '덥지도 춥지도 않은 선선한 바람을\n맞으며 걷기 좋은 깨끗한 도시의 거리',
        '날씨와 상관없이 화려한 조명과\n에너지가 넘치는 실내 랜드마크',
      ],
    ),
    _SurveyQuestion(
      title: 'Q2. 이동 범위 및 비행 한계',
      prompt: '이번 여행을 위해 기꺼이 감수할 수 있는\n비행 시간의 한계는 어느 정도인가요?',
      options: const [
        '주말을 활용하여 가볍게\n다녀올 수 있는 4시간 이내의 단거리',
        '기분 전환을 확실히\n할 수 있는 5~8시간 정도의 중거리',
        '완전한 이국적 정취를\n위해 10시간 이상의 장거리',
      ],
    ),
    _SurveyQuestion(
      title: 'Q3. 공간의 분위기와 감성',
      prompt: "당신이 머무는 공간에서\n가장 중요하게 느끼고 싶은 '감성'은 무엇인가요?",
      options: const [
        '세련된 디자인의 건축물과 트렌디한\n팝업 스토어가 가득한 현대적 감각',
        '수백 년의 세월을 간직한 유적지와\n시간이 멈춘 듯한 고즈넉한 역사적 분위기',
        '인공적인 소음 없이 오직 파도 소리와\n새소리만 들리는 압도적인 대자연',
      ],
    ),
    _SurveyQuestion(
      title: 'Q4. 소비 성향과 가치',
      prompt: '여행지에서의 소비에 대해 당신은\n어떤 철학을 가지고 계신가요?',
      options: const [
        '최소한의 비용으로도 현지의\n본질을 경험하는 합리적인 가성비 여행',
        '평소에는 아끼더라도 여행지의 특별한\n순간에는 기꺼이 지불하는 균형 잡힌 소비',
        '비용에 구애받지 않고 오직 최고의\n서비스와 품질만을 지향하는 프리미엄 경험',
      ],
    ),
    _SurveyQuestion(
      title: 'Q5. 식도락의 깊이',
      prompt: "당신에게 '여행의 맛'이란 무엇을 의미하나요?",
      options: const [
        '현지인들만 아는 골목 안쪽의\n투박하지만 진실된 로컬 맛집 탐방',
        '전 세계적으로 검증된\n미슐랭 가이드 맛집이나 쾌적한 파인 다이닝',
        '맛은 기본, 공간의 인테리어와\n플레이팅이 완벽한 인스타 감성 카페 투어',
      ],
    ),
    _SurveyQuestion(
      title: 'Q6. 핵심 활동과 목적',
      prompt: '이번 여행의 단 하나의 목표를 정한다면,\n당신은 무엇을 선택하시겠습니까?',
      options: const [
        '유명 브랜드와 로컬 편집숍을\n넘나드는 감각적인 쇼핑 투어',
        '서핑, 스키, 등산 등 온몸으로\n자연을 느끼는 역동적인 액티비티',
        '미술관과 박물관을 조용히\n관람하며 예술적 영감을 채우는 시간',
      ],
    ),
  ];

  late final List<int?> _selectedOptions =
      List<int?>.filled(_questions.length, null);

  int _pageIndex = 0;

  int get _lastPageIndex => _questions.length + 1;

  bool get _isIntro => _pageIndex == 0;

  bool get _isComplete => _pageIndex == _lastPageIndex;

  bool get _isQuestion => !_isIntro && !_isComplete;

  int get _questionIndex => _pageIndex - 1;

  bool get _isNextEnabled {
    if (_isIntro || _isComplete) {
      return true;
    }
    return _selectedOptions[_questionIndex] != null;
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

  void _handleNext() {
    if (_isComplete) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
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
    _goToPage(_lastPageIndex);
  }

  @override
  Widget build(BuildContext context) {
    final label = _isIntro || _isComplete ? '시작하기' : '다음';

    return MLayout(
      backgroundColor: MColor.white100,
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 16.w),
        child: _buildBottomButton(label: label),
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
            final selectedIndex = _selectedOptions[index - 1];
            return _buildQuestion(question, selectedIndex);
          },
        ),
      ),
    );
  }

  Widget _buildBottomButton({required String label}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isNextEnabled ? _handleNext : null,
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
            color: _isNextEnabled ? MColor.white100 : MColor.gray300,
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

  Widget _buildQuestion(_SurveyQuestion question, int? selectedIndex) {
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
          const Spacer(),
          Column(
            children: [
              for (var i = 0; i < question.options.length; i++) ...[
                _SurveyOptionTile(
                  label: question.options[i],
                  selected: selectedIndex == i,
                  onTap: () {
                    setState(() {
                      _selectedOptions[_questionIndex] = i;
                    });
                  },
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

class _SurveyQuestion {
  const _SurveyQuestion({
    required this.title,
    required this.prompt,
    required this.options,
  });

  final String title;
  final String prompt;
  final List<String> options;
}

class _SurveyOptionTile extends StatelessWidget {
  const _SurveyOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
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
              _SurveyRadio(selected: selected),
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

class _SurveyRadio extends StatelessWidget {
  const _SurveyRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
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
