import 'package:mohaeng_app_service/features/blog/domain/repository/blog_repository.dart';

class RemoveBlogLikeUsecase {
  const RemoveBlogLikeUsecase(this._repository);

  final BlogRepository _repository;

  Future<void> call({required String id}) {
    return _repository.removeBlogLike(id: id);
  }
}
