import 'package:mohaeng_app_service/features/mypage/data/datasource/mypage_remote_datasource.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class MyPageRepositoryImpl implements MyPageRepository {
  MyPageRepositoryImpl({MyPageRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? MyPageRemoteDataSource();

  final MyPageRemoteDataSource _remoteDataSource;

  @override
  Future<CoursesResponse> getMyCourses({int page = 1, int limit = 20}) {
    return _remoteDataSource.getMyCourses(page: page, limit: limit);
  }

  @override
  Future<CourseItemsResponse> getMyCourseBookmarks({
    int page = 1,
    int limit = 20,
  }) {
    return _remoteDataSource.getMyCourseBookmarks(page: page, limit: limit);
  }

  @override
  Future<CourseItemsResponse> getMyCourseLikes({int page = 1, int limit = 20}) {
    return _remoteDataSource.getMyCourseLikes(page: page, limit: limit);
  }
}
