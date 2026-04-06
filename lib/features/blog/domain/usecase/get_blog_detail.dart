import 'package:mohaeng_app_service/features/blog/data/model/blog_detail_models.dart';
import 'package:mohaeng_app_service/features/blog/domain/repository/blog_repository.dart';

class GetBlogDetailUsecase {
  const GetBlogDetailUsecase(this._repository);

  final BlogRepository _repository;

  Future<BlogDetailResponse> call({required String id}) {
    return _repository.getBlogDetail(id: id);
  }
}
