import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/domain/repository/main_repository.dart';

class GetMainCoursesUsecase {
  const GetMainCoursesUsecase(this._repository);

  final MainRepository _repository;

  Future<CoursesResponse> call({
    String sortBy = 'popular',
    String? countryCode,
    int page = 1,
    int limit = 10,
  }) {
    return _repository.getMainCourses(
      sortBy: sortBy,
      countryCode: countryCode,
      page: page,
      limit: limit,
    );
  }
}
