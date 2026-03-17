import 'package:mohaeng_app_service/features/main/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/main/domain/repository/main_repository.dart';

class GetMainBlogsUsecase {
  const GetMainBlogsUsecase(this._repository);

  final MainRepository _repository;

  Future<BlogsResponse> call({int page = 1, int limit = 6}) {
    return _repository.getMainBlogs(page: page, limit: limit);
  }
}
