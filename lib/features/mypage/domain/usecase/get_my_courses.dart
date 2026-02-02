import 'package:mohaeng_app_service/features/mypage/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/mypage/domain/repository/mypage_repository.dart';

class GetMyCoursesUsecase {
  const GetMyCoursesUsecase(this._repository);

  final MyPageRepository _repository;

  Future<CoursesResponse> call({int page = 1, int limit = 20}) {
    return _repository.getMyCourses(page: page, limit: limit);
  }
}
