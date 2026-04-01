import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/main/data/repository/main_repository_impl.dart';
import 'package:mohaeng_app_service/features/main/domain/repository/main_repository.dart';
import 'package:mohaeng_app_service/features/main/domain/usecase/complete_main_course.dart';
import 'package:mohaeng_app_service/features/main/domain/usecase/get_main_course_detail.dart';
import 'package:mohaeng_app_service/features/main/domain/usecase/get_main_blogs.dart';
import 'package:mohaeng_app_service/features/main/domain/usecase/get_main_courses.dart';
import 'package:mohaeng_app_service/features/main/domain/usecase/get_main_user_me.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_blogs_view_model.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_courses_view_model.dart';
import 'package:mohaeng_app_service/features/main/presentation/view_model/main_user_view_model.dart';

final mainRepositoryProvider = Provider<MainRepository>(
  (ref) => MainRepositoryImpl(),
);

final getMainCoursesUsecaseProvider = Provider<GetMainCoursesUsecase>(
  (ref) => GetMainCoursesUsecase(ref.watch(mainRepositoryProvider)),
);

final getMainBlogsUsecaseProvider = Provider<GetMainBlogsUsecase>(
  (ref) => GetMainBlogsUsecase(ref.watch(mainRepositoryProvider)),
);

final getMainCourseDetailUsecaseProvider =
    Provider<GetMainCourseDetailUsecase>(
      (ref) => GetMainCourseDetailUsecase(ref.watch(mainRepositoryProvider)),
    );

final completeMainCourseUsecaseProvider =
    Provider<CompleteMainCourseUsecase>(
      (ref) => CompleteMainCourseUsecase(ref.watch(mainRepositoryProvider)),
    );

final getMainUserMeUsecaseProvider = Provider<GetMainUserMeUsecase>(
  (ref) => GetMainUserMeUsecase(ref.watch(mainRepositoryProvider)),
);

final mainCoursesViewModelProvider =
    StateNotifierProvider<MainCoursesViewModel, MainCoursesState>(
      (ref) => MainCoursesViewModel(ref.watch(getMainCoursesUsecaseProvider)),
    );

final mainBlogsViewModelProvider =
    StateNotifierProvider<MainBlogsViewModel, MainBlogsState>(
      (ref) => MainBlogsViewModel(ref.watch(getMainBlogsUsecaseProvider)),
    );

final mainUserViewModelProvider =
    StateNotifierProvider<MainUserViewModel, MainUserState>(
      (ref) => MainUserViewModel(ref.watch(getMainUserMeUsecaseProvider)),
    );
