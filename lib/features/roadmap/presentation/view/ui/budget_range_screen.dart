import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_types.dart';

class BudgetRangeScreen extends ConsumerStatefulWidget {
  const BudgetRangeScreen({super.key});

  @override
  ConsumerState<BudgetRangeScreen> createState() => _BudgetRangeScreenState();
}

class _BudgetRangeScreenState extends ConsumerState<BudgetRangeScreen> {
  final List<_BudgetOption> _options = const [
    _BudgetOption(
      value: BudgetRange.LOW,
      label: '가성비 / 저예산',
      emoji: '💸',
    ),
    _BudgetOption(
      value: BudgetRange.MID,
      label: '기본 / 적당한',
      emoji: '💰',
    ),
    _BudgetOption(
      value: BudgetRange.HIGH,
      label: '프리미엄',
      emoji: '✨',
    ),
    _BudgetOption(
      value: BudgetRange.LUXURY,
      label: '럭셔리',
      emoji: '💎',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final budgetState = ref.watch(budgetRangeViewModelProvider);
    final enabled = budgetState.range != null;

    return MLayout(
      backgroundColor: MColor.white100,
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 16.w),
        child: _buildCompleteButton(enabled: enabled),
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
                    SizedBox(height: 44.h),
                    _buildBudgetOptions(budgetState.range),
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
            '예산 범위',
            textAlign: TextAlign.center,
            style: MTextStyles.lBodyM.copyWith(color: MColor.black100),
          ),
          SizedBox(height: 16.h),
          Text(
            '어느 정도의 예산으로 여행을 준비하고 계신가요?',
            textAlign: TextAlign.center,
            style: MTextStyles.labelM.copyWith(color: MColor.gray400),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetOptions(BudgetRange? selected) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14.h,
        crossAxisSpacing: 14.w,
        childAspectRatio: 1.1,
      ),
      itemBuilder: (context, index) {
        final option = _options[index];
        final isSelected = option.value == selected;

        return _BudgetOptionCard(
          option: option,
          selected: isSelected,
          onTap: () => ref
              .read(budgetRangeViewModelProvider.notifier)
              .setRange(option.value),
        );
      },
    );
  }

  Widget _buildCompleteButton({required bool enabled}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled
            ? () => Navigator.pushNamed(
                  context,
                  AppRoutes.roadmapAdditionalRequest,
                )
            : null,
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
          '완료',
          style: MTextStyles.labelM.copyWith(
            color: enabled ? MColor.white100 : MColor.gray300,
          ),
        ),
      ),
    );
  }
}

class _BudgetOption {
  const _BudgetOption({
    required this.value,
    required this.label,
    required this.emoji,
  });

  final BudgetRange value;
  final String label;
  final String emoji;
}

class _BudgetOptionCard extends StatelessWidget {
  const _BudgetOptionCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _BudgetOption option;
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
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(option.emoji, style: TextStyle(fontSize: 34.sp, height: 1)),
              SizedBox(height: 12.h),
              Text(
                option.label,
                textAlign: TextAlign.center,
                style: MTextStyles.labelM.copyWith(color: MColor.black100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
