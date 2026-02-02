import 'package:mohaeng_app_service/features/main/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/data/model/user_models.dart';

abstract class MainRepository {
  Future<CoursesResponse> getMainCourses({
    String? countryCode,
    int page = 1,
    int limit = 10,
  });

  Future<BlogsResponse> getMainBlogs({
    String sortBy = 'latest',
    int page = 1,
    int limit = 6,
  });

  Future<MainUserResponse> getMainUserMe();
}
