import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class CompanionSelectScreen extends StatefulWidget {
  const CompanionSelectScreen({super.key});

  @override
  State<CompanionSelectScreen> createState() => _CompanionSelectScreenState();
}

class _CompanionSelectScreenState extends State<CompanionSelectScreen> {
  _CompanionType? _selected;

  @override
  Widget build(BuildContext context) {
    final enabled = _selected != null;

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
            '동행자 선택',
            textAlign: TextAlign.center,
            style: MTextStyles.lBodyM.copyWith(color: MColor.black100),
          ),
          SizedBox(height: 16.h),
          Text(
            '여행을 함께 할 예정인 동행자를 선택해주세요!',
            textAlign: TextAlign.center,
            style: MTextStyles.labelM.copyWith(color: MColor.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    final items = _CompanionType.values;

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
        final type = items[index];
        final selected = type == _selected;

        return _CompanionCard(
          label: type.label,
          imagePaths: type.imagePaths,
          fallbackEmojis: type.fallbackEmojis,
          selected: selected,
          onTap: () => setState(() => _selected = type),
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
    Navigator.pushNamed(context, AppRoutes.roadmapConcept);
  }
}

enum _CompanionType {
  solo,
  parents,
  friend,
  lover,
  child,
  family,
  coworker;

  String get label => switch (this) {
    _CompanionType.solo => '혼자',
    _CompanionType.parents => '부모님',
    _CompanionType.friend => '친구',
    _CompanionType.lover => '연인',
    _CompanionType.child => '아이',
    _CompanionType.family => '가족',
    _CompanionType.coworker => '직장 동료',
  };

  List<String> get fallbackEmojis => switch (this) {
    _CompanionType.solo => const ['🚶‍♂️'],
    _CompanionType.parents => const ['🚶‍♂️', '🚶‍♀️'],
    _CompanionType.friend => const ['🚶‍♂️', '🚶‍♂️'],
    _CompanionType.lover => const ['👫'],
    _CompanionType.child => const ['👶'],
    _CompanionType.family => const ['👨‍👩‍👧‍👦'],
    _CompanionType.coworker => const ['👨‍💼'],
  };

  List<String> get imagePaths => switch (this) {
    _CompanionType.solo => const ['assets/images/companion/alone.png'],
    _CompanionType.parents => const [
        'assets/images/companion/alone.png',
        'assets/images/companion/parent.png',
      ],
    _CompanionType.friend => const [
        'assets/images/companion/alone.png',
        'assets/images/companion/friend.png',
      ],
    _CompanionType.lover => const ['assets/images/companion/couple.png'],
    _CompanionType.child => const ['assets/images/companion/baby.png'],
    _CompanionType.family => const ['assets/images/companion/family.png'],
    _CompanionType.coworker => const ['assets/images/companion/worker.png'],
  };
}

class _CompanionCard extends StatelessWidget {
  const _CompanionCard({
    required this.label,
    required this.imagePaths,
    required this.fallbackEmojis,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final List<String> imagePaths;
  final List<String> fallbackEmojis;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final background = selected ? MColor.primary50 : MColor.white100;
    final borderWidth = selected ? 3.w : 2.w;

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
              SizedBox(height: 20.h),
              Expanded(
                child: Center(
                  child: imagePaths.length <= 1
                      ? _buildSingleImage()
                      : _buildMultipleImages(),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: Text(
                  label,
                  style: MTextStyles.labelM.copyWith(color: MColor.black100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleImage() {
    return Image.asset(
      imagePaths.first,
      width: 96.w,
      height: 96.w,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        final emoji = fallbackEmojis.isNotEmpty ? fallbackEmojis.first : '🙂';
        return Text(
          emoji,
          style: TextStyle(fontSize: 64.sp, height: 1),
        );
      },
    );
  }

  Widget _buildMultipleImages() {
    final iconSize = 100.w;
    if (imagePaths.length == 2) {
      final overlap = 74.w;
      final width = iconSize * 2 - overlap;

      return SizedBox(
        width: width,
        height: iconSize,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: _buildIconImage(index: 0, size: iconSize),
            ),
            Positioned(
              left: iconSize - overlap,
              top: -2.h,
              bottom: 0,
              child: _buildIconImage(index: 1, size: iconSize),
            ),
          ],
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < imagePaths.length; i++) ...[
          _buildIconImage(index: i, size: iconSize),
          if (i != imagePaths.length - 1) SizedBox(width: 8.w),
        ],
      ],
    );
  }

  Widget _buildIconImage({required int index, required double size}) {
    return Image.asset(
      imagePaths[index],
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        final emoji = index < fallbackEmojis.length ? fallbackEmojis[index] : '🙂';
        return SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              emoji,
              style: TextStyle(fontSize: 56.sp, height: 1),
            ),
          ),
        );
      },
    );
  }
}
