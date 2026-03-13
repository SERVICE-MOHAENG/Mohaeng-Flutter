import 'package:mohaeng_app_service/features/mypage/data/datasource/mypage_remote_datasource.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/mypage_summary_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/visited_country_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class MyPageRepositoryImpl implements MyPageRepository {
  MyPageRepositoryImpl({MyPageRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? MyPageRemoteDataSource();

  final MyPageRemoteDataSource _remoteDataSource;

  @override
  Future<MyPageSummaryResponse> getMyPageSummary() {
    return _remoteDataSource.getMyPageSummary();
  }

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

  @override
  Future<BlogsResponse> getMyBlogs({int page = 1, int limit = 6}) {
    return _remoteDataSource.getMyBlogs(page: page, limit: limit);
  }

  @override
  Future<BlogItemsResponse> getMyBlogLikes({int page = 1, int limit = 6}) {
    return _remoteDataSource.getMyBlogLikes(page: page, limit: limit);
  }

  @override
  Future<VisitedCountryItemsResponse> getVisitedCountries({
    int page = 1,
    int limit = 10,
  }) {
    return _remoteDataSource.getVisitedCountries(page: page, limit: limit);
  }

  @override
  Future<VisitedCountryResponse> addVisitedCountry({
    required String countryId,
    required String visitDate,
  }) {
    return _remoteDataSource.addVisitedCountry(
      countryId: countryId,
      visitDate: visitDate,
    );
  }

  @override
  Future<void> deleteVisitedCountry({required String id}) {
    return _remoteDataSource.deleteVisitedCountry(id: id);
  }

  @override
  Future<void> deleteMyAccount() {
    return _remoteDataSource.deleteMyAccount();
  }
}
