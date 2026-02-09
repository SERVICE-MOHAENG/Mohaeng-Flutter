import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/main/data/repository/main_repository_impl.dart';
import 'package:mohaeng_app_service/features/main/domain/repository/main_repository.dart';
import 'package:mohaeng_app_service/features/main/domain/usecase/get_main_user_me.dart';
import 'package:mohaeng_app_service/features/mypage/data/repository/mypage_repository_impl.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_blogs.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_course_bookmarks.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_my_courses.dart';
import 'package:mohaeng_app_service/features/mypage/domain/usecase/get_visited_countries.dart';
import 'package:mohaeng_app_service/features/mypage/presentation/view_model/mypage_view_model.dart';

final myPageRepositoryProvider = Provider<MyPageRepository>(
  (ref) => MyPageRepositoryImpl(),
);

final mainRepositoryProvider = Provider<MainRepository>(
  (ref) => MainRepositoryImpl(),
);

final getMainUserMeUsecaseProvider = Provider<GetMainUserMeUsecase>(
  (ref) => GetMainUserMeUsecase(ref.watch(mainRepositoryProvider)),
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

final myPageViewModelProvider =
    StateNotifierProvider<MyPageViewModel, MyPageState>(
      (ref) => MyPageViewModel(
        getMainUserMeUsecase: ref.watch(getMainUserMeUsecaseProvider),
        getMyCoursesUsecase: ref.watch(getMyCoursesUsecaseProvider),
        getMyCourseBookmarksUsecase: ref.watch(
          getMyCourseBookmarksUsecaseProvider,
        ),
        getMyBlogsUsecase: ref.watch(getMyBlogsUsecaseProvider),
        getVisitedCountriesUsecase: ref.watch(
          getVisitedCountriesUsecaseProvider,
        ),
      ),
    );
