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
    String? countryCode,
    int page = 1,
    int limit = 10,
  }) {
    return _remoteDataSource.getMainCourses(
      countryCode: countryCode,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<BlogsResponse> getMainBlogs({int page = 1, int limit = 6}) {
    return _remoteDataSource.getMainBlogs(page: page, limit: limit);
  }

  @override
  Future<UserSummaryResponse> getMainUserMe() {
    return _remoteDataSource.getMainUserMe();
  }
}
