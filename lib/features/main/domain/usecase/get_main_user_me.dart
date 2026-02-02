import 'package:mohaeng_app_service/features/main/data/model/user_models.dart';
import 'package:mohaeng_app_service/features/main/domain/repository/main_repository.dart';

class GetMainUserMeUsecase {
  const GetMainUserMeUsecase(this._repository);

  final MainRepository _repository;

  Future<MainUserResponse> call() {
    return _repository.getMainUserMe();
  }
}
