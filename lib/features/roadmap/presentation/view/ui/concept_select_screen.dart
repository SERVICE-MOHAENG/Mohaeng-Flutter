import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class ConceptSelectScreen extends StatefulWidget {
  const ConceptSelectScreen({super.key});

  @override
  State<ConceptSelectScreen> createState() => _ConceptSelectScreenState();
}

class _ConceptSelectScreenState extends State<ConceptSelectScreen> {
  final Set<_TravelConcept> _selected = {};

  @override
  Widget build(BuildContext context) {
    final enabled = _selected.isNotEmpty;

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
            SizedBox(height: 40.h),
            _buildDescription(),
            SizedBox(height: 28.h),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  bottom: 180.h,
                ),
                child: _buildGrid(),
              ),
            ),
            SizedBox(height: 16.h),
          ],
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
            '여행 컨셉 선택',
            textAlign: TextAlign.center,
            style: MTextStyles.lBodyM.copyWith(color: MColor.black100),
          ),
          SizedBox(height: 16.h),
          Text(
            '가고싶은 여행 컨셉을 선택해주세요!',
            textAlign: TextAlign.center,
            style: MTextStyles.labelM.copyWith(color: MColor.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final items = _TravelConcept.values;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.0,
      ),
      itemBuilder: (context, index) {
        final concept = items[index];
        final selected = _selected.contains(concept);

        return _ConceptCard(
          label: concept.label,
          imagePath: concept.imagePath,
          fallbackEmoji: concept.fallbackEmoji,
          selected: selected,
          onTap: () {
            setState(() {
              if (_selected.contains(concept)) {
                _selected.remove(concept);
              } else {
                _selected.add(concept);
              }
            });
          },
        );
      },
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

  void _onTapNext() {
    // TODO: 다음 단계 화면이 결정되면 라우팅을 붙여주세요.
  }
}

enum _TravelConcept {
  sightseeing,
  food,
  family,
  healing,
  nature,
  shopping,
  city,
  photo,
  unique,
  honeymoon,
  cultureArt,
  activity;

  String get label => switch (this) {
    _TravelConcept.sightseeing => '관광',
    _TravelConcept.food => '먹방',
    _TravelConcept.family => '가족 여행',
    _TravelConcept.healing => '힐링',
    _TravelConcept.nature => '자연',
    _TravelConcept.shopping => '쇼핑',
    _TravelConcept.city => '도시 여행',
    _TravelConcept.photo => '사진 인생샷',
    _TravelConcept.unique => '이색 여행',
    _TravelConcept.honeymoon => '신혼 여행',
    _TravelConcept.cultureArt => '문화, 예술',
    _TravelConcept.activity => '액티비티',
  };

  String get fallbackEmoji => switch (this) {
    _TravelConcept.sightseeing => '✈️',
    _TravelConcept.food => '🍽️',
    _TravelConcept.family => '👨‍👩‍👧‍👦',
    _TravelConcept.healing => '🛁',
    _TravelConcept.nature => '🏕️',
    _TravelConcept.shopping => '🛍️',
    _TravelConcept.city => '🏙️',
    _TravelConcept.photo => '📷',
    _TravelConcept.unique => '🧩',
    _TravelConcept.honeymoon => '💞',
    _TravelConcept.cultureArt => '🎨',
    _TravelConcept.activity => '🧗‍♂️',
  };

  String get imagePath => switch (this) {
    _TravelConcept.sightseeing => MImages.conceptSightseeing,
    _TravelConcept.food => MImages.conceptFood,
    _TravelConcept.family => MImages.conceptFamily,
    _TravelConcept.healing => MImages.conceptHealing,
    _TravelConcept.nature => MImages.conceptNature,
    _TravelConcept.shopping => MImages.conceptShopping,
    _TravelConcept.city => MImages.conceptCity,
    _TravelConcept.photo => MImages.conceptPhoto,
    _TravelConcept.unique => MImages.conceptUnique,
    _TravelConcept.honeymoon => MImages.conceptHoneymoon,
    _TravelConcept.cultureArt => MImages.conceptCultureArt,
    _TravelConcept.activity => MImages.conceptActivity,
  };
}

class _ConceptCard extends StatelessWidget {
  const _ConceptCard({
    required this.label,
    required this.imagePath,
    required this.fallbackEmoji,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final String fallbackEmoji;
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
                  child: Image.asset(
                    imagePath,
                    width: 92.w,
                    height: 92.w,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        fallbackEmoji,
                        style: TextStyle(fontSize: 64.sp, height: 1),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  label,
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
