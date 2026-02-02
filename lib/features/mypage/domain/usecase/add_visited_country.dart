import 'package:mohaeng_app_service/features/mypage/data/model/visited_country_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class AddVisitedCountryUsecase {
  const AddVisitedCountryUsecase(this._repository);

  final MyPageRepository _repository;

  Future<VisitedCountryResponse> call({
    required String countryId,
    required String visitDate,
  }) {
    return _repository.addVisitedCountry(
      countryId: countryId,
      visitDate: visitDate,
    );
  }
}
