import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/auth/data/auth_token_storage.dart';
import 'package:mohaeng_app_service/features/mypage/data/repository/mypage_repository_impl.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/clear_my_page_cache.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/delete_my_account.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_blogs.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_course_bookmarks.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_courses.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_page_summary.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_visited_countries.dart';
import 'package:mohaeng_app_service/features/mypage/presentation/view_model/mypage_view_model.dart';

final myPageRepositoryProvider = Provider<MyPageRepository>(
  (ref) => MyPageRepositoryImpl(),
);

final myPageAuthTokenStorageProvider = Provider<AuthTokenStorage>(
  (ref) => AuthTokenStorage(),
);

final getMyPageSummaryUsecaseProvider = Provider<GetMyPageSummaryUsecase>(
  (ref) => GetMyPageSummaryUsecase(ref.watch(myPageRepositoryProvider)),
);

final getMyCoursesUsecaseProvider = Provider<GetMyCoursesUsecase>(
  (ref) => GetMyCoursesUsecase(ref.watch(myPageRepositoryProvider)),
);

final getMyCourseBookmarksUsecaseProvider =
    Provider<GetMyCourseBookmarksUsecase>(
      (ref) => GetMyCourseBookmarksUsecase(ref.watch(myPageRepositoryProvider)),
    );

final getMyBlogsUsecaseProvider = Provider<GetMyBlogsUsecase>(
  (ref) => GetMyBlogsUsecase(ref.watch(myPageRepositoryProvider)),
);

final getVisitedCountriesUsecaseProvider = Provider<GetVisitedCountriesUsecase>(
  (ref) => GetVisitedCountriesUsecase(ref.watch(myPageRepositoryProvider)),
);

final deleteMyAccountUsecaseProvider = Provider<DeleteMyAccountUsecase>(
  (ref) => DeleteMyAccountUsecase(ref.watch(myPageRepositoryProvider)),
);

final clearMyPageCacheUsecaseProvider = Provider<ClearMyPageCacheUsecase>(
  (ref) => ClearMyPageCacheUsecase(ref.watch(myPageRepositoryProvider)),
);

final myPageViewModelProvider =
    StateNotifierProvider<MyPageViewModel, MyPageState>(
      (ref) => MyPageViewModel(
        getMyPageSummaryUsecase: ref.watch(getMyPageSummaryUsecaseProvider),
        getMyCoursesUsecase: ref.watch(getMyCoursesUsecaseProvider),
        getMyCourseBookmarksUsecase: ref.watch(
          getMyCourseBookmarksUsecaseProvider,
        ),
        getMyBlogsUsecase: ref.watch(getMyBlogsUsecaseProvider),
        getVisitedCountriesUsecase: ref.watch(
          getVisitedCountriesUsecaseProvider,
        ),
        deleteMyAccountUsecase: ref.watch(deleteMyAccountUsecaseProvider),
        clearMyPageCacheUsecase: ref.watch(clearMyPageCacheUsecaseProvider),
        tokenStorage: ref.watch(myPageAuthTokenStorageProvider),
      ),
    );
