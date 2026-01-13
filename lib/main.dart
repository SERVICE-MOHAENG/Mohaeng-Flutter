import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view/ui/login_screen.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view/ui/sign_up_screen.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/ui/main_screen.dart';
import 'package:mohaeng_app_service/features/splash/presentation/ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_KEY']);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Pretendard',
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: MColor.white100,
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => SplashScreen(),
          AppRoutes.login: (_) => LoginScreen(),
          AppRoutes.signup: (_) => SignUpScreen(),
          AppRoutes.main: (_) => MainScreen(),
        },
      ),
    );
  }
}
