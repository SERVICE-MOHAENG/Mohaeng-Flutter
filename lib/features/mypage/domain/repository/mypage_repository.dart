import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';

abstract class MyPageRepository {
  Future<CoursesResponse> getMyCourses({int page = 1, int limit = 20});

  Future<CourseItemsResponse> getMyCourseBookmarks({
    int page = 1,
    int limit = 20,
  });

  Future<CourseItemsResponse> getMyCourseLikes({int page = 1, int limit = 20});
}
