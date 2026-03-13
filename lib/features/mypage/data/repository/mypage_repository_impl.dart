import 'package:mohaeng_app_service/features/mypage/data/datasource/mypage_remote_datasource.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/mypage_summary_models.dart';
import 'package:mohaeng_app_service/features/mypage/data/model/visited_country_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class MyPageRepositoryImpl implements MyPageRepository {
  MyPageRepositoryImpl({MyPageRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? MyPageRemoteDataSource();

  static const Duration _summaryCacheTtl = Duration(minutes: 5);
  static const Duration _listCacheTtl = Duration(minutes: 2);

  final MyPageRemoteDataSource _remoteDataSource;
  _CacheEntry<MyPageSummaryResponse>? _summaryCache;
  final Map<String, _CacheEntry<CoursesResponse>> _coursesCache =
      <String, _CacheEntry<CoursesResponse>>{};
  final Map<String, _CacheEntry<CourseItemsResponse>> _courseBookmarksCache =
      <String, _CacheEntry<CourseItemsResponse>>{};
  final Map<String, _CacheEntry<CourseItemsResponse>> _courseLikesCache =
      <String, _CacheEntry<CourseItemsResponse>>{};
  final Map<String, _CacheEntry<BlogsResponse>> _blogsCache =
      <String, _CacheEntry<BlogsResponse>>{};
  final Map<String, _CacheEntry<BlogItemsResponse>> _blogLikesCache =
      <String, _CacheEntry<BlogItemsResponse>>{};
  final Map<String, _CacheEntry<VisitedCountryItemsResponse>>
  _visitedCountriesCache = <String, _CacheEntry<VisitedCountryItemsResponse>>{};

  @override
  Future<MyPageSummaryResponse> getMyPageSummary({
    bool forceRefresh = false,
  }) async {
    final cached = _readCache(
      entry: _summaryCache,
      ttl: _summaryCacheTtl,
      forceRefresh: forceRefresh,
    );
    if (cached != null) return cached;

    final response = await _remoteDataSource.getMyPageSummary();
    _summaryCache = _CacheEntry(response);
    return response;
  }

  @override
  Future<CoursesResponse> getMyCourses({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final key = _pageKey(page: page, limit: limit);
    final cached = _readCache(
      entry: _coursesCache[key],
      ttl: _listCacheTtl,
      forceRefresh: forceRefresh,
    );
    if (cached != null) return cached;

    final response = await _remoteDataSource.getMyCourses(
      page: page,
      limit: limit,
    );
    _coursesCache[key] = _CacheEntry(response);
    return response;
  }

  @override
  Future<CourseItemsResponse> getMyCourseBookmarks({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final key = _pageKey(page: page, limit: limit);
    final cached = _readCache(
      entry: _courseBookmarksCache[key],
      ttl: _listCacheTtl,
      forceRefresh: forceRefresh,
    );
    if (cached != null) return cached;

    final response = await _remoteDataSource.getMyCourseBookmarks(
      page: page,
      limit: limit,
    );
    _courseBookmarksCache[key] = _CacheEntry(response);
    return response;
  }

  @override
  Future<CourseItemsResponse> getMyCourseLikes({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    final key = _pageKey(page: page, limit: limit);
    final cached = _readCache(
      entry: _courseLikesCache[key],
      ttl: _listCacheTtl,
      forceRefresh: forceRefresh,
    );
    if (cached != null) return cached;

    final response = await _remoteDataSource.getMyCourseLikes(
      page: page,
      limit: limit,
    );
    _courseLikesCache[key] = _CacheEntry(response);
    return response;
  }

  @override
  Future<BlogsResponse> getMyBlogs({
    int page = 1,
    int limit = 6,
    bool forceRefresh = false,
  }) async {
    final key = _pageKey(page: page, limit: limit);
    final cached = _readCache(
      entry: _blogsCache[key],
      ttl: _listCacheTtl,
      forceRefresh: forceRefresh,
    );
    if (cached != null) return cached;

    final response = await _remoteDataSource.getMyBlogs(
      page: page,
      limit: limit,
    );
    _blogsCache[key] = _CacheEntry(response);
    return response;
  }

  @override
  Future<BlogItemsResponse> getMyBlogLikes({
    int page = 1,
    int limit = 6,
    bool forceRefresh = false,
  }) async {
    final key = _pageKey(page: page, limit: limit);
    final cached = _readCache(
      entry: _blogLikesCache[key],
      ttl: _listCacheTtl,
      forceRefresh: forceRefresh,
    );
    if (cached != null) return cached;

    final response = await _remoteDataSource.getMyBlogLikes(
      page: page,
      limit: limit,
    );
    _blogLikesCache[key] = _CacheEntry(response);
    return response;
  }

  @override
  Future<VisitedCountryItemsResponse> getVisitedCountries({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    final key = _pageKey(page: page, limit: limit);
    final cached = _readCache(
      entry: _visitedCountriesCache[key],
      ttl: _listCacheTtl,
      forceRefresh: forceRefresh,
    );
    if (cached != null) return cached;

    final response = await _remoteDataSource.getVisitedCountries(
      page: page,
      limit: limit,
    );
    _visitedCountriesCache[key] = _CacheEntry(response);
    return response;
  }

  @override
  Future<VisitedCountryResponse> addVisitedCountry({
    required String countryId,
    required String visitDate,
  }) async {
    final response = await _remoteDataSource.addVisitedCountry(
      countryId: countryId,
      visitDate: visitDate,
    );
    _summaryCache = null;
    _visitedCountriesCache.clear();
    return response;
  }

  @override
  Future<void> deleteVisitedCountry({required String id}) async {
    await _remoteDataSource.deleteVisitedCountry(id: id);
    _summaryCache = null;
    _visitedCountriesCache.clear();
  }

  @override
  Future<void> deleteMyAccount() async {
    await _remoteDataSource.deleteMyAccount();
    clearCache();
  }

  @override
  void clearCache() {
    _summaryCache = null;
    _coursesCache.clear();
    _courseBookmarksCache.clear();
    _courseLikesCache.clear();
    _blogsCache.clear();
    _blogLikesCache.clear();
    _visitedCountriesCache.clear();
  }
}

class _CacheEntry<T> {
  _CacheEntry(this.value) : cachedAt = DateTime.now();

  final T value;
  final DateTime cachedAt;

  bool isFresh(Duration ttl) => DateTime.now().difference(cachedAt) < ttl;
}

String _pageKey({required int page, required int limit}) => '$page:$limit';

T? _readCache<T>({
  required _CacheEntry<T>? entry,
  required Duration ttl,
  required bool forceRefresh,
}) {
  if (forceRefresh || entry == null || !entry.isFresh(ttl)) {
    return null;
  }
  return entry.value;
}
