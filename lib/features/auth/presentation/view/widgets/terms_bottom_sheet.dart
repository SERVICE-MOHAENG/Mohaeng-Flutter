import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';

class TermsBottomSheet extends StatefulWidget {
  const TermsBottomSheet({
    super.key,
    required this.onConfirm,
    this.onServiceTermsTap,
    this.onPrivacyTermsTap,
    this.onMarketingTermsTap,
  });

  final VoidCallback onConfirm;
  final VoidCallback? onServiceTermsTap;
  final VoidCallback? onPrivacyTermsTap;
  final VoidCallback? onMarketingTermsTap;

  @override
  State<TermsBottomSheet> createState() => _TermsBottomSheetState();
}

class _TermsBottomSheetState extends State<TermsBottomSheet> {
  bool allAgree = false;

  bool serviceAgree = false; // 필수
  bool privacyAgree = false; // 필수
  bool marketingAgree = false; // 선택

  bool get canConfirm => serviceAgree && privacyAgree;

  void _setAll(bool value) {
    setState(() {
      allAgree = value;
      serviceAgree = value;
      privacyAgree = value;
      marketingAgree = value;
    });
  }

  void _syncAll() {
    allAgree = serviceAgree && privacyAgree && marketingAgree;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          color: MColor.white100,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 16.h),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: MColor.gray100,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              Text(
                '잠깐!\n이용약관을 확인해주세요!',
                style: MTextStyles.lBodyM.copyWith(color: MColor.gray900),
              ),
              SizedBox(height: 18.h),
              _AgreeRow(
                title: '약관 전체 동의',
                checked: allAgree,
                onTap: () => _setAll(!allAgree),
                trailingType: _TrailingType.circleCheck,
              ),
              SizedBox(height: 10.h),
              Divider(height: 1.h, color: MColor.gray100),
              SizedBox(height: 10.h),
              _AgreeRow(
                title: '서비스 이용 약관 동의 (필수)',
                checked: serviceAgree,
                onTap: () {
                  setState(() {
                    serviceAgree = !serviceAgree;
                    _syncAll();
                  });
                },
                onArrowTap: widget.onServiceTermsTap,
                trailingType: _TrailingType.arrow,
              ),
              _AgreeRow(
                title: '개인정보 수집·이용 동의 (필수)',
                checked: privacyAgree,
                onTap: () {
                  setState(() {
                    privacyAgree = !privacyAgree;
                    _syncAll();
                  });
                },
                onArrowTap: widget.onPrivacyTermsTap,
                trailingType: _TrailingType.arrow,
              ),
              _AgreeRow(
                title: '마케팅 정보 수신 동의 (선택)',
                checked: marketingAgree,
                onTap: () {
                  setState(() {
                    marketingAgree = !marketingAgree;
                    _syncAll();
                  });
                },
                onArrowTap: widget.onMarketingTermsTap,
                trailingType: _TrailingType.arrow,
              ),
              SizedBox(height: 18.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  onPressed: canConfirm ? widget.onConfirm : null,
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    backgroundColor: MColor.primary500,
                    disabledBackgroundColor: MColor.primary300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    '다음',
                    style: MTextStyles.bodyB.copyWith(
                      color: MColor.white100.withOpacity(
                        canConfirm ? 1 : 0.9,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _TrailingType { circleCheck, arrow }

class _AgreeRow extends StatelessWidget {
  const _AgreeRow({
    required this.title,
    required this.checked,
    required this.onTap,
    required this.trailingType,
    this.onArrowTap,
  });

  final String title;
  final bool checked;
  final VoidCallback onTap;
  final _TrailingType trailingType;
  final VoidCallback? onArrowTap;

  @override
  Widget build(BuildContext context) {
    final isAllRow = trailingType == _TrailingType.circleCheck;
    final textStyle = (isAllRow ? MTextStyles.bodyM : MTextStyles.bodyM)
        .copyWith(color: isAllRow ? MColor.black100 : MColor.gray400);

    return InkWell(

      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            _CircleCheck(checked: checked),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: textStyle,
              ),
            ),
            if (trailingType == _TrailingType.arrow)
              InkWell(
                onTap: onArrowTap,
                borderRadius: BorderRadius.circular(10.r),
                child: Padding(
                  padding: EdgeInsets.all(6.r),
                  child: Icon(
                    Icons.chevron_right,
                    color: MColor.gray300,
                    size: 22.r,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleCheck extends StatelessWidget {
  const _CircleCheck({required this.checked});
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.r,
      height: 22.r,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: checked ? MColor.primary500 : MColor.gray200,
          width: 2.w,
        ),
        color: checked ? MColor.primary500 : Colors.transparent,
      ),
      child: checked
          ? Icon(Icons.check, size: 14.r, color: MColor.white100)
          : null,
    );
  }
}
