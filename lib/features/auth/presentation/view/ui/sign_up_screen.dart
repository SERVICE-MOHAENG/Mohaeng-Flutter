import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/app_snack_bar.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view/ui/sign_up_survey_screen.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view/widgets/auth_text_field.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view/widgets/terms_bottom_sheet.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view_model/auth_providers.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view_model/sign_up_view_model.dart';
import 'package:pinput/pinput.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _codeTotalDuration = Duration(minutes: 3);
  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  late final AnimationController _controller;
  late final Animation<double> _waveAnimation;
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController emailCodeController;
  late final TextEditingController passwordController;
  late final TextEditingController passwordCheckController;
  late final List<_SignUpStep> _steps;

  Color _waveColor = MColor.primary500;
  Duration _codeTimeRemaining = _codeTotalDuration;
  Timer? _codeTimer;

  int currentIndex = 0;

  bool _hasLetter = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;
  bool _hasValidLength = false;
  bool _passwordsMatch = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _waveAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    nameController = TextEditingController();
    emailController = TextEditingController();
    emailCodeController = TextEditingController();
    passwordController = TextEditingController();
    passwordCheckController = TextEditingController();
    nameController.addListener(_handleInputChanged);
    emailController.addListener(_handleInputChanged);
    emailCodeController.addListener(_handleInputChanged);
    passwordController.addListener(_updatePasswordValidation);
    passwordCheckController.addListener(_updatePasswordValidation);
    _steps = [
      _SignUpStep(
        title: '사용자님의\n이름을 입력해주세요!',
        subtitle: '사용자님 성함을 정확히 입력해주세요!',
        label: '이름',
        hintText: 'ex.홍길동',
        controller: nameController,
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.next,
      ),
      _SignUpStep(
        title: '이메일을\n입력해주세요!',
        subtitle: '사용하실 이메일을 정확히 입력해주세요!',
        label: '이메일',
        hintText: 'example@email.com',
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.next,
        isEmailInput: true,
      ),
      _SignUpStep(
        title: '이메일로 전송된\n인증번호를 입력하세요',
        subtitle: '3:00분 내로 이메일로 전송된\n인증 번호 6자리를 정확히 입력해주세요!',
        label: '인증 코드',
        hintText: '',
        controller: emailCodeController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        isPinInput: true,
        pinLength: 6,
      ),
      _SignUpStep(
        title: '비밀번호를\n입력해주세요!',
        subtitle: '다른 사용자가\n유추하기 어렵게 설정해주세요!',
        label: '비밀번호',
        hintText: '비밀번호를 입력해주세요.',
        controller: passwordController,
        keyboardType: TextInputType.visiblePassword,
        textInputAction: TextInputAction.next,
        obscureText: true,
        showPasswordRules: true,
        secondaryLabel: '비밀번호 재확인',
        secondaryHintText: '비밀번호를 다시 입력해주세요.',
        secondaryController: passwordCheckController,
        secondaryKeyboardType: TextInputType.visiblePassword,
        secondaryTextInputAction: TextInputAction.done,
        secondaryObscureText: true,
        revealSecondaryWhenPrimaryFilled: true,
      ),
    ];
  }

  void _startWave() {
    setState(() {
      _waveColor = MColor.primary500;
    });
    _controller.forward(from: 0);
  }

  void _handleInputChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  bool get _isBusy {
    return ref.read(signUpViewModelProvider).isBusy;
  }

  void _startCodeTimer() {
    _codeTimer?.cancel();
    setState(() {
      _codeTimeRemaining = _codeTotalDuration;
    });
    _codeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_codeTimeRemaining.inSeconds <= 1) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _codeTimeRemaining = Duration.zero;
          });
        }
        return;
      }
      if (mounted) {
        setState(() {
          _codeTimeRemaining -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _stopCodeTimer() {
    _codeTimer?.cancel();
    _codeTimer = null;
  }

  void _moveToStep(int nextIndex, {bool animateWave = false}) {
    final leavingPin = _steps[currentIndex].isPinInput;
    final enteringPin = _steps[nextIndex].isPinInput;

    if (animateWave) {
      _startWave();
    }

    setState(() {
      currentIndex = nextIndex;
    });

    if (leavingPin && !enteringPin) {
      _stopCodeTimer();
    } else if (!leavingPin && enteringPin) {
      _startCodeTimer();
    }
  }

  void _updatePasswordValidation() {
    final password = passwordController.text;
    final confirm = passwordCheckController.text;

    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasNumber = RegExp(r'\d').hasMatch(password);
    final hasSpecial = RegExp(r'[^A-Za-z0-9]').hasMatch(password);
    final hasValidLength = password.length >= 8 && password.length <= 30;
    final passwordsMatch = confirm.isNotEmpty && password == confirm;

    setState(() {
      _hasLetter = hasLetter;
      _hasNumber = hasNumber;
      _hasSpecial = hasSpecial;
      _hasValidLength = hasValidLength;
      _passwordsMatch = passwordsMatch;
    });
  }

  bool get _isPasswordValid {
    return _hasLetter && _hasNumber && _hasSpecial && _hasValidLength;
  }

  bool _isCurrentStepValid() {
    final step = _currentStep;
    final primaryText = step.controller.text.trim();
    if (primaryText.isEmpty) {
      return false;
    }
    if (step.isPinInput && primaryText.length < step.pinLength) {
      return false;
    }
    if (step.isEmailInput && !_emailRegex.hasMatch(primaryText)) {
      return false;
    }
    if (step.secondaryController != null) {
      final secondaryText = step.secondaryController!.text.trim();
      final requiresSecondary =
          !step.revealSecondaryWhenPrimaryFilled || primaryText.isNotEmpty;
      if (requiresSecondary && secondaryText.isEmpty) {
        return false;
      }
    }
    if (step.showPasswordRules) {
      if (!_isPasswordValid) {
        return false;
      }
      if (!_passwordsMatch) {
        return false;
      }
    }
    return true;
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

  Future<void> _submitSignUp(BuildContext context) async {
    final result = await ref
        .read(signUpViewModelProvider.notifier)
        .submit(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          passwordConfirm: passwordCheckController.text,
        );

    if (!mounted) {
      return;
    }
    if (result.isSuccess) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              SignUpSurveyScreen(userName: nameController.text.trim()),
        ),
      );
      return;
    }
    if (result.message != null) {
      _showSnack(result.message!, fallbackMessage: '회원가입에 실패했어요.');
    }
  }

  Future<void> _sendEmailOtp() async {
    final result = await ref
        .read(signUpViewModelProvider.notifier)
        .sendEmailOtp(email: emailController.text.trim());
    if (result.isSuccess) {
      return;
    }
    if (result.message != null) {
      _showSnack(result.message!, fallbackMessage: '인증번호 전송에 실패했어요.');
    }
    throw Exception(result.message ?? '인증번호 전송에 실패했어요.');
  }

  Future<void> _verifyEmailOtp() async {
    final result = await ref
        .read(signUpViewModelProvider.notifier)
        .verifyEmailOtp(
          email: emailController.text.trim(),
          otp: emailCodeController.text.trim(),
        );
    if (result.isSuccess) {
      return;
    }
    if (result.message != null) {
      _showSnack(result.message!, fallbackMessage: '인증번호 확인에 실패했어요.');
    }
    throw Exception(result.message ?? '인증번호 확인에 실패했어요.');
  }

  Future<void> _handleResendOtp() async {
    if (ref.read(signUpViewModelProvider).isOtpSending) {
      return;
    }
    if (!_emailRegex.hasMatch(emailController.text.trim())) {
      _showSnack('이메일 형식을 확인해주세요.');
      return;
    }

    try {
      await _sendEmailOtp();
      emailCodeController.clear();
      _startCodeTimer();
    } catch (_) {}
  }

  Future<bool?> _showTermsBottomSheet() {
    FocusScope.of(context).unfocus();
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          TermsBottomSheet(onConfirm: () => Navigator.of(context).pop(true)),
    );
  }

  Future<void> _handleNext(BuildContext context) async {
    if (_isBusy) {
      return;
    }
    if (!_isCurrentStepValid()) {
      return;
    }
    if (_currentStep.isEmailInput) {
      try {
        await _sendEmailOtp();
        _moveToStep(currentIndex + 1, animateWave: true);
      } catch (_) {}
      return;
    }
    if (_currentStep.isPinInput) {
      try {
        await _verifyEmailOtp();
        _moveToStep(currentIndex + 1, animateWave: true);
      } catch (_) {}
      return;
    }
    if (currentIndex >= _steps.length - 1) {
      final agreed = await _showTermsBottomSheet();
      if (agreed == true) {
        await _submitSignUp(context);
      }
      return;
    }
    _moveToStep(currentIndex + 1, animateWave: true);
  }

  void _handleBack(BuildContext context) {
    if (currentIndex > 0) {
      _moveToStep(currentIndex - 1);
      return;
    }
    Navigator.pop(context);
  }

  _SignUpStep get _currentStep {
    final maxIndex = _steps.length - 1;
    final index = currentIndex < 0
        ? 0
        : (currentIndex > maxIndex ? maxIndex : currentIndex);
    return _steps[index];
  }

  @override
  void dispose() {
    _controller.dispose();
    _codeTimer?.cancel();
    nameController.dispose();
    emailController.dispose();
    emailCodeController.dispose();
    passwordController.dispose();
    passwordCheckController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final signUpState = ref.watch(signUpViewModelProvider);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Stack(
      children: [
        MLayout(
          backgroundColor: MColor.white100,
          body: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(top: 0, left: 0, right: 0, child: _buildWavePainter()),
              Positioned(
                top: 6.h,
                left: 4.w,
                child: SafeArea(bottom: false, child: _buildBackButton()),
              ),
              Positioned(
                top: 70.h,
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  bottom: false,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final allowScroll = bottomInset > 0;
                      return SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        physics: allowScroll
                            ? const ClampingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: allowScroll ? 140.h + bottomInset : 0,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: _buildStepContent(),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: AnimatedPadding(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: EdgeInsets.only(bottom: bottomInset),
            child: _buildBottomSheet(() {
              Navigator.pop(context);
            }, signUpState),
          ),
        ),
        if (signUpState.isBusy) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Positioned.fill(
      child: AbsorbPointer(
        absorbing: true,
        child: Container(
          color: MColor.black100.withOpacity(0.2),
          child: Center(
            child: SizedBox(
              width: 32.r,
              height: 32.r,
              child: CircularProgressIndicator(
                strokeWidth: 3.r,
                valueColor: AlwaysStoppedAnimation<Color>(MColor.primary500),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWavePainter() {
    return SizedBox(
      height: 320.h,
      child: AnimatedBuilder(
        animation: _waveAnimation,
        builder: (_, __) {
          return CustomPaint(
            painter: WavePainter(
              progress: _waveAnimation.value,
              color: _waveColor,
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }

  Widget _buildBackButton() {
    return IconButton(
      onPressed: () => _handleBack(context),
      icon: Icon(Icons.arrow_back_ios_new_rounded, color: MColor.gray700),
      splashRadius: 18.r,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildBottomSheet(
    VoidCallback onTapSignUp,
    SignUpViewState signUpState,
  ) {
    final isLastStep = currentIndex >= _steps.length - 1;
    final buttonLabel = isLastStep ? '가입하기' : '다음';
    final isPinStep = _currentStep.isPinInput;
    final helperText = isPinStep ? '인증 코드가 오지 않았을 경우 ' : '이미 계정이 있으신가요? ';
    final actionText = isPinStep ? '재전송' : '로그인';
    final isEnabled = !signUpState.isBusy && _isCurrentStepValid();
    return Padding(
      padding: EdgeInsets.only(bottom: 32.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                helperText,
                style: MTextStyles.labelM.copyWith(color: MColor.gray500),
              ),
              GestureDetector(
                onTap: isPinStep ? _handleResendOtp : onTapSignUp,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                  child: Text(
                    actionText,
                    style: MTextStyles.labelM.copyWith(
                      color: MColor.primary500,
                      decoration: TextDecoration.underline,
                      decorationColor: MColor.primary500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15.h),
          _buildCustomButton(
            isEnabled ? () => _handleNext(context) : null,
            label: buttonLabel,
            enabled: isEnabled,
          ),
        ],
      ),
    );
  }

  Widget _buildCustomButton(
    VoidCallback? onPressed, {
    required String label,
    required bool enabled,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 150.w),
        backgroundColor: enabled ? MColor.primary500 : MColor.primary300,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'GmarketSansMedium',
          fontSize: 12.sp,
          color: MColor.white100,
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    final step = _currentStep;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            step.title,
            style: MTextStyles.lBodyM.copyWith(color: MColor.black100),
          ),
          _buildSubtitle(step),
          SizedBox(height: 30.h),
          _buildItem(step),
        ],
      ),
    );
  }

  Widget _buildSubtitle(_SignUpStep step) {
    if (!step.isPinInput) {
      return Text(
        step.subtitle,
        style: MTextStyles.labelM.copyWith(color: MColor.gray400),
      );
    }

    final minutes = _codeTimeRemaining.inMinutes;
    final seconds = _codeTimeRemaining.inSeconds % 60;
    final timeText = '$minutes:${seconds.toString().padLeft(2, '0')}';

    return RichText(
      text: TextSpan(
        style: MTextStyles.labelM.copyWith(color: MColor.gray400),
        children: [
          TextSpan(
            text: timeText,
            style: MTextStyles.labelM.copyWith(color: MColor.primary500),
          ),
          const TextSpan(text: '분 내로 이메일로 전송된\n인증 번호 6자리를 정확히 입력해주세요!'),
        ],
      ),
    );
  }

  Widget _buildItem(_SignUpStep step) {
    final hasSecondary = step.secondaryController != null;
    final showSecondary =
        hasSecondary &&
        (!step.revealSecondaryWhenPrimaryFilled ||
            step.controller.text.trim().isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          step.label,
          style: TextStyle(
            fontFamily: 'GmarketSansMedium',
            fontSize: 12.sp,
            color: MColor.gray700,
          ),
        ),
        SizedBox(height: 10.h),
        if (!step.isPinInput)
          AuthTextField(
            controller: step.controller,
            hintText: step.hintText,
            keyboardType: step.keyboardType,
            textInputAction: step.textInputAction,
            obscureText: step.obscureText,
          )
        else
          _buildPinInput(step),
        if (showSecondary) ...[
          SizedBox(height: 16.h),
          Text(
            step.secondaryLabel ?? '',
            style: TextStyle(
              fontFamily: 'GmarketSansMedium',
              fontSize: 12.sp,
              color: MColor.gray700,
            ),
          ),
          SizedBox(height: 10.h),
          AuthTextField(
            controller: step.secondaryController!,
            hintText: step.secondaryHintText ?? '',
            keyboardType: step.secondaryKeyboardType,
            textInputAction: step.secondaryTextInputAction,
            obscureText: step.secondaryObscureText,
          ),
        ],
      ],
    );
  }

  Widget _buildPinInput(_SignUpStep step) {
    final baseTheme = PinTheme(
      width: 45.w,
      height: 55.w,
      textStyle: MTextStyles.bodyM.copyWith(color: MColor.gray800),
      decoration: BoxDecoration(
        color: MColor.gray100,
        borderRadius: BorderRadius.circular(8.r),
      ),
    );

    return Align(
      alignment: Alignment.center,
      child: Pinput(
        controller: step.controller,
        length: step.pinLength,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        defaultPinTheme: baseTheme,
        focusedPinTheme: baseTheme.copyWith(
          decoration: BoxDecoration(
            color: MColor.white100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: MColor.primary500, width: 1.w),
          ),
        ),
        submittedPinTheme: baseTheme.copyWith(
          decoration: BoxDecoration(
            color: MColor.white100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: MColor.gray200, width: 1.w),
          ),
        ),
        separatorBuilder: (_) => SizedBox(width: 8.w),
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}

class _SignUpStep {
  final String title;
  final String subtitle;
  final String label;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool showPasswordRules;
  final String? secondaryLabel;
  final String? secondaryHintText;
  final TextEditingController? secondaryController;
  final TextInputType? secondaryKeyboardType;
  final TextInputAction? secondaryTextInputAction;
  final bool secondaryObscureText;
  final bool isPinInput;
  final int pinLength;
  final bool isEmailInput;
  final bool revealSecondaryWhenPrimaryFilled;

  _SignUpStep({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.showPasswordRules = false,
    this.secondaryLabel,
    this.secondaryHintText,
    this.secondaryController,
    this.secondaryKeyboardType,
    this.secondaryTextInputAction,
    this.secondaryObscureText = false,
    this.isPinInput = false,
    this.pinLength = 6,
    this.isEmailInput = false,
    this.revealSecondaryWhenPrimaryFilled = false,
  });
}

class WavePainter extends CustomPainter {
  final double progress;
  final Color color;

  WavePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    final waveHeight = size.height * 0.07;
    final waveLength = size.width * 1.5;
    final shift = progress * 2 * pi;
    final baseY = size.height * 0.2;

    path.moveTo(0, baseY);

    for (double x = 0; x <= size.width; x++) {
      final y = baseY + sin((x / waveLength * 2 * pi) + shift) * waveHeight;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant WavePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
