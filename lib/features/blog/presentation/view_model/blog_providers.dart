import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/blog/data/repository/blog_repository_impl.dart';
import 'package:mohaeng_app_service/features/blog/domain/repository/blog_repository.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/add_blog_like.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/create_blog.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/get_blog_detail.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/remove_blog_like.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/upload_blog_image.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view_model/blog_course_selection_view_model.dart';
import 'package:mohaeng_app_service/features/blog/presentation/view_model/blog_detail_view_model.dart';
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

final getBlogDetailUsecaseProvider = Provider<GetBlogDetailUsecase>(
  (ref) => GetBlogDetailUsecase(ref.watch(blogRepositoryProvider)),
);

final addBlogLikeUsecaseProvider = Provider<AddBlogLikeUsecase>(
  (ref) => AddBlogLikeUsecase(ref.watch(blogRepositoryProvider)),
);

final removeBlogLikeUsecaseProvider = Provider<RemoveBlogLikeUsecase>(
  (ref) => RemoveBlogLikeUsecase(ref.watch(blogRepositoryProvider)),
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

final blogDetailViewModelProvider = StateNotifierProvider.autoDispose
    .family<BlogDetailViewModel, BlogDetailState, String>(
      (ref, blogId) => BlogDetailViewModel(
        ref.watch(getBlogDetailUsecaseProvider),
        ref.watch(addBlogLikeUsecaseProvider),
        ref.watch(removeBlogLikeUsecaseProvider),
        blogId,
      ),
    );
