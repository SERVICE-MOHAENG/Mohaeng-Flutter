import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_types.dart';

class ConceptSelectScreen extends ConsumerStatefulWidget {
  const ConceptSelectScreen({super.key});

  @override
  ConsumerState<ConceptSelectScreen> createState() =>
      _ConceptSelectScreenState();
}

class _ConceptSelectScreenState extends ConsumerState<ConceptSelectScreen> {
  @override
  Widget build(BuildContext context) {
    final conceptState = ref.watch(conceptSelectViewModelProvider);
    final enabled = conceptState.selected.isNotEmpty;

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
                child: _buildGrid(conceptState.selected),
              ),
            ),
            SizedBox(height: 16.h),
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

  Widget _buildGrid(Set<TravelConcept> selectedSet) {
    final items = TravelConcept.values;

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
        final selected = selectedSet.contains(concept);

        return _ConceptCard(
          label: concept.label,
          imagePath: concept.imagePath,
          fallbackEmoji: concept.fallbackEmoji,
          selected: selected,
          onTap: () =>
              ref.read(conceptSelectViewModelProvider.notifier).toggle(concept),
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
    Navigator.pushNamed(context, AppRoutes.roadmapTravelStyle);
  }
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
