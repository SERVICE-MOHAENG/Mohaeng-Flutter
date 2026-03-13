import 'package:mohaeng_app_service/features/mypage/data/model/visited_country_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class GetVisitedCountriesUsecase {
  const GetVisitedCountriesUsecase(this._repository);

  final MyPageRepository _repository;

  Future<VisitedCountryItemsResponse> call({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) {
    return _repository.getVisitedCountries(
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
