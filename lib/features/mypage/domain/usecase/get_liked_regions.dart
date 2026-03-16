import 'package:mohaeng_app_service/features/mypage/data/model/liked_region_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class GetLikedRegionsUsecase {
  const GetLikedRegionsUsecase(this._repository);

  final MyPageRepository _repository;

  Future<LikedRegionsResponse> call({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) {
    return _repository.getLikedRegions(
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
