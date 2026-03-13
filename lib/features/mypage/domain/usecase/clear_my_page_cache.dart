import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class ClearMyPageCacheUsecase {
  const ClearMyPageCacheUsecase(this._repository);

  final MyPageRepository _repository;

  void call() {
    _repository.clearCache();
  }
}
