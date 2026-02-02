import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class GetMyCourseBookmarksUsecase {
  const GetMyCourseBookmarksUsecase(this._repository);

  final MyPageRepository _repository;

  Future<CourseItemsResponse> call({int page = 1, int limit = 20}) {
    return _repository.getMyCourseBookmarks(page: page, limit: limit);
  }
}
