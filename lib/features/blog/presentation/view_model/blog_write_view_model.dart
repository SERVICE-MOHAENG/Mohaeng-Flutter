import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mohaeng_app_service/features/blog/data/model/blog_create_models.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/create_blog.dart';
import 'package:mohaeng_app_service/features/blog/domain/usecase/upload_blog_image.dart';

@immutable
class BlogWriteState {
  const BlogWriteState({
    this.isUploadingImage = false,
    this.isSubmitting = false,
    this.uploadedImageUrls = const <String>[],
  });

  final bool isUploadingImage;
  final bool isSubmitting;
  final List<String> uploadedImageUrls;

  BlogWriteState copyWith({
    bool? isUploadingImage,
    bool? isSubmitting,
    List<String>? uploadedImageUrls,
  }) {
    return BlogWriteState(
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      uploadedImageUrls: uploadedImageUrls ?? this.uploadedImageUrls,
    );
  }
}

class BlogWriteViewModel extends StateNotifier<BlogWriteState> {
  BlogWriteViewModel({
    required UploadBlogImageUsecase uploadBlogImageUsecase,
    required CreateBlogUsecase createBlogUsecase,
  }) : _uploadBlogImageUsecase = uploadBlogImageUsecase,
       _createBlogUsecase = createBlogUsecase,
       super(const BlogWriteState());

  final UploadBlogImageUsecase _uploadBlogImageUsecase;
  final CreateBlogUsecase _createBlogUsecase;

  Future<String> uploadImage({required String filePath}) async {
    if (state.isUploadingImage) {
      throw StateError('image upload is already in progress.');
    }

    state = state.copyWith(
      isUploadingImage: true,
      uploadedImageUrls: const <String>[],
    );

    try {
      final imageUrl = await _uploadBlogImageUsecase(filePath: filePath);
      state = state.copyWith(
        isUploadingImage: false,
        uploadedImageUrls: <String>[imageUrl],
      );
      return imageUrl;
    } catch (_) {
      state = state.copyWith(
        isUploadingImage: false,
        uploadedImageUrls: const <String>[],
      );
      rethrow;
    }
  }

  void clearUploadedImages() {
    state = state.copyWith(uploadedImageUrls: const <String>[]);
  }

  Future<CreatedBlogResponse> createBlog({
    required CreateBlogRequest request,
  }) async {
    if (state.isSubmitting) {
      throw StateError('blog create is already in progress.');
    }

    state = state.copyWith(isSubmitting: true);
    try {
      final response = await _createBlogUsecase(request: request);
      state = state.copyWith(isSubmitting: false);
      return response;
    } catch (_) {
      state = state.copyWith(isSubmitting: false);
      rethrow;
    }
  }
}
