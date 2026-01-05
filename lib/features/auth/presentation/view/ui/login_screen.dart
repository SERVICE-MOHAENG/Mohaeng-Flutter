import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_images.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_text_styles.dart';
import 'package:mohaeng_app_service/core/widgets/m_layout.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_api.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view/widgets/Oauth_button.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view/widgets/auth_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final AuthApi _authApi;
  late final AuthTokenStorage _tokenStorage;

  bool _keepLogin = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _tokenStorage = AuthTokenStorage();
    _authApi = AuthApi(tokenStorage: _tokenStorage);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MLayout(
      backgroundColor: MColor.white100,
      body: Column(
        children: [
          _buildAppBar(),
          SizedBox(height: 25.h),
          _buildEmailLogin(),
          SizedBox(height: 25.h),
          _buildAuth(),
          SizedBox(height: 35.h),
          _buildOAuth(
            onTapSignUp: () {
              //TODO 회원가입 로직 추가
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Stack(
      children: [
        Positioned(
          child: Image.asset(
            MImages.blockImage,
            width: 632.w,
            height: 230.h,
            fit: BoxFit.cover,
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(top: 115.h),
            child: _buildTitle(),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              MImages.mohaengLogo,
              width: 35.w,
              height: 35.h,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 12.w),
            Text(
              'MoHaeng',
              style: TextStyle(
                fontFamily: 'GmarketSansBold',
                color: MColor.white100,
                fontSize: 27.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 15.h),
        Text(
          '모두의 여행 계획, 모행',
          style: MTextStyles.bodyM.copyWith(color: MColor.white100),
        ),
      ],
    );
  }

  Widget _buildEmailLogin() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          _buildLoginItem('이메일', 'example@email.com', _emailController),
          SizedBox(height: 15.h),
          _buildLoginItem('비밀번호', '비밀번호를 입력해주세요.', _passwordController),
        ],
      ),
    );
  }

  Widget _buildLoginItem(
    String text,
    String hintText,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: TextStyle(
            fontFamily: 'GmarketSansMedium',
            fontSize: 12.sp,
            color: MColor.gray700,
          ),
        ),
        SizedBox(height: 10.h),
        AuthTextField(controller: controller, hintText: hintText),
      ],
    );
  }

  Widget _buildAuth() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 상단: 로그인 유지 / 비밀번호 찾기
          Row(
            children: [
              // 체크박스 + 텍스트
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.scale(
                    scale: 0.9, // 이미지처럼 조금 작게
                    child: SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: Checkbox(
                        value: _keepLogin,
                        onChanged: (v) {
                          setState(() {
                            _keepLogin = v ?? false;
                          });
                        },
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                        side: BorderSide(
                          color: const Color(0xFFBDBDBD),
                          width: 1.w,
                        ),
                        activeColor: const Color(0xFF22C9FF),
                        checkColor: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '로그인 유지',
                    style: TextStyle(
                      fontFamily: 'GmarketSansMedium',
                      fontSize: 12.sp,
                      color: MColor.gray500,
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // 비밀번호 찾기
              GestureDetector(
                onTap: () {
                  // TODO: 비밀번호 찾기 화면/다이얼로그로 이동
                },
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 4.w),
                  child: Text(
                    '비밀번호 찾기',
                    style: TextStyle(
                      fontFamily: 'GmarketSansMedium',
                      fontSize: 12.sp,
                      color: MColor.gray500,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10.h),

          // 하단: 로그인 버튼
          SizedBox(
            height: 44.h,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: MColor.primary500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.r),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _authApi.login(email: email, password: password);
      final payload = _extractTokenPayload(response);
      final accessToken = payload['accessToken'];
      final refreshToken = payload['refreshToken'];

      if (accessToken is! String || refreshToken is! String) {
        throw const FormatException('토큰이 없습니다.');
      }

      await _tokenStorage.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      if (!mounted) return;
      _showMessage('로그인 성공');
      // TODO: 로그인 성공 후 화면 이동 로직
    } catch (error) {
      if (!mounted) return;
      _showMessage('로그인 실패: $error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _extractTokenPayload(Map<String, dynamic> response) {
    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return response;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildOAuth({required VoidCallback onTapSignUp}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: [
          // 1) 아직 계정이 없으신가요? 회원가입
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '아직 계정이 없으신가요? ',
                style: MTextStyles.labelM.copyWith(color: MColor.gray500),
              ),
              GestureDetector(
                onTap: onTapSignUp,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
                  child: Text(
                    '회원가입',
                    style: MTextStyles.labelM.copyWith(
                      color: MColor.primary500,
                      decoration: TextDecoration.underline,
                      decorationColor: MColor.primary500
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // 2) 구분선 + SNS로 더 간편하게
          Row(
            children: [
              Expanded(
                child: Container(height: 1.h, color: MColor.gray300),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                child: Text(
                  'SNS로 더 간편하게',
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: MColor.gray300,
                    fontFamily: 'GmarketSansMedium'
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1.h, color: MColor.gray300),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // 3) OAuth 버튼들
          OauthButton(
            label: 'Google로 계속하기',
            textColor: MColor.black100,
            backgroundColor: MColor.white100,
            imagePath: MImages.googleLogo,
            borderColor: MColor.gray200,
            onPressed: () {
              //TODO 구글 오어스 로직 추가
            },
          ),
          SizedBox(height: 8.h),
          OauthButton(
            label: '카카오로 계속하기',
            textColor: MColor.black100,
            backgroundColor: MColor.yellow100,
            imagePath: MImages.kakaoLogo,
            borderColor: MColor.yellow100,
            onPressed: () {
              //TODO 카카오 오어스 로직 추가
            },
          ),
          SizedBox(height: 8.h),
          OauthButton(
            label: '네이버로 계속하기',
            textColor: MColor.white100,
            backgroundColor: MColor.green100,
            imagePath: MImages.naverLogo,
            borderColor: MColor.green100,
            onPressed: () {
              //TODO 네이버 오어스 로직 추가
            },
          ),
        ],
      ),
    );
  }
}
