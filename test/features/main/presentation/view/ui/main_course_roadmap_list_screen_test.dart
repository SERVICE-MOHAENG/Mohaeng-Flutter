import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/ui/main_course_roadmap_list_screen.dart';

void main() {
  testWidgets('renders roadmap list screen and opens detail action', (
    tester,
  ) async {
    const course = CourseResponse(
      title: '시부야 밤거리',
      countryCode: 'JP',
      days: 1,
      tags: <String>['#당일치기', '#친구'],
    );
    CourseResponse? openedCourse;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, __) {
          return MaterialApp(
            home: MainCourseRoadmapListScreen(
              courses: const <CourseResponse>[course],
              onOpenCourseDetail: (value) => openedCourse = value,
            ),
          );
        },
      ),
    );

    expect(find.text('로드맵 보기'), findsOneWidget);
    expect(find.text('시부야 밤거리'), findsOneWidget);
    expect(find.text('바로가기'), findsOneWidget);

    await tester.tap(find.text('바로가기'));
    await tester.pumpAndSettle();

    expect(openedCourse, same(course));
  });

  testWidgets('shows empty state when courses are empty', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, __) {
          return const MaterialApp(
            home: MainCourseRoadmapListScreen(
              courses: <CourseResponse>[],
              onOpenCourseDetail: _noopCourseCallback,
            ),
          );
        },
      ),
    );

    expect(find.text('로드맵 보기'), findsOneWidget);
    expect(find.text('조회할 로드맵이 아직 없어요.'), findsOneWidget);
    expect(find.text('바로가기'), findsNothing);
  });
}

void _noopCourseCallback(CourseResponse _) {}
