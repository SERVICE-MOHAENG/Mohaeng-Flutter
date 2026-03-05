import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_preference_result_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/roadmap_repository.dart';

class GetRoadmapPreferenceMeResultUsecase {
  const GetRoadmapPreferenceMeResultUsecase(this._repository);

  final RoadmapRepository _repository;

  Future<List<RoadmapPreferenceResultItem>> call() {
    return _repository.getPreferenceMeResult();
  }
}
