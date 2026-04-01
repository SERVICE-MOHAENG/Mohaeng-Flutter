import 'package:mohaeng_app_service/core/model/user_summary_models.dart';
import 'package:mohaeng_app_service/features/main/data/datasource/main_remote_datasource.dart';
import 'package:mohaeng_app_service/features/main/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/domain/repository/main_repository.dart';

class MainRepositoryImpl implements MainRepository {
  MainRepositoryImpl({MainRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? MainRemoteDataSource();

  final MainRemoteDataSource _remoteDataSource;

  @override
  Future<CoursesResponse> getMainCourses({
    String sortBy = 'popular',
    String? countryCode,
    int page = 1,
    int limit = 10,
  }) {
    return _remoteDataSource.getMainCourses(
      sortBy: sortBy,
      countryCode: countryCode,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<BlogsResponse> getMainBlogs({
    String sortBy = 'latest',
    int page = 1,
    int limit = 6,
  }) {
    return _remoteDataSource.getMainBlogs(
      sortBy: sortBy,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<CourseResponse> getMainCourseDetail({required String id}) {
    return _remoteDataSource.getMainCourseDetail(id: id);
  }

  @override
  Future<CourseResponse> completeMainCourse({
    required String id,
    required bool isCompleted,
  }) {
    return _remoteDataSource.completeMainCourse(
      id: id,
      isCompleted: isCompleted,
    );
  }

  @override
  Future<UserSummaryResponse> getMainUserMe() {
    return _remoteDataSource.getMainUserMe();
  }
}
