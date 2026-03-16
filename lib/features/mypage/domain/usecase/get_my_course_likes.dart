import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class GetMyCourseLikesUsecase {
  const GetMyCourseLikesUsecase(this._repository);

  final MyPageRepository _repository;

  Future<CourseItemsResponse> call({
    int page = 1,
    int limit = 10,
    bool forceRefresh = false,
  }) {
    return _repository.getMyCourseLikes(
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
