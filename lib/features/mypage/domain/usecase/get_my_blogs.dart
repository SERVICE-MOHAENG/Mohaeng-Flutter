import 'package:mohaeng_app_service/features/mypage/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class GetMyBlogsUsecase {
  const GetMyBlogsUsecase(this._repository);

  final MyPageRepository _repository;

  Future<BlogsResponse> call({
    int page = 1,
    int limit = 6,
    bool forceRefresh = false,
  }) {
    return _repository.getMyBlogs(
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
