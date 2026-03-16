import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/liked_region_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/mypage_summary_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/visited_country_models.dart';

abstract class MyPageRepository {
  Future<MyPageSummaryResponse> getMyPageSummary({bool forceRefresh = false});

  Future<CoursesResponse> getMyCourses({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  });

  Future<CourseItemsResponse> getMyCourseBookmarks({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  });

  Future<CourseItemsResponse> getMyCourseLikes({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  });

  Future<BlogsResponse> getMyBlogs({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  });

  Future<BlogItemsResponse> getMyBlogLikes({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  });

  Future<LikedRegionsResponse> getLikedRegions({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  });

  Future<VisitedCountryItemsResponse> getVisitedCountries({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  });

  Future<VisitedCountryResponse> addVisitedCountry({
    required String countryId,
    required String visitDate,
  });

  Future<void> deleteVisitedCountry({required String id});

  Future<void> deleteMyAccount();

  void clearCache();
}
