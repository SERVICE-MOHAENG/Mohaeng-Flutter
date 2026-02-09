import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view_model/roadmap_providers.dart';

class BudgetRangeScreen extends ConsumerStatefulWidget {
  const BudgetRangeScreen({super.key});

  @override
  ConsumerState<BudgetRangeScreen> createState() => _BudgetRangeScreenState();
}

class _BudgetRangeScreenState extends ConsumerState<BudgetRangeScreen> {
  late final TextEditingController _minBudgetController;
  late final TextEditingController _maxBudgetController;

  @override
  void initState() {
    super.initState();
    _minBudgetController = TextEditingController();
    _maxBudgetController = TextEditingController();
  }

  @override
  void dispose() {
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MLayout(
      backgroundColor: MColor.white100,
      bottomSheet: Padding(
        padding: EdgeInsets.symmetric(vertical: 45.h, horizontal: 16.w),
        child: _buildCompleteButton(),
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
                    _buildSectionLabel('최소 경비'),
                    SizedBox(height: 8.h),
                    _buildAmountField(
                      controller: _minBudgetController,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => ref
                          .read(budgetRangeViewModelProvider.notifier)
                          .setMin(value),
                    ),
                    SizedBox(height: 22.h),
                    _buildSectionLabel('최대 경비'),
                    SizedBox(height: 8.h),
                    _buildAmountField(
                      controller: _maxBudgetController,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                      onChanged: (value) => ref
                          .read(budgetRangeViewModelProvider.notifier)
                          .setMax(value),
                    ),
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

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: MTextStyles.bodyM.copyWith(color: MColor.black100),
    );
  }

  Widget _buildAmountField({
    required TextEditingController controller,
    required TextInputAction textInputAction,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      style: MTextStyles.bodyM.copyWith(color: MColor.gray800),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: MColor.white100,
        hintText: '원',
        hintStyle: MTextStyles.labelM.copyWith(color: MColor.gray300),
        contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 13.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide(color: MColor.gray200, width: 1.w),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6.r),
          borderSide: BorderSide(color: MColor.gray200, width: 1.w),
        ),
      ),
    );
  }

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, AppRoutes.roadmapAdditionalRequest);
        },
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: MColor.primary500,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6.r),
          ),
        ),
        child: Text(
          '완료',
          style: MTextStyles.labelM.copyWith(color: MColor.white100),
        ),
      ),
    );
  }
}
