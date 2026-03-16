import 'package:mohaeng_app_service/features/mypage/data/model/blog_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class GetMyBlogLikesUsecase {
  const GetMyBlogLikesUsecase(this._repository);

  final MyPageRepository _repository;

  Future<BlogItemsResponse> call({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) {
    return _repository.getMyBlogLikes(
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
