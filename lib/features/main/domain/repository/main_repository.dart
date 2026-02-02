import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';

abstract class MainRepository {
  Future<CoursesResponse> getMainCourses({
    String? countryCode,
    int page = 1,
    int limit = 10,
  });
}
