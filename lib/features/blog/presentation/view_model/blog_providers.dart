import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/blog/data/repository/blog_repository_impl.dart';
import 'package:mohaeng_app_service/features/blog/domain/repository/blog_repository.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/create_blog.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/upload_blog_image.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view_model/blog_course_selection_view_model.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view_model/blog_write_view_model.dart';
import 'package:mohaeng_app_service/features/mypage/presentation/view_model/mypage_providers.dart';

final blogRepositoryProvider = Provider<BlogRepository>(
  (ref) => BlogRepositoryImpl(),
);

final uploadBlogImageUsecaseProvider = Provider<UploadBlogImageUsecase>(
  (ref) => UploadBlogImageUsecase(ref.watch(blogRepositoryProvider)),
);

final createBlogUsecaseProvider = Provider<CreateBlogUsecase>(
  (ref) => CreateBlogUsecase(ref.watch(blogRepositoryProvider)),
);

final blogWriteViewModelProvider =
    StateNotifierProvider.autoDispose<BlogWriteViewModel, BlogWriteState>(
      (ref) => BlogWriteViewModel(
        uploadBlogImageUsecase: ref.watch(uploadBlogImageUsecaseProvider),
        createBlogUsecase: ref.watch(createBlogUsecaseProvider),
      ),
    );

final blogCourseSelectionViewModelProvider =
    StateNotifierProvider.autoDispose<
      BlogCourseSelectionViewModel,
      BlogCourseSelectionState
    >(
      (ref) =>
          BlogCourseSelectionViewModel(ref.watch(getMyCoursesUsecaseProvider)),
    );
