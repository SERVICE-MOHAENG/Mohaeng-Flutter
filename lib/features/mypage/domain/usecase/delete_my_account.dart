import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class DeleteMyAccountUsecase {
  const DeleteMyAccountUsecase(this._repository);

  final MyPageRepository _repository;

  Future<void> call() {
    return _repository.deleteMyAccount();
  }
}
