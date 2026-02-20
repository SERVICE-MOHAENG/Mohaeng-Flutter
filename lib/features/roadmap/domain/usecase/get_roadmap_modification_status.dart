import 'package:mohaeng_app_service/features/roadmap/data/model/roadmap_modification_status_models.dart';
import 'package:mohaeng_app_service/features/roadmap/domain/repository/roadmap_repository.dart';

class GetRoadmapModificationStatusUsecase {
  const GetRoadmapModificationStatusUsecase(this._repository);

  final RoadmapRepository _repository;

  Future<RoadmapModificationStatusResponse> call({
    required String jobId,
  }) {
    return _repository.getModificationStatus(jobId: jobId);
  }
}
