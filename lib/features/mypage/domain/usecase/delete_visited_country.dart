import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class DeleteVisitedCountryUsecase {
  const DeleteVisitedCountryUsecase(this._repository);

  final MyPageRepository _repository;

  Future<void> call({required String id}) {
    return _repository.deleteVisitedCountry(id: id);
  }
}
