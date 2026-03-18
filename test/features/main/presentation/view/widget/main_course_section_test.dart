import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/presentation/view/widget/main_course_section.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_courses_view_model.dart';

void main() {
  testWidgets('shows roadmap button and card action button with one course', (
    tester,
  ) async {
    const course = CourseResponse(
      id: 'course-1',
      title: '시부야 밤거리',
      countryCode: 'JP',
      nights: 0,
      days: 1,
      tags: <String>['#당일치기', '#친구'],
      places: <CoursePlaceResponse>[
        CoursePlaceResponse(name: '시부야', order: 1, dayNumber: 1),
        CoursePlaceResponse(name: '신주쿠', order: 2, dayNumber: 1),
      ],
    );
    var openedRoadmapList = false;
    CourseResponse? openedCourseDetail;

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        builder: (_, __) {
          return MaterialApp(
            home: Scaffold(
              body: MainCourseSection(
                coursesState: const MainCoursesState(
                  courses: <CourseResponse>[course],
                ),
                onSelectCountry: (_) {},
                onToggleLike: (_) {},
                onOpenRoadmap: () => openedRoadmapList = true,
                onOpenCourseDetail: (value) => openedCourseDetail = value,
              ),
            ),
          );
        },
      ),
    );

    expect(find.text('로드맵 보러가기'), findsOneWidget);
    expect(find.text('바로가기'), findsOneWidget);
    expect(find.text('시부야 밤거리'), findsOneWidget);

    await tester.tap(find.text('바로가기'));
    await tester.pumpAndSettle();

    expect(openedCourseDetail, same(course));

    await tester.tap(find.text('로드맵 보러가기'));
    await tester.pumpAndSettle();

    expect(openedRoadmapList, isTrue);
  });

  testWidgets(
    'shows empty state and roadmap button when courses list is empty',
    (tester) async {
      var openedRoadmapList = false;
      CourseResponse? openedCourseDetail;

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          builder: (_, __) {
            return MaterialApp(
              home: Scaffold(
                body: MainCourseSection(
                  coursesState: const MainCoursesState(),
                  onSelectCountry: (_) {},
                  onToggleLike: (_) {},
                  onOpenRoadmap: () => openedRoadmapList = true,
                  onOpenCourseDetail: (value) => openedCourseDetail = value,
                ),
              ),
            );
          },
        ),
      );

      expect(find.text('로드맵 보러가기'), findsOneWidget);
      expect(find.text('바로가기'), findsNothing);
      expect(find.text('표시할 여행 코스가 없어요.'), findsOneWidget);
      expect(openedCourseDetail, isNull);

      await tester.tap(find.text('로드맵 보러가기'));
      await tester.pumpAndSettle();

      expect(openedRoadmapList, isTrue);
    },
  );
}
