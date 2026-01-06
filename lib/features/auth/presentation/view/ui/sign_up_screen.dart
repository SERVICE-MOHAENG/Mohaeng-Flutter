import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view/widgets/auth_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _waveAnimation;
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController passwordCheckController;
  late final List<_SignUpStep> _steps;

  Color _waveColor = MColor.primary500;

  int currentIndex = 0;

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
    passwordController = TextEditingController();
    passwordCheckController = TextEditingController();
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
        secondaryLabel: '비밀번호 재확인',
        secondaryHintText: '비밀번호를 다시 입력해주세요.',
        secondaryController: passwordCheckController,
        secondaryKeyboardType: TextInputType.visiblePassword,
        secondaryTextInputAction: TextInputAction.done,
        secondaryObscureText: true,
      ),
    ];
  }

  void _startWave() {
    setState(() {
      _waveColor = MColor.primary500;
    });
    _controller.forward(from: 0);
  }

  void _handleNext() {
    _startWave();
    setState(() {
      if (currentIndex < _steps.length - 1) {
        currentIndex += 1;
      }
    });
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    passwordCheckController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MLayout(
      backgroundColor: MColor.white100,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildWavePainter(),
          ),
          Positioned(
            top: 40.h,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: _buildStepContent(),
            ),
          ),
        ],
      ),
      bottomSheet: _buildBottomSheet(() {
        Navigator.pop(context);
      }),
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

  Widget _buildBottomSheet(VoidCallback onTapSignUp) {
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
                '이미 계정이 있으신가요? ',
                style: MTextStyles.labelM.copyWith(color: MColor.gray500),
              ),
              GestureDetector(
                onTap: onTapSignUp,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                  child: Text(
                    '로그인',
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
          _buildCustomButton(() {
            _handleNext();
          }),
        ],
      ),
    );
  }

  Widget _buildCustomButton(VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 150.w),
        backgroundColor: MColor.primary500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
      ),
      child: Text(
        '다음',
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
          Text(
            step.subtitle,
            style: MTextStyles.labelM.copyWith(color: MColor.gray400),
          ),
          SizedBox(height: 30.h),
          _buildItem(step),
        ],
      ),
    );
  }

  Widget _buildItem(_SignUpStep step) {
    final hasSecondary = step.secondaryController != null;
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
        AuthTextField(
          controller: step.controller,
          hintText: step.hintText,
          keyboardType: step.keyboardType,
          textInputAction: step.textInputAction,
          obscureText: step.obscureText,
        ),
        if (hasSecondary) ...[
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
  final String? secondaryLabel;
  final String? secondaryHintText;
  final TextEditingController? secondaryController;
  final TextInputType? secondaryKeyboardType;
  final TextInputAction? secondaryTextInputAction;
  final bool secondaryObscureText;

  _SignUpStep({
    required this.title,
    required this.subtitle,
    required this.label,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.secondaryLabel,
    this.secondaryHintText,
    this.secondaryController,
    this.secondaryKeyboardType,
    this.secondaryTextInputAction,
    this.secondaryObscureText = false,
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
