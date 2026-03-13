import 'package:mohaeng_app_service/features/mypage/data/model/mypage_summary_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class GetMyPageSummaryUsecase {
  const GetMyPageSummaryUsecase(this._repository);

  final MyPageRepository _repository;

  Future<MyPageSummaryResponse> call({bool forceRefresh = false}) {
    return _repository.getMyPageSummary(forceRefresh: forceRefresh);
  }
}
