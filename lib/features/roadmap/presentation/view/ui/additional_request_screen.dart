import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';

class AdditionalRequestScreen extends StatefulWidget {
  const AdditionalRequestScreen({super.key});

  @override
  State<AdditionalRequestScreen> createState() =>
      _AdditionalRequestScreenState();
}

class _AdditionalRequestScreenState extends State<AdditionalRequestScreen> {
  late final TextEditingController _requestController;

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

  Widget _buildCompleteButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _onTapComplete,
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

  void _onTapComplete() {
    Navigator.popUntil(
      context,
      (route) =>
          route.settings.name == AppRoutes.roadmapConcept || route.isFirst,
    );
  }
}
