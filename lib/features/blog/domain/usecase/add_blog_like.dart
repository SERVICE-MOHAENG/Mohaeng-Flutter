import 'package:mohaeng_app_service/features/blog/domain/repository/blog_repository.dart';

class AddBlogLikeUsecase {
  const AddBlogLikeUsecase(this._repository);

  final BlogRepository _repository;

  Future<void> call({required String id}) {
    return _repository.addBlogLike(id: id);
  }
}
