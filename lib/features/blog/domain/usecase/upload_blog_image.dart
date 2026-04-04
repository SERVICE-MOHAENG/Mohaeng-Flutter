import 'package:mohaeng_app_service/features/blog/domain/repository/blog_repository.dart';

class UploadBlogImageUsecase {
  const UploadBlogImageUsecase(this._repository);

  final BlogRepository _repository;

  Future<String> call({required String filePath}) {
    return _repository.uploadImage(filePath: filePath);
  }
}
