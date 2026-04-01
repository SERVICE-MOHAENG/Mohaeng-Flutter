import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/domain/repository/main_repository.dart';

class GetMainCourseDetailUsecase {
  const GetMainCourseDetailUsecase(this._repository);

  final MainRepository _repository;

  Future<CourseResponse> call({required String id}) {
    return _repository.getMainCourseDetail(id: id);
  }
}
