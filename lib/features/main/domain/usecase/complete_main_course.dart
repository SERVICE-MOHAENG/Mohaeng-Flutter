import 'package:mohaeng_app_service/features/main/data/model/course_models.dart';
import 'package:mohaeng_app_service/features/main/domain/repository/main_repository.dart';

class CompleteMainCourseUsecase {
  const CompleteMainCourseUsecase(this._repository);

  final MainRepository _repository;

  Future<CourseResponse> call({
    required String id,
    required bool isCompleted,
  }) {
    return _repository.completeMainCourse(
      id: id,
      isCompleted: isCompleted,
    );
  }
}
