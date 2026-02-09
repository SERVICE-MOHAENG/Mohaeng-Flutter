import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:mohaeng_app_service/core/constants/app_routes.dart';
import 'package:mohaeng_app_service/core/mohaeng/m_color.dart';
import 'package:mohaeng_app_service/core/widgets/m_tab.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view/ui/login_screen.dart';
import 'package:mohaeng_app_service/features/auth/presentation/view/ui/sign_up_screen.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/ui/main_screen.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view/ui/additional_request_screen.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view/ui/budget_range_screen.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view/ui/companion_select_screen.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view/ui/concept_select_screen.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view/ui/people_select_screen.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view/ui/region_select_screen.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view/ui/schedule_select_screen.dart';
import 'package:mohaeng_app_service/features/roadmap/presentation/view/ui/travel_style_select_screen.dart';
import 'package:mohaeng_app_service/features/splash/presentation/ui/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  KakaoSdk.init(nativeAppKey: dotenv.env['KAKAO_NATIVE_KEY']);

  runApp(const ProviderScope(child: MyApp()));
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
          AppRoutes.root: (_) => MTab(),
          AppRoutes.roadmap: (_) => RegionSelectScreen(),
          AppRoutes.roadmapSchedule: (_) => ScheduleSelectScreen(),
          AppRoutes.roadmapPeople: (_) => PeopleSelectScreen(),
          AppRoutes.roadmapCompanion: (_) => CompanionSelectScreen(),
          AppRoutes.roadmapConcept: (_) => ConceptSelectScreen(),
          AppRoutes.roadmapTravelStyle: (_) => TravelStyleSelectScreen(),
          AppRoutes.roadmapBudgetRange: (_) => BudgetRangeScreen(),
          AppRoutes.roadmapAdditionalRequest: (_) => AdditionalRequestScreen(),
        },
      ),
    );
  }
}
