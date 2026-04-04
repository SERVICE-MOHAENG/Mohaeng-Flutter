import 'package:mohaeng_app_service/features/blog/data/model/blog_create_models.dart';
import 'package:mohaeng_app_service/features/blog/domain/repository/blog_repository.dart';

class CreateBlogUsecase {
  const CreateBlogUsecase(this._repository);

  final BlogRepository _repository;

  Future<CreatedBlogResponse> call({required CreateBlogRequest request}) {
    return _repository.createBlog(request: request);
  }
}
